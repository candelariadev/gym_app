import '../domain/payment_models.dart';

abstract interface class PlanCatalog {
  Future<List<PlanOffer>> list({
    String country = 'MX',
    String currency = 'MXN',
    String language = 'es',
  });
}
