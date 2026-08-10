import '../../domain/entities/exercise_catalog_page.dart';
import '../../domain/entities/exercise_catalog_request.dart';
import '../../domain/exercise_catalog_error.dart';
import '../../domain/ports/exercise_catalog_repository.dart';
import '../../domain/ports/exercise_access_token_provider.dart';
import '../datasources/exercise_graphql_data_source.dart';
import '../mappers/exercise_catalog_error_mapper.dart';

class ExerciseCatalogRepositoryImpl implements ExerciseCatalogRepository {
  const ExerciseCatalogRepositoryImpl({
    required ExerciseGraphQlDataSource dataSource,
    required ExerciseAccessTokenProvider accessTokenProvider,
    required ExerciseCatalogErrorMapper errorMapper,
  }) : _dataSource = dataSource,
       _accessTokenProvider = accessTokenProvider,
       _errorMapper = errorMapper;

  final ExerciseGraphQlDataSource _dataSource;
  final ExerciseAccessTokenProvider _accessTokenProvider;
  final ExerciseCatalogErrorMapper _errorMapper;

  @override
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request) async {
    try {
      final accessToken = _accessTokenProvider();
      if (accessToken == null || accessToken.isEmpty) {
        throw const ExerciseCatalogException(
          ExerciseCatalogErrorCode.unauthorized,
        );
      }
      final dto = await _dataSource.getPage(
        request: request,
        accessToken: accessToken,
      );
      return dto.toDomain();
    } on Object catch (error) {
      throw _errorMapper.from(error);
    }
  }
}
