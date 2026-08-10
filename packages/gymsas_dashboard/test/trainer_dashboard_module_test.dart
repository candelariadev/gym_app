import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_dashboard/src/infrastructure/datasources/trainer_dashboard_graphql_data_source.dart';
import 'package:gymsas_dashboard/src/infrastructure/dto/trainer_dashboard_dto.dart';
import 'package:test/test.dart';

void main() {
  test(
    'maps available and unavailable metrics without converting errors to zero',
    () {
      final dashboard = TrainerDashboardDto({
        'activeClients': {'value': 3, 'status': 'AVAILABLE'},
        'assignedWorkouts': {'value': null, 'status': 'UNAVAILABLE'},
        'generatedAt': '2026-08-09T18:00:00Z',
      }).toDomain();

      expect(dashboard.activeClients.value, 3);
      expect(dashboard.activeClients.isAvailable, isTrue);
      expect(dashboard.assignedWorkouts.value, isNull);
      expect(dashboard.assignedWorkouts.isAvailable, isFalse);
    },
  );

  test('sends one authenticated dashboard query', () async {
    final client = _FakeGraphQlClient({
      'trainerDashboard': {
        'activeClients': {'value': 1, 'status': 'AVAILABLE'},
        'assignedWorkouts': {'value': 2, 'status': 'AVAILABLE'},
        'generatedAt': '2026-08-09T18:00:00Z',
      },
    });
    final dataSource = TrainerDashboardGraphQlDataSource(client);

    final result = await dataSource.getDashboard(accessToken: 'access');

    expect(result['generatedAt'], '2026-08-09T18:00:00Z');
    expect(client.accessToken, 'access');
    expect(client.document, contains('trainerDashboard'));
  });
}

class _FakeGraphQlClient implements GraphQlClient {
  _FakeGraphQlClient(this.response);

  final Map<String, dynamic> response;
  String? document;
  String? accessToken;

  @override
  void close() {}

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    this.document = document;
    this.accessToken = accessToken;
    return response;
  }
}
