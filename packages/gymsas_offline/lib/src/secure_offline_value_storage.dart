import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'offline_document_store.dart';

class SecureOfflineValueStorage implements OfflineValueStorage {
  const SecureOfflineValueStorage([
    this.storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  ]);
  final FlutterSecureStorage storage;
  @override
  Future<String?> read(String key) => storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);
}
