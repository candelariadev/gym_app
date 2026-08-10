import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_clients/src/infrastructure/datasources/trainer_clients_graphql_data_source.dart';
import 'package:test/test.dart';

void main() {
  test('consulta clientes con sus rutinas y envia el bearer token', () async {
    final client = _FakeGraphQlClient({
      'clients': [
        {
          'id': 'client-1',
          'ownerId': 'gym-1',
          'name': 'Kevin',
          'email': 'kevin@example.com',
          'birthdate': '1990-04-03',
          'gender': 'MALE',
          'weight': 82,
          'goals': ['strength'],
          'notes': null,
          'user': 'kevin',
          'status': 'ACTIVE',
          'createdAt': '2026-01-02T10:00:00Z',
          'updatedAt': null,
          'assignedTrainers': [
            {'userId': 'trainer-1', 'assignedAt': '2026-01-02T10:00:00Z'},
          ],
          'assignedWorkouts': [
            {
              'routineId': '550e8400-e29b-41d4-a716-446655440000',
              'ownerId': 'gym-1',
              'callerId': 'trainer-1',
              'userId': 'kevin',
              'name': 'Upper body',
              'days': [
                {
                  'day': 'MONDAY',
                  'exercises': [
                    {
                      'exerciseId': 'bench-press',
                      'sets': 4,
                      'reps': 8,
                      'restSeconds': 90,
                      'notes': null,
                    },
                  ],
                },
                {
                  'day': 'TUESDAY',
                  'exercises': [
                    {
                      'exerciseId': 'bench-press',
                      'sets': 3,
                      'reps': 10,
                      'restSeconds': 60,
                      'notes': null,
                    },
                  ],
                },
              ],
              'startDate': '2026-08-10',
              'durationWeeks': 4,
              'notes': null,
              'status': 'ACTIVE',
              'createdAt': '2026-01-03T10:00:00Z',
            },
          ],
        },
      ],
    });
    final dataSource = TrainerClientsGraphQlDataSource(client);

    final result = await dataSource.getClients(accessToken: 'access-token');
    final domain = result.single.toDomain();

    expect(client.accessToken, 'access-token');
    expect(client.document, contains('assignedWorkouts'));
    expect(domain.name, 'Kevin');
    expect(domain.assignedWorkouts.single.days, hasLength(2));
    expect(domain.assignedWorkouts.single.days.first.exercises.single.sets, 4);
    expect(
      domain.assignedWorkouts.single.days.last.exercises.single.exerciseId,
      'bench-press',
    );
    expect(domain.assignedWorkouts.single.totalExercises, 2);
    expect(domain.assignedWorkouts.single.durationWeeks, 4);
  });

  test('acepta clientes sin email', () async {
    final client = _FakeGraphQlClient({
      'clients': [
        {
          'id': 'client-1',
          'ownerId': 'gym-1',
          'name': 'Kevin',
          'email': null,
          'birthdate': null,
          'gender': 'MALE',
          'weight': 80,
          'goals': ['competition'],
          'notes': 'knee pain',
          'user': 'kevin_568eba',
          'status': 'ACTIVE',
          'createdAt': null,
          'updatedAt': null,
          'assignedTrainers': [
            {'userId': 'kevintrainer_8efc45', 'assignedAt': null},
          ],
          'assignedWorkouts': <Map<String, dynamic>>[],
        },
      ],
    });

    final result = await TrainerClientsGraphQlDataSource(
      client,
    ).getClients(accessToken: 'access-token');

    expect(result.single.toDomain().email, isNull);
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
