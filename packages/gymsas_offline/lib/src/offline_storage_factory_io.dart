import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'offline_document_store.dart';
import 'secure_offline_value_storage.dart';
import 'encrypted_file_offline_value_storage.dart';

OfflineValueStorage createProductionOfflineStorage() => _LazyNativeStorage();

class _LazyNativeStorage implements OfflineValueStorage {
  Future<OfflineValueStorage>? _pending;
  Future<OfflineValueStorage> _open() =>
      _pending ??= _initialize().catchError((Object e, StackTrace s) {
        _pending = null;
        Error.throwWithStackTrace(e, s);
      });

  Future<OfflineValueStorage> _initialize() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/offline-v1');
    const protected = SecureOfflineValueStorage();
    const keyName = 'gymsas_offline_encryption_key_v1';
    var encoded = await protected.read(keyName);
    if (encoded == null) {
      if (await directory.exists() &&
          await directory.list().any((file) => file.path.endsWith('.bin'))) {
        throw StateError(
          'Encryption key unavailable; preserve existing offline files',
        );
      }
      final random = Random.secure();
      encoded = base64Encode(List.generate(32, (_) => random.nextInt(256)));
      await protected.write(keyName, encoded);
    }
    return _MigratingNativeStorage(
      EncryptedFileOfflineValueStorage(directory, base64Decode(encoded)),
      protected,
    );
  }

  @override
  Future<String?> read(String key) async => (await _open()).read(key);
  @override
  Future<void> write(String key, String value) async =>
      (await _open()).write(key, value);
}

/// One-way migration from the earlier protected-value adapter. Never remove a
/// legacy snapshot before a flushed encrypted replacement has been acknowledged.
class _MigratingNativeStorage implements OfflineValueStorage {
  _MigratingNativeStorage(this.files, this.protected);
  final OfflineValueStorage files, protected;
  String _marker(String key) => '${key}_native_migrated_v1';
  @override
  Future<String?> read(String key) async {
    final current = await files.read(key);
    if (current != null) return current;
    if (await protected.read(_marker(key)) == '1') {
      throw StateError(
        'Offline snapshot missing; do not resurrect stale legacy data',
      );
    }
    final legacy = await protected.read(key);
    if (legacy != null) {
      await files.write(key, legacy);
      await protected.write(_marker(key), '1');
    }
    return legacy;
  }

  @override
  Future<void> write(String key, String value) async {
    await files.write(key, value);
    await protected.write(_marker(key), '1');
  }
}
