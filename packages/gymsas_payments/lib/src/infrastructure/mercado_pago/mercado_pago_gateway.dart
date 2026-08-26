import 'package:flutter/services.dart';

import '../../domain/payment_models.dart';
import '../../ports/payment_gateway.dart';

class MercadoPagoGateway implements PaymentGateway {
  const MercadoPagoGateway({
    required this.publicKey,
    this.channel = const MethodChannel('gymsas/payments'),
  });

  final String publicKey;
  final MethodChannel channel;

  @override
  Future<PaymentResult> checkout(CheckoutSession session) async {
    if (session.provider != 'mercado_pago') {
      throw StateError('El gateway Mercado Pago no acepta ${session.provider}');
    }
    if (publicKey.trim().isEmpty) {
      throw StateError('Falta MERCADO_PAGO_PUBLIC_KEY');
    }
    final orderId = session.clientPayload['order_id'];
    final clientToken = session.clientPayload['client_token'];
    if (orderId == null || clientToken == null) {
      throw StateError('La sesión no contiene los datos del proveedor');
    }
    final result = await channel.invokeMapMethod<String, dynamic>('checkout', {
      'publicKey': publicKey,
      'orderId': orderId,
      'clientToken': clientToken,
    });
    return PaymentResult(
      outcome: switch (result?['outcome']) {
        'success' => PaymentOutcome.submitted,
        'cancelled' => PaymentOutcome.cancelled,
        _ => PaymentOutcome.failed,
      },
      providerStatus: result?['providerStatus'] as String?,
      message: result?['message'] as String?,
    );
  }
}
