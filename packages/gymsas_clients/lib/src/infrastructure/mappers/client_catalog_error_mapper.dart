import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/client_catalog_error.dart';

class ClientCatalogErrorMapper {
  const ClientCatalogErrorMapper();

  ClientCatalogException from(Object error) {
    if (error is ClientCatalogException) return error;
    if (error is GraphQlException) {
      final status = _status(error);
      return ClientCatalogException(switch (status) {
        401 || 403 => ClientCatalogErrorCode.unauthorized,
        502 || 503 || 504 => ClientCatalogErrorCode.unavailable,
        _ => ClientCatalogErrorCode.server,
      });
    }
    if (error is ApiClientException) {
      return ClientCatalogException(switch (error.code) {
        ApiClientErrorCode.server => ClientCatalogErrorCode.server,
        ApiClientErrorCode.invalidResponse =>
          ClientCatalogErrorCode.invalidResponse,
        ApiClientErrorCode.timeout => ClientCatalogErrorCode.timeout,
        ApiClientErrorCode.network => ClientCatalogErrorCode.network,
      });
    }
    if (error is FormatException || error is TypeError) {
      return const ClientCatalogException(
        ClientCatalogErrorCode.invalidResponse,
      );
    }
    return const ClientCatalogException(ClientCatalogErrorCode.unexpected);
  }

  int? _status(GraphQlException error) {
    if (error.errors.isEmpty) return null;
    final raw = error.errors.first.extensions['httpStatus'];
    return raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
  }
}
