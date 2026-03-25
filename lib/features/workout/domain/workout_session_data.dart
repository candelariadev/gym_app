class WorkoutExercise {
  const WorkoutExercise({
    required this.order,
    required this.name,
    required this.focus,
    required this.seriesCount,
    required this.repetitionRange,
    this.isCompleted = false,
  });

  final int order;
  final String name;
  final String focus;
  final int seriesCount;
  final String repetitionRange;
  final bool isCompleted;
}

class WorkoutSessionData {
  const WorkoutSessionData({
    required this.routineName,
    required this.dayTitle,
    required this.estimatedDurationMinutes,
    required this.totalSeries,
    required this.exercises,
  });

  final String routineName;
  final String dayTitle;
  final int estimatedDurationMinutes;
  final int totalSeries;
  final List<WorkoutExercise> exercises;

  int get totalExercises => exercises.length;

  int get completedExercises =>
      exercises.where((exercise) => exercise.isCompleted).length;

  WorkoutExercise get currentExercise =>
      exercises.firstWhere((exercise) => !exercise.isCompleted);

  static const mock = WorkoutSessionData(
    routineName: 'Rutina Full Body',
    dayTitle: 'Dia 2 - Espalda y Biceps',
    estimatedDurationMinutes: 45,
    totalSeries: 16,
    exercises: [
      WorkoutExercise(
        order: 1,
        name: 'Jalon al pecho',
        focus: 'Espalda',
        seriesCount: 4,
        repetitionRange: '10 - 12',
      ),
      WorkoutExercise(
        order: 2,
        name: 'Remo con barra',
        focus: 'Espalda',
        seriesCount: 4,
        repetitionRange: '6 - 8',
      ),
      WorkoutExercise(
        order: 3,
        name: 'Dominadas asistidas',
        focus: 'Espalda',
        seriesCount: 3,
        repetitionRange: '8 - 10',
      ),
      WorkoutExercise(
        order: 4,
        name: 'Curl de Biceps',
        focus: 'Espalda',
        seriesCount: 3,
        repetitionRange: '10 - 12',
      ),
    ],
  );
}

class WorkoutExerciseArgs {
  const WorkoutExerciseArgs({
    required this.session,
    required this.exerciseIndex,
  });

  final WorkoutSessionData session;
  final int exerciseIndex;
}
