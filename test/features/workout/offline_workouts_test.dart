import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_offline/gymsas_offline.dart';
import 'package:gymsas_offline/gymsas_offline_native.dart'
    show EncryptedFileOfflineValueStorage;
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:gym_app/features/workout/application/workout_session_store.dart';
import 'package:gym_app/features/workout/domain/workout_session_data.dart'
    as ui;
import 'package:gym_app/features/advised/presentation/controllers/my_progress_controller.dart';

void main() {
  test(
    'rutina validada desde push persiste sin perder entrenamientos pendientes',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymsas-push-cache-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final key = List.generate(32, (i) => i);
      final h = _Harness(EncryptedFileOfflineValueStorage(directory, key));
      await h.repo.synchronize();
      h.remote.online = false;
      final local = await h.repo.startWorkoutSession(_start);
      await h.repo.recordPerformance(_performance(local.id, 35));
      await h.repo.synchronize();
      final before = await h.store.read(_identity.scope);
      await h.store.update(
        _identity.scope,
        (d) => d['notifications'] = {'sentinel': true},
      );
      await h.repo.cacheConfirmedWorkout(
        _pushWorkout,
        expectedScope: _identity.scope,
      );
      final after = await h.store.read(_identity.scope);
      expect(after['outbox'], before['outbox']);
      expect(after['sessions'], before['sessions']);
      expect(after['notifications'], {'sentinel': true});
      h.repo.dispose();

      final reopened = _Harness(
        EncryptedFileOfflineValueStorage(directory, key),
      )..remote.online = false;
      addTearDown(reopened.repo.dispose);
      expect(
        (await reopened.repo.getMyWorkouts()).map((w) => w.routineId),
        containsAll(['routine', 'push-routine']),
      );
      expect(
        (await reopened.repo.getMyWorkoutSessions())
            .single
            .exercises
            .single
            .sets
            .single
            .weightKg,
        35,
      );
      for (final file in directory.listSync().whereType<File>()) {
        expect(await file.readAsString(), isNot(contains('Verified routine')));
      }
    },
  );

  test(
    'una consulta anterior no borra la rutina recién verificada desde push',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.workoutGate = Completer<List<Workout>>();
      h.remote.workoutEntered = Completer<void>();
      final syncing = h.repo.synchronize();
      await h.remote.workoutEntered!.future;
      await h.repo.cacheConfirmedWorkout(
        _pushWorkout,
        expectedScope: _identity.scope,
      );
      h.remote.workoutGate!.complete([_workout]);
      await syncing;
      final saved = await h.store.read(_identity.scope);
      expect(
        (saved['workouts'] as List).map((w) => w['id']),
        contains('push-routine'),
      );
    },
  );

  test(
    'abrir push exige acceso remoto y rechaza cambio de cuenta antes de persistir',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      final verify = GetConfirmedWorkoutUseCase(h.remote, cache: h.repo);
      await expectLater(
        verify('missing'),
        throwsA(
          isA<WorkoutException>().having(
            (e) => e.code,
            'code',
            WorkoutErrorCode.forbidden,
          ),
        ),
      );
      h.remote.workoutGate = Completer<List<Workout>>();
      h.remote.workoutEntered = Completer<void>();
      final verifying = verify('push-routine');
      await h.remote.workoutEntered!.future;
      h.identity = const OfflineIdentity(
        scope: 'another-account',
        ownerId: 'tenant-B',
        userId: 'user-B',
      );
      h.remote.workoutGate!.complete([_pushWorkout]);
      await expectLater(
        verifying,
        throwsA(
          isA<WorkoutException>().having(
            (e) => e.code,
            'code',
            WorkoutErrorCode.unauthorized,
          ),
        ),
      );
      expect((await h.store.read('another-account'))['workouts'], isNull);
      expect((await h.store.read(_identity.scope))['workouts'], isNull);
    },
  );

  test(
    'apertura validada guarda la rutina y falla de forma segura sin red',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      final verify = GetConfirmedWorkoutUseCase(h.remote, cache: h.repo);
      h.remote.workoutGate = Completer<List<Workout>>()
        ..complete([_pushWorkout]);
      expect((await verify('push-routine')).routineId, 'push-routine');
      h.remote.online = false;
      await h.repo.synchronize();
      expect((await h.repo.getMyWorkouts()).single.routineId, 'push-routine');
      await expectLater(
        verify('push-routine'),
        throwsA(isA<WorkoutException>()),
      );
      await expectLater(
        h.repo.cacheConfirmedWorkout(
          const Workout(
            routineId: 'foreign',
            userId: 'other',
            name: 'Foreign',
            status: 'ACTIVE',
          ),
          expectedScope: _identity.scope,
        ),
        throwsA(isA<WorkoutException>()),
      );
    },
  );

  test(
    'fallo al persistir ACK conserva la operacion y reintenta sin duplicar',
    () async {
      final storage = _MemoryStorage();
      final h = _Harness(storage);
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      h.remote.online = true;
      h.remote.onStartSaved = () => storage.failWrites = true;
      await h.repo.synchronize();
      expect(h.repo.state.phase, OfflineSyncPhase.storageError);
      expect(h.remote.sessions.length, 1);
      storage.failWrites = false;
      expect((await h.store.read(_identity.scope))['outbox'], hasLength(1));
      h.remote.onStartSaved = null;
      await h.repo.synchronize();
      expect(h.repo.state.pending, 0);
      expect(h.remote.sessions.length, 1);
    },
  );

  test(
    'ACK atrasado no elimina una serie editada mientras la anterior se enviaba',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      final local = await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      h.remote.online = true;
      await h.repo.synchronize();
      h.remote.performanceGate = Completer<void>();
      h.remote.performanceEntered = Completer<void>();
      await h.repo.recordPerformance(_performance(local.id, 20));
      final sync = h.repo.synchronize();
      await h.remote.performanceEntered!.future;
      await h.repo.recordPerformance(_performance(local.id, 30));
      h.remote.performanceGate!.complete();
      await sync;
      expect(h.remote.recordedWeights, [20, 30]);
      expect(
        h.remote.sessions.values.single.exercises.single.sets.single.weightKg,
        30,
      );
      expect(h.repo.state.pending, 0);
    },
  );

  test(
    'cerrar sesion durante un ACK conserva la operacion de la cuenta anterior',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      h.remote.online = true;
      h.remote.startResponseGate = Completer<void>();
      h.remote.startEntered = Completer<void>();
      final syncing = h.repo.synchronize();
      await h.remote.startEntered!.future;
      h.identity = null;
      h.repo.accountChanged();
      h.remote.startResponseGate!.complete();
      await syncing;
      expect((await h.store.read(_identity.scope))['outbox'], hasLength(1));
      expect(h.remote.sessions, hasLength(1));

      h.identity = _identity;
      h.repo.accountChanged();
      await h.repo.synchronize();
      expect(h.repo.state.pending, 0);
      expect(h.remote.sessions, hasLength(1));
    },
  );

  test(
    'rutinas y series sobreviven recrear el repositorio desde disco sin red',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gymsas-offline-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final storage = EncryptedFileOfflineValueStorage(
        directory,
        List.generate(32, (i) => i),
      );
      final h = _Harness(storage);
      await h.repo.synchronize();
      h.remote.online = false;
      final session = await h.repo.startWorkoutSession(_start);
      await h.repo.recordPerformance(_performance(session.id, 42.5));
      await h.repo.synchronize();
      h.repo.dispose();

      for (final file in directory.listSync().whereType<File>()) {
        expect(await file.readAsString(), isNot(contains('Strength')));
      }

      final reopenedHarness = _Harness(
        EncryptedFileOfflineValueStorage(
          directory,
          List.generate(32, (i) => i),
        ),
      )..remote.online = false;
      final reopened = reopenedHarness.repo;
      addTearDown(reopened.dispose);
      expect((await reopened.getMyWorkouts()).single.name, 'Strength');
      final restored = (await reopened.getMyWorkoutSessions()).single;
      expect(restored.id, session.id);
      expect(restored.exercises.single.sets.single.weightKg, 42.5);
      expect(restored.exercises.single.sets.single.completed, isTrue);
      await reopened.synchronize();
      expect(reopened.state.pending, 2);
    },
  );

  test(
    'sincroniza inicio, series, pausa y finalizacion en orden con IDs estables',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      final session = await h.repo.startWorkoutSession(_start);
      await h.repo.recordPerformance(_performance(session.id, 20));
      await h.repo.pauseWorkoutSession(session.id);
      await h.repo.finishWorkoutSession(session.id);
      await h.repo.synchronize();
      expect(h.repo.state.pending, 4);
      h.remote.online = true;
      await h.repo.synchronize();
      expect(h.remote.applied, ['start', 'performance', 'pause', 'finish']);
      expect(h.repo.state.pending, 0);
      final local = (await h.repo.getMyWorkoutSessions()).single;
      expect(local.id, session.id);
      expect(local.status, 'COMPLETED');
      expect(local.exercises.single.sets.single.weightKg, 20);
    },
  );

  test(
    'respuesta perdida al iniciar reintenta la misma clave sin duplicar',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      final session = await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      h.remote.online = true;
      h.remote.loseStartResponse = true;
      await h.repo.synchronize();
      expect(h.repo.state.pending, 1);
      expect(h.remote.sessions.length, 1);
      await h.repo.synchronize();
      expect(h.remote.startKeys.toSet().length, 1);
      expect(h.remote.sessions.length, 1);
      expect(h.repo.state.pending, 0);
      expect((await h.repo.getMyWorkoutSessions()).single.id, session.id);
    },
  );

  test('reintenta automaticamente cuando vuelve el servidor', () async {
    final h = _Harness(_MemoryStorage());
    addTearDown(h.repo.dispose);
    await h.repo.synchronize();
    h.remote.online = false;
    final session = await h.repo.startWorkoutSession(_start);
    await h.repo.recordPerformance(_performance(session.id, 30));
    await h.repo.synchronize();
    final synced = h.repo.changes.firstWhere(
      (s) => s.pending == 0 && s.phase == OfflineSyncPhase.ready,
    );
    h.repo.start();
    h.remote.online = true;
    await synced.timeout(const Duration(seconds: 3));
    expect(h.remote.applied, ['start', 'performance']);
  });

  test('cambio de cuenta conserva cola anterior y no mezcla rutinas', () async {
    final storage = _MemoryStorage();
    final h = _Harness(storage);
    addTearDown(h.repo.dispose);
    await h.repo.synchronize();
    h.remote.online = false;
    await h.repo.startWorkoutSession(_start);
    await h.repo.synchronize();
    h.identity = const OfflineIdentity(
      scope: 'backend/tenant-B/user-B',
      ownerId: 'tenant-B',
      userId: 'user-B',
    );
    h.repo.accountChanged();
    await expectLater(h.repo.getMyWorkouts(), throwsA(isA<WorkoutException>()));
    expect((await h.store.read(h.identity!.scope))['outbox'], isNull);
    h.identity = _identity;
    h.repo.accountChanged();
    expect((await h.repo.getMyWorkoutSessions()).length, 1);
    await h.repo.synchronize();
    expect(h.repo.state.pending, 1);
  });

  test(
    'respuesta tardia de otra cuenta no se escribe en la cuenta nueva',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      final gate = Completer<List<Workout>>();
      h.remote.workoutGate = gate;
      final syncing = h.repo.synchronize();
      await Future<void>.delayed(Duration.zero);
      h.identity = const OfflineIdentity(
        scope: 'other',
        ownerId: 'other',
        userId: 'other',
      );
      gate.complete([_workout]);
      await syncing;
      expect((await h.store.read('other'))['workouts'], isNull);
      expect((await h.store.read(_identity.scope))['workouts'], isNull);
    },
  );

  test(
    'fallo de disco no confirma guardado ni altera el snapshot anterior',
    () async {
      final storage = _MemoryStorage();
      final h = _Harness(storage);
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      storage.failWrites = true;
      await expectLater(
        h.repo.startWorkoutSession(_start),
        throwsA(isA<FileSystemException>()),
      );
      expect(h.repo.state.phase, OfflineSyncPhase.storageError);
      storage.failWrites = false;
      expect((await h.store.read(_identity.scope))['outbox'], isNull);
    },
  );

  test(
    'rechazo definitivo conserva la operacion y detiene reintentos automaticos',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      h.remote.online = true;
      h.remote.rejectStart = true;
      await h.repo.synchronize();
      final calls = h.remote.startCalls;
      await h.repo.synchronize();
      expect(h.remote.startCalls, calls);
      expect(h.repo.state.phase, OfflineSyncPhase.conflict);
      expect(h.repo.state.pending, 1);
      h.remote.rejectStart = false;
      await h.repo.synchronize(retryBlocked: true);
      expect(h.repo.state.pending, 0);
    },
  );

  test(
    'token expirado permite datos locales pero no envio al servidor',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.authorized = false;
      await h.repo.startWorkoutSession(_start);
      await h.repo.synchronize();
      expect((await h.repo.getMyWorkouts()).single.name, 'Strength');
      expect(h.remote.startCalls, 0);
      expect(h.repo.state.phase, OfflineSyncPhase.authenticationRequired);
      expect(h.repo.state.pending, 1);
    },
  );

  test(
    'serie escrita en el store se confirma localmente aunque no haya red',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      await h.repo.synchronize();
      h.remote.online = false;
      final session = await h.repo.startWorkoutSession(_start);
      final store = WorkoutSessionStore(
        recordPerformance: RecordWorkoutPerformance(h.repo),
        initialSession: ui.WorkoutSessionData(
          sessionId: session.id,
          status: 'IN_PROGRESS',
          routineName: 'Strength',
          dayTitle: null,
          totalSeries: 1,
          estimatedDurationMinutes: 30,
          exercises: const [
            ui.WorkoutExercise(
              order: 1,
              name: 'Squat',
              exerciseId: 'squat',
              seriesCount: 1,
              repetitionRange: '10',
            ),
          ],
        ),
      );
      addTearDown(store.dispose);
      store.setSeriesWeight(0, 0, '45');
      store.setSeriesRepetitions(0, 0, '10');
      store.toggleSeries(0, 0);
      store.completeExercise(0);
      await store.flushPerformance();
      expect(store.saveFailed, isFalse);
      final persisted = (await h.repo.getMyWorkoutSessions()).single;
      expect(persisted.exercises.single.sets.single.weightKg, 45);
      expect(persisted.exercises.single.sets.single.reps, 10);
      expect(persisted.exercises.single.isCompleted, isTrue);
      final restoredRepository = h.createRepository();
      addTearDown(restoredRepository.dispose);
      expect(
        (await restoredRepository.getMyWorkoutSessions())
            .single
            .exercises
            .single
            .isCompleted,
        isTrue,
      );
    },
  );

  test(
    'progreso consultado se conserva sin red y no se borra por errores transitorios',
    () async {
      final h = _Harness(_MemoryStorage());
      addTearDown(h.repo.dispose);
      final controller = MyProgressController(GetWorkoutProgress(h.repo));
      addTearDown(controller.dispose);
      await controller.load();
      h.remote.online = false;
      await controller.load();
      expect(controller.progress, isNotNull);
      expect(controller.error, isNull);
    },
  );

  test(
    'transacciones concurrentes y schema corrupto no descartan datos',
    () async {
      final storage = _MemoryStorage();
      final store = SerializedOfflineDocumentStore(storage);
      await Future.wait(
        List.generate(
          30,
          (_) => store.update('scope', (d) {
            d['count'] = (d['count'] as int? ?? 0) + 1;
          }),
        ),
      );
      expect((await store.read('scope'))['count'], 30);
      final original = storage.values.values.single;
      storage.values[storage.values.keys.single] = '{invalid';
      await expectLater(
        store.update('scope', (d) => d.clear()),
        throwsA(isA<FormatException>()),
      );
      expect(storage.values.values.single, '{invalid');
      expect(original, contains('30'));
    },
  );
}

const _identity = OfflineIdentity(
  scope: 'backend/tenant-A/user-A',
  ownerId: 'tenant-A',
  userId: 'user-A',
);
const _pushWorkout = Workout(
  routineId: 'push-routine',
  userId: 'user-A',
  name: 'Verified routine',
  status: 'ACTIVE',
);
const _start = StartWorkoutSessionCommand(
  routineId: 'routine',
  scheduledDay: 'MONDAY',
);
const _workout = Workout(
  routineId: 'routine',
  userId: 'user-A',
  name: 'Strength',
  status: 'ACTIVE',
  days: [
    WorkoutDayPlan(
      day: WorkoutDay.monday,
      exercises: [
        WorkoutExercise(
          exerciseId: 'squat',
          name: 'Squat',
          sets: 1,
          reps: 10,
          restSeconds: 60,
        ),
      ],
    ),
  ],
);
SessionPerformance _performance(String id, double weight) => SessionPerformance(
  sessionId: id,
  exercises: [
    ExercisePerformance(
      exerciseId: 'squat',
      sets: [
        WorkoutSet(setNumber: 1, weightKg: weight, reps: 10, completed: true),
      ],
    ),
  ],
);

class _Harness {
  _Harness(OfflineValueStorage storage)
    : store = SerializedOfflineDocumentStore(storage) {
    repo = createRepository();
  }
  final SerializedOfflineDocumentStore store;
  final remote = _Remote();
  OfflineIdentity? identity = _identity;
  bool authorized = true;
  late OfflineWorkoutRepository repo;
  OfflineWorkoutRepository createRepository() => OfflineWorkoutRepository(
    remote: remote,
    performance: remote,
    progress: remote,
    store: store,
    identity: () => identity,
    canSynchronize: () => authorized,
    retryInterval: const Duration(milliseconds: 30),
  );
}

class _MemoryStorage implements OfflineValueStorage {
  final values = <String, String>{};
  bool failWrites = false;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw const FileSystemException('Synthetic disk failure');
    values[key] = value;
  }
}

class _Remote
    implements
        WorkoutRepository,
        SessionPerformanceCommandPort,
        WorkoutProgressQueryPort {
  bool online = true, loseStartResponse = false, rejectStart = false;
  int startCalls = 0;
  void Function()? onStartSaved;
  Completer<void>?
  performanceGate,
      performanceEntered,
      workoutEntered,
      startResponseGate,
      startEntered;
  final recordedWeights = <double?>[];
  Completer<List<Workout>>? workoutGate;
  final sessions = <String, WorkoutSession>{};
  final startKeys = <String>[];
  final applied = <String>[];
  void _network() {
    if (!online) throw const WorkoutException(WorkoutErrorCode.network);
  }

  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async {
    _network();
    if (workoutEntered != null && !workoutEntered!.isCompleted) {
      workoutEntered!.complete();
    }
    return workoutGate?.future ?? [_workout];
  }

  @override
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly}) async {
    _network();
    return sessions.values.toList();
  }

  @override
  Future<WorkoutSession> startWorkoutSession(
    StartWorkoutSessionCommand command,
  ) async {
    startCalls++;
    _network();
    if (rejectStart) throw const WorkoutException(WorkoutErrorCode.conflict);
    final key = command.clientRequestId!;
    startKeys.add(key);
    final existing = sessions['server-$key'];
    if (existing != null) return existing;
    final value = WorkoutSession(
      id: 'server-$key',
      routineId: command.routineId,
      userId: 'user-A',
      status: 'IN_PROGRESS',
      startedAt: command.startedAt,
      exercises: const [
        WorkoutSessionExercise(
          exerciseId: 'squat',
          plannedSets: 1,
          plannedReps: 10,
        ),
      ],
    );
    sessions[value.id] = value;
    applied.add('start');
    onStartSaved?.call();
    if (startEntered != null && !startEntered!.isCompleted) {
      startEntered!.complete();
    }
    await startResponseGate?.future;
    if (loseStartResponse) {
      loseStartResponse = false;
      throw const WorkoutException(WorkoutErrorCode.timeout);
    }
    return value;
  }

  @override
  Future<void> recordPerformance(SessionPerformance value) async {
    _network();
    if (performanceEntered != null && !performanceEntered!.isCompleted) {
      performanceEntered!.complete();
    }
    await performanceGate?.future;
    recordedWeights.add(value.exercises.first.sets.first.weightKg);
    applied.add('performance');
    final current = sessions[value.sessionId]!;
    sessions[value.sessionId] = WorkoutSession(
      id: current.id,
      routineId: current.routineId,
      userId: current.userId,
      status: current.status,
      startedAt: current.startedAt,
      exercises: value.exercises
          .map(
            (e) => WorkoutSessionExercise(
              exerciseId: e.exerciseId,
              plannedSets: 1,
              plannedReps: 10,
              sets: e.sets,
            ),
          )
          .toList(),
    );
  }

  Future<WorkoutSession> _transition(
    String id,
    String status,
    String event,
  ) async {
    _network();
    applied.add(event);
    final current = sessions[id]!;
    final value = WorkoutSession(
      id: id,
      routineId: current.routineId,
      userId: current.userId,
      status: status,
      startedAt: current.startedAt,
      exercises: current.exercises,
    );
    sessions[id] = value;
    return value;
  }

  @override
  Future<WorkoutSession> pauseWorkoutSession(String id) =>
      _transition(id, 'PAUSED', 'pause');
  @override
  Future<WorkoutSession> finishWorkoutSession(String id) =>
      _transition(id, 'COMPLETED', 'finish');
  @override
  Future<Workout> assign(AssignWorkoutCommand command) async =>
      throw UnimplementedError();
  @override
  Future<WorkoutProgress> getProgress(ProgressRequest r) async {
    if (!online) throw const ProgressException(ProgressError.unavailable);
    return WorkoutProgress(
      from: r.from,
      to: r.to,
      historyMonths: 1,
      points: const [],
    );
  }
}
