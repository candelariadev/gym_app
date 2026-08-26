import 'package:gymsas_api_client/gymsas_api_client.dart';

import 'application/get_my_trainers_use_case.dart';
import 'application/get_trainer_clients_use_case.dart';
import 'domain/ports/client_access_token_provider.dart';
import 'infrastructure/datasources/trainer_clients_graphql_data_source.dart';
import 'infrastructure/datasources/my_trainers_graphql_data_source.dart';
import 'infrastructure/mappers/client_catalog_error_mapper.dart';
import 'infrastructure/repositories/trainer_client_repository_impl.dart';
import 'infrastructure/repositories/my_trainers_repository_impl.dart';

class TrainerClientsModule {
  TrainerClientsModule._({
    required this.getTrainerClientsUseCase,
    required this.getMyTrainersUseCase,
    required GraphQlClient graphQlClient,
  }) : _graphQlClient = graphQlClient;

  factory TrainerClientsModule.production({
    required String graphQlEndpoint,
    required ClientAccessTokenProvider accessTokenProvider,
  }) {
    final client = HttpGraphQlClient(endpoint: graphQlEndpoint);
    final repository = TrainerClientRepositoryImpl(
      dataSource: TrainerClientsGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
      errorMapper: const ClientCatalogErrorMapper(),
    );
    final myTrainersRepository = MyTrainersRepositoryImpl(
      dataSource: MyTrainersGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
      errorMapper: const ClientCatalogErrorMapper(),
    );
    return TrainerClientsModule._(
      getTrainerClientsUseCase: GetTrainerClientsUseCase(repository),
      getMyTrainersUseCase: GetMyTrainersUseCase(myTrainersRepository),
      graphQlClient: client,
    );
  }

  final GetTrainerClientsUseCase getTrainerClientsUseCase;
  final GetMyTrainersUseCase getMyTrainersUseCase;
  final GraphQlClient _graphQlClient;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _graphQlClient.close();
  }
}
