class PlanOffer {
  const PlanOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.taxIncluded,
    this.isCurrent = false,
  });

  final String id;
  final String name;
  final String description;
  final int amountMinor;
  final String currency;
  final bool taxIncluded;
  final bool isCurrent;
}

class CheckoutRequest {
  const CheckoutRequest({
    required this.planId,
    required this.payerEmail,
    this.country = 'MX',
    this.currency = 'MXN',
  });

  final String planId;
  final String payerEmail;
  final String country;
  final String currency;
}

class CheckoutSession {
  const CheckoutSession({
    required this.id,
    required this.provider,
    required this.status,
    required this.clientPayload,
  });

  final String id;
  final String provider;
  final String status;
  final Map<String, String> clientPayload;
}

enum PaymentOutcome { submitted, cancelled, failed }

class PaymentResult {
  const PaymentResult({
    required this.outcome,
    this.providerStatus,
    this.message,
  });

  final PaymentOutcome outcome;
  final String? providerStatus;
  final String? message;
}
