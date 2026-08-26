import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/payment_models.dart';
import '../../ports/checkout_session_repository.dart';
import '../../ports/plan_catalog.dart';

typedef AccessTokenProvider = String? Function();
typedef CheckoutSessionDecoder =
    CheckoutSession Function(Map<String, dynamic> data);

class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PaymentApiClient implements CheckoutSessionRepository, PlanCatalog {
  PaymentApiClient(
    String graphQlUrl,
    this._accessTokenProvider,
    this._checkoutSessionDecoder,
  ) : _graphQlUrl = Uri.parse(graphQlUrl),
      assert(graphQlUrl != '');

  final Uri _graphQlUrl;
  final AccessTokenProvider _accessTokenProvider;
  final CheckoutSessionDecoder _checkoutSessionDecoder;
  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 5);

  @override
  Future<List<PlanOffer>> list({
    String country = 'MX',
    String currency = 'MXN',
    String language = 'es',
  }) async {
    final response = await _execute(
      r'''
        query Plans($country: String!, $currency: String!, $language: String!) {
          plans(country: $country, currency: $currency, language: $language) {
            id
            name
            description
            isCurrent
            price {
              amountMinor
              currency
              taxIncluded
            }
          }
        }
      ''',
      variables: {
        'country': country,
        'currency': currency,
        'language': language,
      },
    );
    final data = response['plans'];
    if (data is! List) {
      throw const PaymentException('Catálogo de planes inválido');
    }
    return data
        .map((item) {
          final json = item as Map<String, dynamic>;
          final price = json['price'] as Map<String, dynamic>;
          return PlanOffer(
            id: json['id'] as String,
            name: json['name'] as String,
            description: json['description'] as String,
            amountMinor: (price['amountMinor'] as num).toInt(),
            currency: price['currency'] as String,
            taxIncluded: price['taxIncluded'] as bool? ?? false,
            isCurrent: json['isCurrent'] as bool? ?? false,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<CheckoutSession> create(
    CheckoutRequest request, {
    required String idempotencyKey,
  }) async {
    final response = await _execute(
      r'''
        mutation CreateCheckout($input: CreateCheckoutInput!) {
          createCheckout(input: $input) {
            id
            providerOrderId
            clientToken
            status
          }
        }
      ''',
      variables: {
        'input': {
          'idempotencyKey': idempotencyKey,
          'planId': request.planId,
          'country': request.country,
          'currency': request.currency,
          'payerEmail': request.payerEmail,
        },
      },
    );
    final data = response['createCheckout'];
    if (data is! Map<String, dynamic>) {
      throw const PaymentException('Sesión de pago inválida');
    }
    return _checkoutSessionDecoder(data);
  }

  Future<Map<String, dynamic>> _execute(
    String query, {
    required Map<String, Object?> variables,
  }) async {
    final token = _accessTokenProvider()?.trim();
    if (token == null || token.isEmpty) {
      throw const PaymentException('La sesión de usuario no está disponible');
    }
    try {
      final request = await _httpClient
          .postUrl(_graphQlUrl)
          .timeout(const Duration(seconds: 6));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'query': query, 'variables': variables}));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      final text = await utf8.decoder.bind(response).join();
      final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const PaymentException('Respuesta de pagos inválida');
      }
      final errors = decoded['errors'];
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          errors is List && errors.isNotEmpty) {
        final firstError = errors is List && errors.isNotEmpty
            ? errors.first
            : null;
        final message = firstError is Map<String, dynamic>
            ? firstError['message']?.toString()
            : decoded['message']?.toString();
        throw PaymentException(
          message ?? 'El BFF respondió ${response.statusCode}',
        );
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const PaymentException('Respuesta de pagos inválida');
      }
      return data;
    } on TimeoutException {
      throw const PaymentException('El servicio tardó demasiado en responder');
    } on SocketException {
      throw const PaymentException('No se pudo conectar con el BFF');
    } on FormatException {
      throw const PaymentException(
        'El servicio devolvió una respuesta inválida',
      );
    }
  }

  void close() => _httpClient.close(force: true);
}
