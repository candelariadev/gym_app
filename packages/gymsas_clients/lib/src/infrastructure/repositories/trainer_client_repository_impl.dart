import '../../domain/client_catalog_error.dart';
import '../../domain/entities/trainer_client.dart';
import '../../domain/ports/client_access_token_provider.dart';
import '../../domain/ports/trainer_client_repository.dart';
import '../datasources/trainer_clients_graphql_data_source.dart';
import '../mappers/client_catalog_error_mapper.dart';

class TrainerClientRepositoryImpl implements TrainerClientRepository {
  const TrainerClientRepositoryImpl({
    required TrainerClientsGraphQlDataSource dataSource,
    required ClientAccessTokenProvider accessTokenProvider,
    required ClientCatalogErrorMapper errorMapper,
  }) : _dataSource = dataSource,
       _accessTokenProvider = accessTokenProvider,
       _errorMapper = errorMapper;

  final TrainerClientsGraphQlDataSource _dataSource;
  final ClientAccessTokenProvider _accessTokenProvider;
  final ClientCatalogErrorMapper _errorMapper;

  @override
  Future<List<TrainerClient>> getClients() async {
    try {
      final accessToken = _accessTokenProvider();
      if (accessToken == null || accessToken.isEmpty) {
        throw const ClientCatalogException(ClientCatalogErrorCode.unauthorized);
      }
      final dtos = await _dataSource.getClients(accessToken: accessToken);
      return dtos.map((dto) => dto.toDomain()).toList(growable: false);
    } on Object catch (error) {
      throw _errorMapper.from(error);
    }
  }
}
