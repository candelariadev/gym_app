import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'api_client_exception.dart';
import 'api_trace.dart';
import 'graphql_client.dart';
import 'graphql_exception.dart';

class HttpGraphQlClient implements GraphQlClient {
  HttpGraphQlClient({
    required String endpoint,
    http.Client? httpClient,
    this.trace = const DeveloperApiTrace(),
    this.timeout = const Duration(seconds: 20),
  }) : _endpoint = Uri.parse(endpoint),
       _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null;

  final Uri _endpoint;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  final Duration timeout;
  final ApiTrace trace;
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
    final correlationId = _correlationId();
    final operation = _operationName(document);
    final startedAt = DateTime.now();
    trace.record('graphql_request_started', {
      'operation': operation,
      'correlation_id': correlationId,
      'authenticated': accessToken != null,
    });
    try {
      final response = await _httpClient
          .post(
            _endpoint,
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              'x-correlation-id': correlationId,
              if (accessToken != null) 'authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'query': document, 'variables': variables}),
          )
          .timeout(timeout);

      final body = _decodeBody(response.body);
      final responseCorrelationId =
          response.headers['x-correlation-id'] ?? correlationId;
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        trace.record('graphql_request_failed', {
          'operation': operation,
          'correlation_id': responseCorrelationId,
          'status': response.statusCode,
          'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
          'graphql_error_count': errors.length,
        });
        throw GraphQlException(
          errors
              .whereType<Map<String, dynamic>>()
              .map(GraphQlError.fromJson)
              .toList(growable: false),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        trace.record('graphql_request_failed', {
          'operation': operation,
          'correlation_id': responseCorrelationId,
          'status': response.statusCode,
          'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
        });
        throw ApiClientException(
          ApiClientErrorCode.server,
          statusCode: response.statusCode,
        );
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        trace.record('graphql_invalid_response', {
          'operation': operation,
          'correlation_id': responseCorrelationId,
          'status': response.statusCode,
          'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
        });
        throw const ApiClientException(ApiClientErrorCode.invalidResponse);
      }
      trace.record('graphql_request_completed', {
        'operation': operation,
        'correlation_id': responseCorrelationId,
        'status': response.statusCode,
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      });
      return data;
    } on ApiClientException catch (_) {
      rethrow;
    } on GraphQlException catch (_) {
      rethrow;
    } on TimeoutException catch (_) {
      trace.record('graphql_request_timeout', {
        'operation': operation,
        'correlation_id': correlationId,
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      });
      throw const ApiClientException(ApiClientErrorCode.timeout);
    } on FormatException catch (_) {
      trace.record('graphql_invalid_response', {
        'operation': operation,
        'correlation_id': correlationId,
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      });
      throw const ApiClientException(ApiClientErrorCode.invalidResponse);
    } on http.ClientException catch (_) {
      trace.record('graphql_network_failed', {
        'operation': operation,
        'correlation_id': correlationId,
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      });
      throw const ApiClientException(ApiClientErrorCode.network);
    }
  }

  String _correlationId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    String hex(int start, int length) => bytes
        .skip(start)
        .take(length)
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 2)}-${hex(6, 2)}-${hex(8, 2)}-${hex(10, 6)}';
  }

  String _operationName(String document) {
    final match = RegExp(
      r'\b(?:query|mutation|subscription)\s+([_A-Za-z][_0-9A-Za-z]*)',
    ).firstMatch(document);
    return match?.group(1) ?? 'anonymous';
  }

  Map<String, dynamic> _decodeBody(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    return decoded;
  }
}
