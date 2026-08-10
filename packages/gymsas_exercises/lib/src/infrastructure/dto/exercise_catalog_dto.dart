import '../../domain/entities/exercise_catalog_item.dart';
import '../../domain/entities/exercise_catalog_page.dart';
import '../../domain/entities/localized_value.dart';

class ExerciseCatalogPageDto {
  const ExerciseCatalogPageDto({
    required this.content,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
  });

  factory ExerciseCatalogPageDto.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    if (rawContent is! List) throw const FormatException('content');
    return ExerciseCatalogPageDto(
      content: rawContent
          .map((item) => ExerciseCatalogItemDto.fromJson(_map(item)))
          .toList(growable: false),
      page: _integer(json['page']),
      size: _integer(json['size']),
      total: _integer(json['total']),
      totalPages: _integer(json['totalPages']),
    );
  }

  final List<ExerciseCatalogItemDto> content;
  final int page;
  final int size;
  final int total;
  final int totalPages;

  ExerciseCatalogPage toDomain() => ExerciseCatalogPage(
    items: content.map((item) => item.toDomain()).toList(growable: false),
    page: page,
    size: size,
    total: total,
    totalPages: totalPages,
  );
}

class ExerciseCatalogItemDto {
  const ExerciseCatalogItemDto({
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

  factory ExerciseCatalogItemDto.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final instructions = json['instructions'];
    return ExerciseCatalogItemDto(
      id: _requiredString(json['id'], 'id'),
      exerciseId: _requiredString(json['exerciseId'], 'exerciseId'),
      name: LocalizedValueDto.fromJson(_map(name)),
      force: _string(json['force']),
      level: _string(json['level']),
      mechanic: _string(json['mechanic']),
      equipment: _string(json['equipment']),
      primaryMuscles: _strings(json['primaryMuscles']),
      secondaryMuscles: _strings(json['secondaryMuscles']),
      instructions: LocalizedStringListDto.fromJson(_map(instructions)),
      category: _string(json['category']),
      images: _strings(json['images']),
    );
  }

  final String id;
  final String exerciseId;
  final LocalizedValueDto name;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final LocalizedStringListDto instructions;
  final String? category;
  final List<String> images;

  ExerciseCatalogItem toDomain() => ExerciseCatalogItem(
    id: id,
    exerciseId: exerciseId,
    name: name.toDomain(),
    force: force,
    level: level,
    mechanic: mechanic,
    equipment: equipment,
    primaryMuscles: List.unmodifiable(primaryMuscles),
    secondaryMuscles: List.unmodifiable(secondaryMuscles),
    instructions: instructions.toDomain(),
    category: category,
    images: List.unmodifiable(images),
  );
}

class LocalizedValueDto {
  const LocalizedValueDto({this.en, this.es});

  factory LocalizedValueDto.fromJson(Map<String, dynamic> json) =>
      LocalizedValueDto(en: _string(json['en']), es: _string(json['es']));

  final String? en;
  final String? es;

  LocalizedValue toDomain() => LocalizedValue(en: en, es: es);
}

class LocalizedStringListDto {
  const LocalizedStringListDto({required this.en, required this.es});

  factory LocalizedStringListDto.fromJson(Map<String, dynamic> json) =>
      LocalizedStringListDto(
        en: _strings(json['en']),
        es: _strings(json['es']),
      );

  final List<String> en;
  final List<String> es;

  LocalizedStringList toDomain() => LocalizedStringList(en: en, es: es);
}

Map<String, dynamic> _map(Object? value) {
  if (value == null) return const {};
  if (value is Map<String, dynamic>) return value;
  throw const FormatException('map');
}

String _requiredString(Object? value, String field) {
  final result = _string(value);
  if (result == null || result.isEmpty) throw FormatException(field);
  return result;
}

String? _string(Object? value) => value is String ? value : null;

int _integer(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const FormatException('integer');
}

List<String> _strings(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const [];
