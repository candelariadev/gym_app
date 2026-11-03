import 'dart:async';
import 'dart:convert';

/// Adapters must complete writes only after durable storage acknowledges them.
abstract interface class OfflineValueStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

abstract interface class OfflineDocumentStore {
  Future<Map<String, dynamic>> read(String scope);
  Future<T> update<T>(String scope, T Function(Map<String, dynamic>) change);
}

/// A single encrypted value atomically contains both snapshots and their outbox.
/// Serialization prevents read/modify/write races, including between accounts.
/// This adapter is intended for one application isolate.
class SerializedOfflineDocumentStore implements OfflineDocumentStore {
  SerializedOfflineDocumentStore(this._storage);
  final OfflineValueStorage _storage;
  Future<void> _tail = Future.value();

  String _key(String scope) =>
      'gymsas_offline_v1_${base64Url.encode(utf8.encode(scope))}';

  Future<Map<String, dynamic>> _read(String scope) async {
    final raw = await _storage.read(_key(scope));
    if (raw == null) return {'schemaVersion': 1};
    final document = jsonDecode(raw) as Map<String, dynamic>;
    if (document['schemaVersion'] != 1) {
      throw const FormatException('Unsupported offline schema; preserve data');
    }
    return document;
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  @override
  Future<Map<String, dynamic>> read(String scope) =>
      _exclusive(() => _read(scope));

  @override
  Future<T> update<T>(String scope, T Function(Map<String, dynamic>) change) =>
      _exclusive(() async {
        final document = await _read(scope);
        final result = change(document);
        await _storage.write(_key(scope), jsonEncode(document));
        return result;
      });
}
