import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/payments/application/checkout_controller.dart';
import 'package:gym_app/features/payments/presentation/pages/plans_checkout_page.dart';
import 'package:gymsas_payments/gymsas_payments.dart';

void main() {
  testWidgets('muestra el plan actual deshabilitado', (tester) async {
    final payments = PaymentsModule.custom(
      plans: _CurrentPlanCatalog(),
      sessions: _UnusedCheckoutSessions(),
      gateway: _UnusedGateway(),
      idempotencyKeyFactory: () => 'idem-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PlansCheckoutPage(
          controller: CheckoutController(payments: payments),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plan actual'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}

class _CurrentPlanCatalog implements PlanCatalog {
  @override
  Future<List<PlanOffer>> list({
    String country = 'MX',
    String currency = 'MXN',
    String language = 'es',
  }) async => const [
    PlanOffer(
      id: 'individual',
      name: 'Individual',
      description: 'Plan vigente',
      amountMinor: 0,
      currency: 'MXN',
      taxIncluded: true,
      isCurrent: true,
    ),
  ];
}

class _UnusedCheckoutSessions implements CheckoutSessionRepository {
  @override
  Future<CheckoutSession> create(
    CheckoutRequest request, {
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

class _UnusedGateway implements PaymentGateway {
  @override
  Future<PaymentResult> checkout(CheckoutSession session) {
    throw UnimplementedError();
  }
}
