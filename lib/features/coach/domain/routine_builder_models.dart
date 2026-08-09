import 'coach_dashboard_data.dart';

class RoutineDraft {
  const RoutineDraft({
    this.id = '',
    required this.name,
    required this.durationWeeks,
    required this.days,
  });

  static const int minimumExercisesPerDay = 3;
  static const int minimumDurationWeeks = 4;

  final String id;
  final String name;
  final int durationWeeks;
  final List<RoutineDayDraft> days;

  int get totalExercises =>
      days.fold(0, (total, day) => total + day.exercises.length);

  bool get hasMinimumDuration => durationWeeks >= minimumDurationWeeks;

  bool get isWeeklyRoutineComplete =>
      days.isNotEmpty &&
      days.every((day) => day.exercises.length >= minimumExercisesPerDay);

  List<RoutineDayDraft> get daysBelowMinimumExercises => days
      .where((day) => day.exercises.length < minimumExercisesPerDay)
      .toList(growable: false);

  List<String> get focusTags {
    final tags = <String>{};
    for (final day in days) {
      if (day.focus.trim().isNotEmpty) {
        tags.add(day.focus.trim());
      }
      for (final exercise in day.exercises) {
        if (exercise.focus.trim().isNotEmpty) {
          tags.add(exercise.focus.trim());
        }
      }
    }
    return tags.toList(growable: false);
  }
}

class RoutineDayDraft {
  const RoutineDayDraft({
    required this.label,
    required this.focus,
    required this.exercises,
  });

  final String label;
  final String focus;
  final List<RoutineExerciseDraft> exercises;

  String get title => '$label - $focus';
}

class RoutineExerciseDraft {
  const RoutineExerciseDraft({
    required this.id,
    required this.name,
    required this.focus,
    required this.series,
    required this.repetitions,
    required this.weight,
    required this.rest,
  });

  final String id;
  final String name;
  final String focus;
  final String series;
  final String repetitions;
  final String weight;
  final String rest;

  RoutineExerciseDraft copyWith({
    String? name,
    String? focus,
    String? series,
    String? repetitions,
    String? weight,
    String? rest,
  }) {
    return RoutineExerciseDraft(
      id: id,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      series: series ?? this.series,
      repetitions: repetitions ?? this.repetitions,
      weight: weight ?? this.weight,
      rest: rest ?? this.rest,
    );
  }
}

class AssignRoutineArgs {
  const AssignRoutineArgs({
    this.routine,
    this.preselectedClients = const [],
  });

  final RoutineDraft? routine;
  final List<CoachClient> preselectedClients;
}
