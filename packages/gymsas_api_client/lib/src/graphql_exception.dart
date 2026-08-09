class GraphQlError {
  const GraphQlError({required this.message, required this.extensions});

  factory GraphQlError.fromJson(Map<String, dynamic> json) {
    final extensions = json['extensions'];
    return GraphQlError(
      message: json['message']?.toString() ?? '',
      extensions: extensions is Map<String, dynamic> ? extensions : const {},
    );
  }

  final String message;
  final Map<String, dynamic> extensions;
}

class GraphQlException implements Exception {
  const GraphQlException(this.errors);

  final List<GraphQlError> errors;
}
