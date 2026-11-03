import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'offline_document_store.dart';

/// Native encrypted snapshots. AAD binds ciphertext to its account-scoped key.
/// The serialized document store is the sole writer in the application isolate.
class EncryptedFileOfflineValueStorage implements OfflineValueStorage {
  EncryptedFileOfflineValueStorage(this.directory, List<int> keyBytes)
    : _key = SecretKey(keyBytes) {
    if (keyBytes.length != 32) throw ArgumentError('Expected a 256-bit key');
  }
  final Directory directory;
  final SecretKey _key;
  final _cipher = AesGcm.with256bits();

  Future<File> _file(String key) async {
    final digest = await Sha256().hash(utf8.encode(key));
    final name = digest.bytes
        .map((v) => v.toRadixString(16).padLeft(2, '0'))
        .join();
    return File('${directory.path}/$name.bin');
  }

  @override
  Future<String?> read(String key) async {
    final file = await _file(key);
    if (!await file.exists()) return null;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    if (data['version'] != 1) {
      throw const FormatException('Unsupported encrypted storage version');
    }
    final box = SecretBox(
      base64Decode(data['ciphertext'] as String),
      nonce: base64Decode(data['nonce'] as String),
      mac: Mac(base64Decode(data['mac'] as String)),
    );
    final clear = await _cipher.decrypt(
      box,
      secretKey: _key,
      aad: utf8.encode(key),
    );
    return utf8.decode(clear);
  }

  @override
  Future<void> write(String key, String value) async {
    await directory.create(recursive: true);
    final box = await _cipher.encrypt(
      utf8.encode(value),
      secretKey: _key,
      nonce: _cipher.newNonce(),
      aad: utf8.encode(key),
    );
    final file = await _file(key);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({
        'version': 1,
        'nonce': base64Encode(box.nonce),
        'ciphertext': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      }),
      flush: true,
    );
    // Never delete the prior snapshot before the flushed replacement is ready.
    await temporary.rename(file.path);
  }
}
