import 'localized_value.dart';

class ExerciseCatalogItem {
  const ExerciseCatalogItem({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.images,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    this.category,
  });

  final String id;
  final String exerciseId;
  final LocalizedValue name;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final LocalizedStringList instructions;
  final String? category;
  final List<String> images;
}
