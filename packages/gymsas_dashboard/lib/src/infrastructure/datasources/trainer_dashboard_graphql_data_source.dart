import 'package:gymsas_api_client/gymsas_api_client.dart';

class TrainerDashboardGraphQlDataSource {
  const TrainerDashboardGraphQlDataSource(this._client);

  static const document = r'''
    query TrainerDashboard {
      trainerDashboard {
        activeClients { value status }
        assignedWorkouts { value status }
        generatedAt
      }
    }
  ''';

  final GraphQlClient _client;

  Future<Map<String, dynamic>> getDashboard({
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: document,
      accessToken: accessToken,
    );
    final dashboard = data['trainerDashboard'];
    if (dashboard is! Map<String, dynamic>) {
      throw const FormatException('trainerDashboard');
    }
    return dashboard;
  }
}
