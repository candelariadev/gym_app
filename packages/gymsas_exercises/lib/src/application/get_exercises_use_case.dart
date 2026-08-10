import '../domain/entities/exercise_catalog_page.dart';
import '../domain/entities/exercise_catalog_request.dart';
import '../domain/ports/exercise_catalog_repository.dart';

class GetExercisesUseCase {
  const GetExercisesUseCase(this._repository);

  final ExerciseCatalogRepository _repository;

  Future<ExerciseCatalogPage> call(ExerciseCatalogRequest request) {
    final normalized = ExerciseCatalogRequest(
      search: _normalize(request.search),
      level: _normalize(request.level),
      category: _normalize(request.category),
      equipment: _normalize(request.equipment),
      muscle: _normalize(request.muscle),
      page: request.page < 0 ? 0 : request.page,
      size: request.size.clamp(1, 50).toInt(),
    );
    return _repository.getPage(normalized);
  }

  String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
