import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client_exception.dart';
import 'graphql_client.dart';
import 'graphql_exception.dart';

class HttpGraphQlClient implements GraphQlClient {
  HttpGraphQlClient({
    required String endpoint,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _endpoint = Uri.parse(endpoint),
       _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final Uri _endpoint;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  final Duration timeout;
  bool _isClosed = false;

  bool get isClosed => _isClosed;

  @override
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    if (_ownsHttpClient) _httpClient.close();
  }

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    try {
      final response = await _httpClient
          .post(
            _endpoint,
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              if (accessToken != null) 'authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'query': document, 'variables': variables}),
          )
          .timeout(timeout);

      final body = _decodeBody(response.body);
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw GraphQlException(
          errors
              .whereType<Map<String, dynamic>>()
              .map(GraphQlError.fromJson)
              .toList(growable: false),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiClientException(
          ApiClientErrorCode.server,
          statusCode: response.statusCode,
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ApiClientException(ApiClientErrorCode.invalidResponse);
      }
      return data;
    } on ApiClientException catch (_) {
      rethrow;
    } on GraphQlException catch (_) {
      rethrow;
    } on TimeoutException catch (_) {
      throw const ApiClientException(ApiClientErrorCode.timeout);
    } on FormatException catch (_) {
      throw const ApiClientException(ApiClientErrorCode.invalidResponse);
    } on http.ClientException catch (_) {
      throw const ApiClientException(ApiClientErrorCode.network);
    }
  }

  Map<String, dynamic> _decodeBody(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    return decoded;
  }
}
