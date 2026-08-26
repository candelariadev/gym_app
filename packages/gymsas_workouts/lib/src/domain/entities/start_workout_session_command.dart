class StartWorkoutSessionCommand {
  const StartWorkoutSessionCommand({
    required this.routineId,
    required this.scheduledDay,
    this.userId,
  });

  final String routineId;
  final String scheduledDay;
  final String? userId;
}
