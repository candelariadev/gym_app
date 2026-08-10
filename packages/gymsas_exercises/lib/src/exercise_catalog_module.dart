import 'package:gymsas_api_client/gymsas_api_client.dart';

import 'application/get_exercises_use_case.dart';
import 'infrastructure/datasources/exercise_graphql_data_source.dart';
import 'infrastructure/mappers/exercise_catalog_error_mapper.dart';
import 'infrastructure/repositories/exercise_catalog_repository_impl.dart';
import 'domain/ports/exercise_access_token_provider.dart';

class ExerciseCatalogModule {
  ExerciseCatalogModule._({
    required this.getExercisesUseCase,
    required GraphQlClient graphQlClient,
  }) : _graphQlClient = graphQlClient;

  factory ExerciseCatalogModule.production({
    required String graphQlEndpoint,
    required ExerciseAccessTokenProvider accessTokenProvider,
  }) {
    final client = HttpGraphQlClient(endpoint: graphQlEndpoint);
    final repository = ExerciseCatalogRepositoryImpl(
      dataSource: ExerciseGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
      errorMapper: const ExerciseCatalogErrorMapper(),
    );
    return ExerciseCatalogModule._(
      getExercisesUseCase: GetExercisesUseCase(repository),
      graphQlClient: client,
    );
  }

  final GetExercisesUseCase getExercisesUseCase;
  final GraphQlClient _graphQlClient;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _graphQlClient.close();
  }
}
