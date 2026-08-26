import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_clients/src/infrastructure/datasources/my_trainers_graphql_data_source.dart';
import 'package:test/test.dart';

void main() {
  test(
    'consulta entrenadores asignados y devuelve el perfil con campos obligatorios',
    () async {
      final client = _FakeGraphQlClient({
        'myTrainers': [
          {
            'user': 'ana_trainer',
            'name': 'Ana Trainer',
            'email': 'ana@gymsas.test',
            'plan': 'FREE',
            'status': 'ACTIVE',
            'profile': {
              'bio': 'Entrenadora de fuerza',
              'certifications': ['NSCA'],
              'experience': 3,
            },
          },
        ],
      });
      final dataSource = MyTrainersGraphQlDataSource(client);

      final result = await dataSource.getTrainers(accessToken: 'access-token');
      final trainer = result.single.toDomain();

      expect(client.document, contains('myTrainers'));
      expect(client.accessToken, 'access-token');
      expect(client.accessToken, isNotEmpty);
      expect(trainer.user, 'ana_trainer');
      expect(trainer.email, 'ana@gymsas.test');
      expect(trainer.initials, 'AT');
      expect(trainer.plan, 'FREE');
      expect(trainer.status, 'ACTIVE');
      expect(trainer.bio, 'Entrenadora de fuerza');
      expect(trainer.certifications, ['NSCA']);
      expect(trainer.experience, 3);
    },
  );

  test('acepta perfil de entrenador sin email', () async {
    final client = _FakeGraphQlClient({
      'myTrainers': [
        {
          'user': 'sin_email',
          'name': 'Sin Email',
          'email': null,
          'plan': 'FREE',
          'status': 'ACTIVE',
          'profile': {
            'bio': 'Entrenador',
            'certifications': <String>[],
            'experience': 1,
          },
        },
      ],
    });
    final dataSource = MyTrainersGraphQlDataSource(client);

    final result = await dataSource.getTrainers(accessToken: 'access-token');
    final trainer = result.single.toDomain();

    expect(trainer.email, isEmpty);
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
