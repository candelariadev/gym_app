import '../../domain/client_catalog_error.dart';
import '../../domain/entities/advised_trainer.dart';
import '../../domain/ports/advised_trainer_repository.dart';
import '../../domain/ports/client_access_token_provider.dart';
import '../datasources/my_trainers_graphql_data_source.dart';
import '../mappers/client_catalog_error_mapper.dart';

class MyTrainersRepositoryImpl implements AdvisedTrainerRepository {
  const MyTrainersRepositoryImpl({
    required MyTrainersGraphQlDataSource dataSource,
    required ClientAccessTokenProvider accessTokenProvider,
    required ClientCatalogErrorMapper errorMapper,
  })  : _dataSource = dataSource,
        _accessTokenProvider = accessTokenProvider,
        _errorMapper = errorMapper;

  final MyTrainersGraphQlDataSource _dataSource;
  final ClientAccessTokenProvider _accessTokenProvider;
  final ClientCatalogErrorMapper _errorMapper;

  @override
  Future<List<AdvisedTrainer>> getTrainers() async {
    try {
      final accessToken = _accessTokenProvider();
      if (accessToken == null || accessToken.isEmpty) {
        throw const ClientCatalogException(ClientCatalogErrorCode.unauthorized);
      }
      final dtos = await _dataSource.getTrainers(accessToken: accessToken);
      return dtos.map((dto) => dto.toDomain()).toList(growable: false);
    } on Object catch (error) {
      throw _errorMapper.from(error);
    }
  }
}

