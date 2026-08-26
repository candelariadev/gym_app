enum WorkoutSessionStatus {
  inProgress('IN_PROGRESS'),
  paused('PAUSED'),
  completed('COMPLETED'),
  abandoned('ABANDONED'),
  unknown('UNKNOWN');

  const WorkoutSessionStatus(this.value);

  final String value;

  static WorkoutSessionStatus fromString(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    return switch (normalized) {
      'IN_PROGRESS' => WorkoutSessionStatus.inProgress,
      'PAUSED' => WorkoutSessionStatus.paused,
      'COMPLETED' => WorkoutSessionStatus.completed,
      'ABANDONED' => WorkoutSessionStatus.abandoned,
      _ => WorkoutSessionStatus.unknown,
    };
  }
}
