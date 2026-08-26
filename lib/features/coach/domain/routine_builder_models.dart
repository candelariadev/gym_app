import 'package:gymsas_workouts/gymsas_workouts.dart';

class RoutineDraft {
  const RoutineDraft({
    required this.name,
    required this.durationWeeks,
    required this.days,
  });

  static const int minimumExercisesPerDay = 3;
  static const int minimumDurationWeeks = 4;
  static const int maximumDurationWeeks = 52;

  final String name;
  final int durationWeeks;
  final List<RoutineDayDraft> days;

  int get totalExercises =>
      days.fold(0, (total, day) => total + day.exercises.length);

  bool get hasValidDuration =>
      durationWeeks >= minimumDurationWeeks &&
      durationWeeks <= maximumDurationWeeks;

  List<RoutineDayDraft> get daysBelowMinimumExercises => days
      .where((day) => day.exercises.length < minimumExercisesPerDay)
      .toList(growable: false);

  AssignWorkoutCommand toCommand({
    required String userId,
    required DateTime startDate,
  }) => AssignWorkoutCommand(
    userId: userId,
    name: name.trim(),
    startDate: startDate,
    durationWeeks: durationWeeks,
    days: days
        .map(
          (day) => WorkoutDayPlan(
            day: day.day,
            exercises: day.exercises
                .map(
                  (exercise) => WorkoutExercise(
                    exerciseId: exercise.exerciseId,
                    name: exercise.name,
                    sets: exercise.sets,
                    reps: exercise.reps,
                    restSeconds: exercise.restSeconds,
                    notes: exercise.notes,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false),
  );
}

class RoutineDayDraft {
  const RoutineDayDraft({required this.day, required this.exercises});

  final WorkoutDay day;
  final List<RoutineExerciseDraft> exercises;

  RoutineDayDraft copyWith({List<RoutineExerciseDraft>? exercises}) =>
      RoutineDayDraft(day: day, exercises: exercises ?? this.exercises);
}

class RoutineExerciseDraft {
  const RoutineExerciseDraft({
    required this.exerciseId,
    required this.name,
    required this.focus,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
  });

  final String exerciseId;
  final String name;
  final String focus;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  RoutineExerciseDraft copyWith({
    int? sets,
    int? reps,
    int? restSeconds,
    String? notes,
  }) => RoutineExerciseDraft(
    exerciseId: exerciseId,
    name: name,
    focus: focus,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    restSeconds: restSeconds ?? this.restSeconds,
    notes: notes ?? this.notes,
  );
}

class AssignRoutineArgs {
  const AssignRoutineArgs({this.routine, this.preselectedClients = const []});

  final RoutineDraft? routine;
  final List<AssignableClient> preselectedClients;
}

class AssignableClient {
  const AssignableClient({
    required this.id,
    required this.userId,
    required this.name,
  });

  final String id;
  final String userId;
  final String name;
}
