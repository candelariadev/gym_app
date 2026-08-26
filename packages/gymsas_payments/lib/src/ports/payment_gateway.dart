import '../domain/payment_models.dart';

abstract interface class PaymentGateway {
  Future<PaymentResult> checkout(CheckoutSession session);
}
