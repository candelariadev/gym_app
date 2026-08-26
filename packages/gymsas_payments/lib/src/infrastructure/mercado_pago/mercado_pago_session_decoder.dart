import '../../domain/payment_models.dart';

final class MercadoPagoSessionDecoder {
  const MercadoPagoSessionDecoder();

  CheckoutSession call(Map<String, dynamic> data) {
    return CheckoutSession(
      id: data['id'] as String,
      provider: 'mercado_pago',
      status: data['status'] as String,
      clientPayload: {
        'order_id': data['providerOrderId'] as String,
        'client_token': data['clientToken'] as String,
      },
    );
  }
}
