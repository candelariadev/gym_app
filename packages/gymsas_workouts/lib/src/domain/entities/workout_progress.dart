enum ProgressGranularity { day, week, month }

enum ProgressMetric {
  sets,
  repetitions,
  weight,
  volume,
  sessions,
  trainingDays,
}

class ProgressPoint {
  const ProgressPoint({
    required this.date,
    required this.completedSets,
    required this.repetitions,
    this.maxWeightKg,
    required this.volumeKg,
    required this.sessions,
    required this.trainingDays,
    required this.unrecordedSessions,
  });
  final DateTime date;
  final int completedSets,
      repetitions,
      sessions,
      trainingDays,
      unrecordedSessions;
  final double? maxWeightKg;
  final double volumeKg;

  double? value(ProgressMetric metric) => switch (metric) {
    ProgressMetric.sets => completedSets.toDouble(),
    ProgressMetric.repetitions => repetitions.toDouble(),
    ProgressMetric.weight => maxWeightKg,
    ProgressMetric.volume => volumeKg,
    ProgressMetric.sessions => sessions.toDouble(),
    ProgressMetric.trainingDays => trainingDays.toDouble(),
  };
}

class WorkoutProgress {
  const WorkoutProgress({
    required this.from,
    required this.to,
    this.earliestDate,
    required this.historyMonths,
    required this.points,
  });
  final DateTime from, to;
  final DateTime? earliestDate;
  final int historyMonths;
  final List<ProgressPoint> points;
}

class ProgressRequest {
  const ProgressRequest({
    required this.from,
    required this.to,
    required this.granularity,
    required this.timeZone,
    this.exerciseId,
  });
  final DateTime from, to;
  final ProgressGranularity granularity;
  final String timeZone;
  final String? exerciseId;
}

enum ProgressError {
  unauthorized,
  forbidden,
  conflict,
  historyNotAllowed,
  unavailable,
  invalidInput,
}

class ProgressException implements Exception {
  const ProgressException(this.code);
  final ProgressError code;
}
