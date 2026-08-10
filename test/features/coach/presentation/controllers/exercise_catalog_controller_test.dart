import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/coach/presentation/controllers/exercise_catalog_controller.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

void main() {
  test('pagina en servidor y acumula resultados sin duplicarlos', () async {
    final repository = _FakeRepository();
    final controller = ExerciseCatalogController(
      getExercises: GetExercisesUseCase(repository),
      pageSize: 1,
      searchDebounce: Duration.zero,
    );

    await controller.loadInitial();
    await controller.loadMore();

    expect(controller.items.map((item) => item.id), ['1', '2']);
    expect(controller.total, 2);
    expect(controller.hasMore, isFalse);
    controller.dispose();
  });

  test(
    'search reinicia la pagina y se envia junto con la paginacion',
    () async {
      final repository = _FakeRepository();
      final controller = ExerciseCatalogController(
        getExercises: GetExercisesUseCase(repository),
        searchDebounce: Duration.zero,
      );
      await controller.loadInitial();

      controller.updateSearch('  press  ');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.lastRequest?.search, 'press');
      expect(repository.lastRequest?.page, 0);
      controller.dispose();
    },
  );
}

class _FakeRepository implements ExerciseCatalogRepository {
  ExerciseCatalogRequest? lastRequest;

  @override
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request) async {
    lastRequest = request;
    final id = '${request.page + 1}';
    return ExerciseCatalogPage(
      items: [
        ExerciseCatalogItem(
          id: id,
          exerciseId: 'exercise-$id',
          name: LocalizedValue(en: 'Exercise $id', es: 'Ejercicio $id'),
          primaryMuscles: const ['chest'],
          secondaryMuscles: const [],
          instructions: const LocalizedStringList(),
          images: const [],
        ),
      ],
      page: request.page,
      size: request.size,
      total: 2,
      totalPages: 2,
    );
  }
}
