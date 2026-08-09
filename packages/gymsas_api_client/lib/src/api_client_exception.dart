enum ApiClientErrorCode { server, invalidResponse, timeout, network }

class ApiClientException implements Exception {
  const ApiClientException(this.code, {this.statusCode});

  final ApiClientErrorCode code;
  final int? statusCode;
}
