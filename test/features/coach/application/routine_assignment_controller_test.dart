import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/coach/application/routine_assignment_controller.dart';
import 'package:gym_app/features/coach/domain/routine_builder_models.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import '../../../../packages/gymsas_notifications/test/support.dart';

class Workouts implements WorkoutRepository {
  final users = <String>[];
  Future<Workout> Function(AssignWorkoutCommand)? handler;
  @override
  Future<Workout> assign(AssignWorkoutCommand c) async {
    users.add(c.userId);
    return handler == null
        ? Workout(
            routineId: 'server-${c.userId}',
            userId: c.userId,
            name: c.name,
            status: 'ACTIVE',
          )
        : handler!(c);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

RoutineDraft draft() => RoutineDraft(
  name: 'Strength',
  durationWeeks: 4,
  days: [
    RoutineDayDraft(
      day: WorkoutDay.monday,
      exercises: List.generate(
        3,
        (i) => RoutineExerciseDraft(
          exerciseId: 'exercise-$i',
          name: 'Exercise',
          focus: '',
          sets: 3,
          reps: 10,
          restSeconds: 60,
        ),
      ),
    ),
  ],
);
const clients = [
  AssignableClient(id: 'client-id-1', userId: 'client1', name: 'Client 1'),
  AssignableClient(id: 'client-id-2', userId: 'client2', name: 'Client 2'),
];
void main() {
  test(
    'ofrece notificación sólo después del ACK del servidor y nunca la envía automáticamente',
    () async {
      final h = Harness(), remote = Workouts(), gate = Completer<Workout>();
      addTearDown(h.repo.dispose);
      remote.handler = (_) => gate.future;
      final c = RoutineAssignmentController(
        assignWorkout: AssignWorkoutUseCase(remote),
        notifications: h.repo,
      );
      addTearDown(c.dispose);
      final operation = c.publish(draft(), [
        clients.first,
      ], DateTime(2026, 10, 20));
      expect(c.confirmed, isEmpty);
      expect(await h.repo.history(), isEmpty);
      gate.complete(
        const Workout(
          routineId: 'server-routine',
          userId: 'client1',
          name: 'Strength',
          status: 'ACTIVE',
        ),
      );
      await operation;
      expect(c.confirmed.length, 1);
      expect(
        (await h.repo.history()).single.state,
        NotificationDeliveryState.ready,
      );
      expect(h.remote.notifyCalls, 0);
    },
  );
  test(
    'un fallo de almacenamiento de notificación no revierte la rutina',
    () async {
      final values = MemoryValues()..failWrites = true,
          h = Harness(values: values),
          remote = Workouts();
      addTearDown(h.repo.dispose);
      final c = RoutineAssignmentController(
        assignWorkout: AssignWorkoutUseCase(remote),
        notifications: h.repo,
      );
      addTearDown(c.dispose);
      await c.publish(draft(), [clients.first], DateTime(2026, 10, 20));
      expect(c.confirmed.length, 1);
      expect(c.error, isNull);
      expect(c.notificationError, NotificationErrorCode.storage);
      expect(remote.users, ['client1']);
    },
  );
  test(
    'reintentar una publicación parcial no vuelve a asignar clientes completados',
    () async {
      final h = Harness(), remote = Workouts();
      addTearDown(h.repo.dispose);
      var failed = false;
      remote.handler = (command) async {
        if (command.userId == 'client2' && !failed) {
          failed = true;
          throw const WorkoutException(WorkoutErrorCode.network);
        }
        return Workout(
          routineId: 'server-${command.userId}',
          userId: command.userId,
          name: command.name,
          status: 'ACTIVE',
        );
      };
      final c = RoutineAssignmentController(
        assignWorkout: AssignWorkoutUseCase(remote),
        notifications: h.repo,
      );
      addTearDown(c.dispose);
      await c.publish(draft(), clients, DateTime(2026, 10, 20));
      expect(c.confirmed.length, 1);
      expect(c.error, WorkoutErrorCode.network);
      await c.publish(draft(), clients, DateTime(2026, 10, 20));
      expect(c.confirmed.length, 2);
      expect(remote.users, ['client1', 'client2', 'client2']);
      expect(h.remote.notifyCalls, 0);
    },
  );
  test(
    'un ACK atrasado tras cambiar cuenta no habilita notificación en la nueva',
    () async {
      final h = Harness(), remote = Workouts(), gate = Completer<Workout>();
      addTearDown(h.repo.dispose);
      var current = true;
      remote.handler = (_) => gate.future;
      final c = RoutineAssignmentController(
        assignWorkout: AssignWorkoutUseCase(remote),
        notifications: h.repo,
        isCurrentAccount: () => current,
      );
      addTearDown(c.dispose);
      final operation = c.publish(draft(), [
        clients.first,
      ], DateTime(2026, 10, 20));
      current = false;
      gate.complete(
        const Workout(
          routineId: 'server-routine',
          userId: 'client1',
          name: 'Strength',
          status: 'ACTIVE',
        ),
      );
      await operation;
      expect(c.confirmed, isEmpty);
      expect(await h.repo.history(), isEmpty);
    },
  );
}
