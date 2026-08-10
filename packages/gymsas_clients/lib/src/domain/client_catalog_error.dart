enum ClientCatalogErrorCode {
  unauthorized,
  unavailable,
  server,
  invalidResponse,
  timeout,
  network,
  unexpected,
}

class ClientCatalogException implements Exception {
  const ClientCatalogException(this.code);

  final ClientCatalogErrorCode code;
}
