import 'offline_document_store.dart';
import 'secure_offline_value_storage.dart';

// Web uses the browser storage adapter. Native apps use encrypted atomic files.
OfflineValueStorage createProductionOfflineStorage() =>
    const SecureOfflineValueStorage();
