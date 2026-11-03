import 'package:flutter/foundation.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import '../domain/routine_builder_models.dart';

class RoutineAssignmentController extends ChangeNotifier {
  RoutineAssignmentController({
    required this.assignWorkout,
    this.notifications,
    bool Function()? isCurrentAccount,
  }) : _isCurrent = isCurrentAccount ?? (() => true);
  final AssignWorkoutUseCase assignWorkout;
  final NotificationsRepository? notifications;
  final bool Function() _isCurrent;
  final Map<String, ConfirmedRoutineTarget> confirmed = {};
  bool publishing = false, _disposed = false;
  WorkoutErrorCode? error;
  NotificationErrorCode? notificationError;
  bool get _active => !_disposed && _isCurrent();
  Future<void> publish(
    RoutineDraft routine,
    List<AssignableClient> clients,
    DateTime date,
  ) async {
    if (publishing || !_active) return;
    publishing = true;
    error = null;
    notificationError = null;
    notifyListeners();
    try {
      for (final client in clients) {
        if (!_active) return;
        if (confirmed.containsKey(client.userId)) continue;
        final result = await assignWorkout(
          routine.toCommand(userId: client.userId, startDate: date),
        );
        if (!_active) return;
        if (result.userId != client.userId || result.routineId.isEmpty) {
          throw const WorkoutException(WorkoutErrorCode.invalidResponse);
        }
        final target = ConfirmedRoutineTarget(
          routineId: result.routineId,
          clientId: client.id,
          clientName: client.name,
          routineName: result.name,
        );
        confirmed[client.userId] = target;
        notifyListeners();
        // El fallo de la notificación nunca convierte la asignación en fallida.
        try {
          await notifications?.rememberConfirmed(target);
        } on NotificationException catch (e) {
          if (_active) notificationError = e.code;
        }
        if (!_active) return;
      }
    } on WorkoutException catch (e) {
      if (_active) error = e.code;
    } on Object {
      if (_active) error = WorkoutErrorCode.unexpected;
    } finally {
      if (_active) {
        publishing = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
