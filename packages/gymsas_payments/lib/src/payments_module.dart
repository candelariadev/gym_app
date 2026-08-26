import 'dart:math';

import 'application/checkout_payment.dart';
import 'domain/payment_models.dart';
import 'infrastructure/http/payment_api_client.dart';
import 'infrastructure/mercado_pago/mercado_pago_gateway.dart';
import 'infrastructure/mercado_pago/mercado_pago_session_decoder.dart';
import 'ports/checkout_session_repository.dart';
import 'ports/payment_gateway.dart';
import 'ports/plan_catalog.dart';

class PaymentsModule {
  factory PaymentsModule.custom({
    required PlanCatalog plans,
    required CheckoutSessionRepository sessions,
    required PaymentGateway gateway,
    IdempotencyKeyFactory idempotencyKeyFactory = _newIdempotencyKey,
    void Function()? onDispose,
  }) => PaymentsModule._(
    plans,
    sessions,
    gateway,
    idempotencyKeyFactory,
    onDispose,
  );

  PaymentsModule._(
    this._plans,
    CheckoutSessionRepository sessions,
    PaymentGateway gateway,
    IdempotencyKeyFactory idempotencyKeyFactory,
    this._onDispose,
  ) : checkoutPayment = CheckoutPayment(
        sessions,
        gateway,
        idempotencyKeyFactory,
      );

  factory PaymentsModule.mercadoPago({
    required String graphQlUrl,
    required String publicKey,
    required AccessTokenProvider accessTokenProvider,
  }) {
    final api = PaymentApiClient(
      graphQlUrl,
      accessTokenProvider,
      const MercadoPagoSessionDecoder().call,
    );
    return PaymentsModule.custom(
      plans: api,
      sessions: api,
      gateway: MercadoPagoGateway(publicKey: publicKey),
      onDispose: api.close,
    );
  }

  final PlanCatalog _plans;
  final void Function()? _onDispose;
  final CheckoutPayment checkoutPayment;

  Future<List<PlanOffer>> listPlans() => _plans.list();

  void dispose() => _onDispose?.call();

  static String _newIdempotencyKey() {
    final random = Random.secure();
    final entropy = List<int>.generate(16, (_) => random.nextInt(256));
    final suffix = entropy
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
