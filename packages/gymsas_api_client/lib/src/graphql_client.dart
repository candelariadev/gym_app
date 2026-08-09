abstract interface class GraphQlClient {
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  });

  void close();
}
