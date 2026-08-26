import 'package:flutter/foundation.dart';
import 'package:gymsas_payments/gymsas_payments.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController({required PaymentsModule payments}) : _payments = payments;
  final PaymentsModule _payments;
  bool isPaying = false;
  String? message;

  Future<List<PlanOffer>> loadPlans() => _payments.listPlans();
  Future<void> pay(PlanOffer plan, String payerEmail) async {
    if (isPaying || plan.isCurrent) return;
    isPaying = true;
    message = null;
    notifyListeners();
    try {
      final result = await _payments.checkoutPayment(
        CheckoutRequest(planId: plan.id, payerEmail: payerEmail.trim()),
      );
      message = switch (result.outcome) {
        PaymentOutcome.submitted =>
          'Pago enviado. Confirmaremos tu plan cuando el proveedor notifique al servidor.',
        PaymentOutcome.cancelled => 'Pago cancelado.',
        PaymentOutcome.failed =>
          result.message ?? 'No fue posible completar el pago.',
      };
    } catch (error) {
      message = error.toString();
    } finally {
      isPaying = false;
      notifyListeners();
    }
  }
}
