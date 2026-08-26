import 'package:gymsas_exercises/gymsas_exercises.dart';

import '../domain/workout_exercise_metadata.dart';

class WorkoutExerciseMetadataResolver {
  WorkoutExerciseMetadataResolver({
    required GetExercisesUseCase getExercisesUseCase,
    String? exerciseImageBaseUrl,
  })  : _getExercisesUseCase = getExercisesUseCase,
        _exerciseImageBaseUrl = _normalizeImageBaseUrl(exerciseImageBaseUrl);

  final GetExercisesUseCase _getExercisesUseCase;
  final Uri? _exerciseImageBaseUrl;

  final Map<String, WorkoutExerciseMetadata> _cache = {};

  Future<Map<String, WorkoutExerciseMetadata>> resolve(Set<String> exerciseIds) async {
    final ids = _normalizeIds(exerciseIds);
    if (ids.isEmpty) {
      return const {};
    }

    final missingIds = ids.where((id) => !_cache.containsKey(id)).toList(growable: false);
    await Future.wait(
      missingIds.map(_loadMetadataById),
      eagerError: false,
    );

    final found = <String, WorkoutExerciseMetadata>{};
    for (final id in ids) {
      final value = _cache[id];
      if (value != null) {
        found[id] = value;
      }
    }
    return found;
  }

  Set<String> _normalizeIds(Set<String> raw) => raw
      .map((id) => id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();

  Future<void> _loadMetadataById(String exerciseId) async {
    try {
      final query = await _getExercisesUseCase(
        ExerciseCatalogRequest(
          search: exerciseId,
          size: 10,
          page: 0,
        ),
      );

      final matches = query.items
          .where(
            (item) =>
                (item.exerciseId.trim().toLowerCase() == exerciseId) ||
                (item.id.trim().toLowerCase() == exerciseId),
          )
          .toList(growable: false);
      if (matches.isEmpty) return;

      final matched = matches.first;

      _cache[exerciseId] = WorkoutExerciseMetadata(
        exerciseId: exerciseId,
        displayName: _localizedName(matched),
        notes: _firstNote(matched),
        imageUrl: _firstImage(matched),
        force: _normalizedMetadataField(matched.force),
        level: _normalizedMetadataField(matched.level),
        mechanic: _normalizedMetadataField(matched.mechanic),
        equipment: _normalizedMetadataField(matched.equipment),
        category: _normalizedMetadataField(matched.category),
        primaryMuscles: _nonEmptyValues(matched.primaryMuscles),
        secondaryMuscles: _nonEmptyValues(matched.secondaryMuscles),
        instructions: _instructions(matched),
      );
    } on Object {
      // Resolver intentionally fails open: if catalog fails, the workout flow should continue.
      return;
    }
  }

  String? _localizedName(ExerciseCatalogItem item) {
    if (item.name.es?.trim().isNotEmpty == true) return item.name.es;
    if (item.name.en?.trim().isNotEmpty == true) return item.name.en;
    return null;
  }

  String? _firstNote(ExerciseCatalogItem item) {
    final first = item.instructions.resolve('es');
    if (first.isNotEmpty) return first.first;
    final fallback = item.instructions.resolve('en');
    return fallback.isNotEmpty ? fallback.first : null;
  }

  List<String> _instructions(ExerciseCatalogItem item) {
    return _nonEmptyValues(item.instructions.resolve('es').isNotEmpty
        ? item.instructions.resolve('es')
        : item.instructions.resolve('en'));
  }

  List<String> _nonEmptyValues(List<String> values) =>
      values.where((value) => value.trim().isNotEmpty).toList(growable: false);

  String? _normalizedMetadataField(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _firstImage(ExerciseCatalogItem item) {
    if (item.images.isEmpty) return null;

    final first = item.images.first.trim();
    if (first.isEmpty) return null;

    final isAbsoluteHttp = first.startsWith('http://') || first.startsWith('https://');
    if (isAbsoluteHttp) {
      return first;
    }

    if (_exerciseImageBaseUrl == null) {
      return null;
    }

    final normalizedPath = first.startsWith('/') ? first : '/$first';
    return _exerciseImageBaseUrl.resolve(normalizedPath).toString();
  }

  static Uri? _normalizeImageBaseUrl(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || !parsed.hasAuthority) {
      return null;
    }

    final path = parsed.path;
    if (path.endsWith('/graphql')) {
      final withoutGraphQl = path.substring(0, path.length - '/graphql'.length);
      return parsed.replace(path: withoutGraphQl.isEmpty ? '/' : withoutGraphQl);
    }

    return parsed;
  }
}
