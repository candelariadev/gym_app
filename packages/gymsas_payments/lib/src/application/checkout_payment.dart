import '../domain/payment_models.dart';
import '../ports/checkout_session_repository.dart';
import '../ports/payment_gateway.dart';

typedef IdempotencyKeyFactory = String Function();

class CheckoutPayment {
  const CheckoutPayment(this._sessions, this._gateway, this._newIdempotencyKey);

  final CheckoutSessionRepository _sessions;
  final PaymentGateway _gateway;
  final IdempotencyKeyFactory _newIdempotencyKey;

  Future<PaymentResult> call(CheckoutRequest request) async {
    final session = await _sessions.create(
      request,
      idempotencyKey: _newIdempotencyKey(),
    );
    return _gateway.checkout(session);
  }
}
