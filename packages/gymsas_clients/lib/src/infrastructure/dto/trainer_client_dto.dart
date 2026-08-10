import '../../domain/entities/assigned_trainer.dart';
import '../../domain/entities/assigned_workout.dart';
import '../../domain/entities/trainer_client.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_day_plan.dart';
import '../../domain/entities/workout_day.dart';

class TrainerClientDto {
  const TrainerClientDto(this._json);

  factory TrainerClientDto.fromJson(Map<String, dynamic> json) =>
      TrainerClientDto(json);

  final Map<String, dynamic> _json;

  TrainerClient toDomain() => TrainerClient(
    id: _requiredString('id'),
    ownerId: _requiredString('ownerId'),
    name: _requiredString('name'),
    email: _optionalString(_json['email']),
    birthdate: _date(_json['birthdate']),
    gender: _optionalString(_json['gender']),
    weight: (_json['weight'] as num?)?.toDouble(),
    goals: _strings(_json['goals']),
    notes: _optionalString(_json['notes']),
    user: _requiredString('user'),
    assignedTrainers: _maps(
      'assignedTrainers',
    ).map(_trainer).toList(growable: false),
    assignedWorkouts: _maps(
      'assignedWorkouts',
    ).map(_workout).toList(growable: false),
    status: _requiredString('status'),
    createdAt: _date(_json['createdAt']),
    updatedAt: _date(_json['updatedAt']),
  );

  String _requiredString(String key) {
    final value = _json[key];
    if (value is! String || value.trim().isEmpty) throw FormatException(key);
    return value;
  }

  List<Map<String, dynamic>> _maps(String key) {
    final value = _json[key];
    if (value is! List) throw FormatException(key);
    return value
        .map((item) {
          if (item is! Map<String, dynamic>) throw FormatException(key);
          return item;
        })
        .toList(growable: false);
  }

  AssignedTrainer _trainer(Map<String, dynamic> json) => AssignedTrainer(
    userId: _required(json, 'userId'),
    assignedAt: _date(json['assignedAt']),
  );

  AssignedWorkout _workout(Map<String, dynamic> json) {
    return AssignedWorkout(
      routineId: _required(json, 'routineId'),
      ownerId: _required(json, 'ownerId'),
      callerId: _required(json, 'callerId'),
      userId: _required(json, 'userId'),
      name: _required(json, 'name'),
      days: _nestedMaps(json, 'days').map(_day).toList(growable: false),
      startDate: _date(json['startDate']),
      durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
      notes: _optionalString(json['notes']),
      status: _required(json, 'status'),
      createdAt: _date(json['createdAt']),
    );
  }

  WorkoutDayPlan _day(Map<String, dynamic> json) {
    final day = WorkoutDay.tryParse(json['day']);
    if (day == null) throw const FormatException('day');
    return WorkoutDayPlan(
      day: day,
      exercises: _nestedMaps(
        json,
        'exercises',
      ).map(_exercise).toList(growable: false),
    );
  }

  WorkoutExercise _exercise(Map<String, dynamic> json) => WorkoutExercise(
    exerciseId: _required(json, 'exerciseId'),
    sets: (json['sets'] as num?)?.toInt(),
    reps: (json['reps'] as num?)?.toInt(),
    restSeconds: (json['restSeconds'] as num?)?.toInt(),
    notes: _optionalString(json['notes']),
  );

  static String _required(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) throw FormatException(key);
    return value;
  }

  static List<Map<String, dynamic>> _nestedMaps(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List) throw FormatException(key);
    return value
        .map((item) {
          if (item is! Map<String, dynamic>) throw FormatException(key);
          return item;
        })
        .toList(growable: false);
  }

  static List<String> _strings(Object? raw) {
    if (raw is! List) throw const FormatException('list');
    return raw
        .map((value) {
          if (value is! String) throw const FormatException('string');
          return value;
        })
        .toList(growable: false);
  }

  static String? _optionalString(Object? raw) =>
      raw is String && raw.trim().isNotEmpty ? raw : null;

  static DateTime? _date(Object? raw) {
    if (raw == null) return null;
    if (raw is! String) throw const FormatException('date');
    return DateTime.tryParse(raw) ?? (throw const FormatException('date'));
  }
}
