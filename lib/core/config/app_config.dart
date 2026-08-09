class AppConfig {
  const AppConfig({required this.graphQlUrl, required this.ownerId});

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      graphQlUrl: String.fromEnvironment(
        'BFF_GRAPHQL_URL',
        defaultValue: 'http://10.0.2.2:8090/graphql',
      ),
      ownerId: String.fromEnvironment('GYM_OWNER_ID', defaultValue: 'tenant_1'),
    );
  }

  final String graphQlUrl;
  final String ownerId;
}
