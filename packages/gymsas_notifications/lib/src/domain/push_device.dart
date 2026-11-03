enum PushPermission { unsupported, notDetermined, denied, allowed }

class PushRoutineReference {
  const PushRoutineReference({
    required this.routineId,
    required this.notificationId,
  });
  final String routineId, notificationId;
}

abstract interface class PushDevice {
  bool get supported;
  Stream<String> get tokenChanges;
  Stream<PushRoutineReference> get opened;
  Stream<PushRoutineReference> get foreground;
  Future<PushPermission> permission();
  Future<PushPermission> requestPermission();
  Future<String?> token();
  Future<void> deleteToken();
  Future<PushRoutineReference?> initialMessage();
}
