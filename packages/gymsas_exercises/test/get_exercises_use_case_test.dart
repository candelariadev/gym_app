import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:test/test.dart';

void main() {
  test('normaliza filtros y limita la paginacion', () async {
    final repository = _CapturingRepository();
    final useCase = GetExercisesUseCase(repository);

    await useCase(
      const ExerciseCatalogRequest(search: '  press  ', page: -2, size: 100),
    );

    expect(repository.request?.search, 'press');
    expect(repository.request?.page, 0);
    expect(repository.request?.size, 50);
  });

  test('resuelve contenido bilingue con fallback', () {
    const value = LocalizedValue(en: 'Bench Press');
    expect(value.resolve('es'), 'Bench Press');
    expect(value.resolve('en'), 'Bench Press');
  });
}

class _CapturingRepository implements ExerciseCatalogRepository {
  ExerciseCatalogRequest? request;

  @override
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request) async {
    this.request = request;
    return const ExerciseCatalogPage(
      items: [],
      page: 0,
      size: 20,
      total: 0,
      totalPages: 0,
    );
  }
}
