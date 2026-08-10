import 'exercise_catalog_item.dart';

class ExerciseCatalogPage {
  const ExerciseCatalogPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
  });

  final List<ExerciseCatalogItem> items;
  final int page;
  final int size;
  final int total;
  final int totalPages;

  bool get hasNextPage => page + 1 < totalPages;
}
