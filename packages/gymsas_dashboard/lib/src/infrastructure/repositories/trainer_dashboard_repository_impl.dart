import '../../domain/entities/trainer_dashboard.dart';
import '../../domain/dashboard_access_exception.dart';
import '../../domain/ports/dashboard_access_token_provider.dart';
import '../../domain/ports/trainer_dashboard_repository.dart';
import '../datasources/trainer_dashboard_graphql_data_source.dart';
import '../dto/trainer_dashboard_dto.dart';

class TrainerDashboardRepositoryImpl implements TrainerDashboardRepository {
  const TrainerDashboardRepositoryImpl({
    required TrainerDashboardGraphQlDataSource dataSource,
    required DashboardAccessTokenProvider accessTokenProvider,
  }) : _dataSource = dataSource,
       _accessTokenProvider = accessTokenProvider;

  final TrainerDashboardGraphQlDataSource _dataSource;
  final DashboardAccessTokenProvider _accessTokenProvider;

  @override
  Future<TrainerDashboard> getDashboard() async {
    final accessToken = _accessTokenProvider();
    if (accessToken == null || accessToken.isEmpty) {
      throw const DashboardAccessException();
    }
    final json = await _dataSource.getDashboard(accessToken: accessToken);
    return TrainerDashboardDto(json).toDomain();
  }
}
