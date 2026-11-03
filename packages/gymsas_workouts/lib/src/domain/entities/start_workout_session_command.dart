class StartWorkoutSessionCommand {
  const StartWorkoutSessionCommand({
    required this.routineId,
    required this.scheduledDay,
    this.userId,
    this.clientRequestId,
    this.startedAt,
  });

  final String routineId;
  final String scheduledDay;
  final String? userId;
  final String? clientRequestId;
  final DateTime? startedAt;
}
