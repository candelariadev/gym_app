class ExerciseCatalogRequest {
  const ExerciseCatalogRequest({
    this.search,
    this.level,
    this.category,
    this.equipment,
    this.muscle,
    this.page = 0,
    this.size = 20,
  });

  final String? search;
  final String? level;
  final String? category;
  final String? equipment;
  final String? muscle;
  final int page;
  final int size;

  ExerciseCatalogRequest copyWith({
    String? search,
    String? level,
    String? category,
    String? equipment,
    String? muscle,
    int? page,
    int? size,
    bool clearSearch = false,
    bool clearLevel = false,
    bool clearCategory = false,
    bool clearEquipment = false,
    bool clearMuscle = false,
  }) {
    return ExerciseCatalogRequest(
      search: clearSearch ? null : search ?? this.search,
      level: clearLevel ? null : level ?? this.level,
      category: clearCategory ? null : category ?? this.category,
      equipment: clearEquipment ? null : equipment ?? this.equipment,
      muscle: clearMuscle ? null : muscle ?? this.muscle,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }
}
