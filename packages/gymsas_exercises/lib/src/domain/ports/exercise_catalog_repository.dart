import '../entities/exercise_catalog_page.dart';
import '../entities/exercise_catalog_request.dart';

abstract interface class ExerciseCatalogRepository {
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request);
}
