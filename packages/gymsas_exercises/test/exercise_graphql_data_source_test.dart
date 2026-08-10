import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_exercises/src/domain/entities/exercise_catalog_request.dart';
import 'package:gymsas_exercises/src/infrastructure/datasources/exercise_graphql_data_source.dart';
import 'package:test/test.dart';

void main() {
  test('envia search, filtros, paginacion y bearer token', () async {
    final client = _FakeGraphQlClient({
      'exercises': {
        'content': [
          {
            'id': 'mongo-id',
            'exerciseId': 'bench-press',
            'name': {'en': 'Bench Press', 'es': 'Press de banca'},
            'force': 'push',
            'level': 'intermediate',
            'mechanic': 'compound',
            'equipment': 'barbell',
            'primaryMuscles': ['chest'],
            'secondaryMuscles': ['triceps'],
            'instructions': {
              'en': ['Press'],
              'es': ['Empuja'],
            },
            'category': 'strength',
            'images': <String>[],
          },
        ],
        'page': 1,
        'size': 20,
        'total': 22,
        'totalPages': 2,
      },
    });
    final dataSource = ExerciseGraphQlDataSource(client);

    final page = await dataSource.getPage(
      request: const ExerciseCatalogRequest(
        search: 'press',
        equipment: 'barbell',
        page: 1,
      ),
      accessToken: 'access-token',
    );

    expect(client.accessToken, 'access-token');
    expect(client.variables?['search'], 'press');
    expect(client.variables?['equipment'], 'barbell');
    expect(client.variables?['page'], 1);
    expect(client.document, contains(r'$search: String'));
    expect(page.toDomain().items.single.name.resolve('es'), 'Press de banca');
    expect(page.toDomain().hasNextPage, isFalse);
  });
}

class _FakeGraphQlClient implements GraphQlClient {
  _FakeGraphQlClient(this.response);

  final Map<String, dynamic> response;
  String? document;
  Map<String, dynamic>? variables;
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
    this.variables = variables;
    this.accessToken = accessToken;
    return response;
  }
}
