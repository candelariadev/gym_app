class AppConfig {
  const AppConfig({required this.graphQlUrl, this.mercadoPagoPublicKey = ''});

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      graphQlUrl: String.fromEnvironment(
        'GYMSAS_CORE_GRAPHQL_URL',
        defaultValue: String.fromEnvironment(
          'BFF_GRAPHQL_URL',
          defaultValue: 'http://10.0.2.2:8080/graphql',
        ),
      ),
      mercadoPagoPublicKey: String.fromEnvironment('MERCADO_PAGO_PUBLIC_KEY'),
    );
  }

  final String graphQlUrl;
  final String mercadoPagoPublicKey;
}
