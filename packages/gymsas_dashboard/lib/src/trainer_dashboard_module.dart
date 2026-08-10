import 'package:gymsas_api_client/gymsas_api_client.dart';

import 'application/get_trainer_dashboard_use_case.dart';
import 'domain/ports/dashboard_access_token_provider.dart';
import 'infrastructure/datasources/trainer_dashboard_graphql_data_source.dart';
import 'infrastructure/repositories/trainer_dashboard_repository_impl.dart';

class TrainerDashboardModule {
  TrainerDashboardModule._({
    required this.getTrainerDashboardUseCase,
    required GraphQlClient graphQlClient,
  }) : _graphQlClient = graphQlClient;

  factory TrainerDashboardModule.production({
    required String graphQlEndpoint,
    required DashboardAccessTokenProvider accessTokenProvider,
  }) {
    final client = HttpGraphQlClient(endpoint: graphQlEndpoint);
    final repository = TrainerDashboardRepositoryImpl(
      dataSource: TrainerDashboardGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
    );
    return TrainerDashboardModule._(
      getTrainerDashboardUseCase: GetTrainerDashboardUseCase(repository),
      graphQlClient: client,
    );
  }

  final GetTrainerDashboardUseCase getTrainerDashboardUseCase;
  final GraphQlClient _graphQlClient;
  bool _isDisposed = false;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _graphQlClient.close();
  }
}
