enum ExerciseCatalogErrorCode {
  unauthorized,
  unavailable,
  server,
  invalidResponse,
  timeout,
  network,
  unexpected,
}

class ExerciseCatalogException implements Exception {
  const ExerciseCatalogException(this.code);

  final ExerciseCatalogErrorCode code;
}
