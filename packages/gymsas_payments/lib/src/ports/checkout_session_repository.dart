import '../domain/payment_models.dart';

abstract interface class CheckoutSessionRepository {
  Future<CheckoutSession> create(
    CheckoutRequest request, {
    required String idempotencyKey,
  });
}
