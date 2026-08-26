import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_payments/gymsas_payments.dart';

void main() {
  test('orquesta la sesión y el gateway sin conocer al proveedor', () async {
    final sessions = _Sessions();
    final gateway = _Gateway();
    final checkout = CheckoutPayment(sessions, gateway, () => 'idem-1');

    final result = await checkout(
      const CheckoutRequest(planId: 'basic', payerEmail: 'buyer@example.com'),
    );

    expect(sessions.idempotencyKey, 'idem-1');
    expect(gateway.session?.provider, 'replaceable_provider');
    expect(result.outcome, PaymentOutcome.submitted);
  });

  test('permite ensamblar otro proveedor sin cambiar el caso de uso', () async {
    var disposed = false;
    final module = PaymentsModule.custom(
      plans: _Plans(),
      sessions: _Sessions(),
      gateway: _Gateway(),
      idempotencyKeyFactory: () => 'idem-custom',
      onDispose: () => disposed = true,
    );

    final plans = await module.listPlans();
    final result = await module.checkoutPayment(
      const CheckoutRequest(planId: 'basic', payerEmail: 'buyer@example.com'),
    );
    module.dispose();

    expect(plans.single.id, 'basic');
    expect(result.outcome, PaymentOutcome.submitted);
    expect(disposed, isTrue);
  });
}

class _Plans implements PlanCatalog {
  @override
  Future<List<PlanOffer>> list({
    String country = 'MX',
    String currency = 'MXN',
    String language = 'es',
  }) async => const [
    PlanOffer(
      id: 'basic',
      name: 'Básico',
      description: 'Plan básico',
      amountMinor: 19900,
      currency: 'MXN',
      taxIncluded: true,
    ),
  ];
}

class _Sessions implements CheckoutSessionRepository {
  String? idempotencyKey;

  @override
  Future<CheckoutSession> create(
    CheckoutRequest request, {
    required String idempotencyKey,
  }) async {
    this.idempotencyKey = idempotencyKey;
    return const CheckoutSession(
      id: 'checkout-1',
      provider: 'replaceable_provider',
      status: 'CREATED',
      clientPayload: {'secret': 'ephemeral'},
    );
  }
}

class _Gateway implements PaymentGateway {
  CheckoutSession? session;

  @override
  Future<PaymentResult> checkout(CheckoutSession session) async {
    this.session = session;
    return const PaymentResult(outcome: PaymentOutcome.submitted);
  }
}
