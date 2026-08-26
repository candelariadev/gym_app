enum WorkoutErrorCode {
  invalidInput,
  unauthorized,
  forbidden,
  conflict,
  quotaExceeded,
  unavailable,
  invalidResponse,
  timeout,
  network,
  server,
  unexpected,
}

class WorkoutException implements Exception {
  const WorkoutException(this.code, [this.message]);

  final WorkoutErrorCode code;
  final String? message;

  @override
  String toString() => message ?? code.name;
}
