import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:gymsas_offline/gymsas_offline.dart';
import '../../domain/entities/assign_workout_command.dart';
import '../../domain/entities/start_workout_session_command.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_session_exercise.dart';
import '../../domain/entities/session_performance.dart';
import '../../domain/entities/workout_progress.dart';
import '../../domain/ports/workout_repository.dart';
import '../../domain/ports/confirmed_workout_cache_port.dart';
import '../../domain/ports/workout_progress_repository.dart';
import '../../domain/workout_error.dart';
import 'workout_local_codec.dart';

/// Local snapshots and the outbox are committed together before acknowledging UI.
/// Only this repository knows remote/local IDs and the synchronization protocol.
class OfflineWorkoutRepository
    implements
        WorkoutRepository,
        ConfirmedWorkoutCachePort,
        SessionPerformanceCommandPort,
        WorkoutProgressQueryPort {
  OfflineWorkoutRepository({
    required WorkoutRepository remote,
    required SessionPerformanceCommandPort performance,
    required WorkoutProgressQueryPort progress,
    required OfflineDocumentStore store,
    required OfflineIdentity? Function() identity,
    required bool Function() canSynchronize,
    DateTime Function()? now,
    this.retryInterval = const Duration(seconds: 15),
  }) : _remote = remote,
       _performance = performance,
       _progress = progress,
       _store = store,
       _identity = identity,
       _canSynchronize = canSynchronize,
       _now = now ?? DateTime.now;

  final WorkoutRepository _remote;
  final SessionPerformanceCommandPort _performance;
  final WorkoutProgressQueryPort _progress;
  final OfflineDocumentStore _store;
  final OfflineIdentity? Function() _identity;
  final bool Function() _canSynchronize;
  final DateTime Function() _now;
  final Duration retryInterval;
  final _events = StreamController<OfflineSyncState>.broadcast(sync: true);
  final _progressRequests = <String>{};
  OfflineSyncState _state = const OfflineSyncState();
  OfflineSyncState get state => _state;
  Stream<OfflineSyncState> get changes => _events.stream;
  Future<void>? _inFlight;
  Timer? _timer;
  bool _disposed = false;
  int _revision = 0;
  int _confirmedRoutineRevision = 0;
  int _failures = 0;
  DateTime? _nextAttempt;

  void start() {
    _timer ??= Timer.periodic(retryInterval, (_) => _kick());
    _kick();
  }

  void accountChanged() {
    _failures = 0;
    _nextAttempt = null;
    _state = OfflineSyncState(revision: ++_revision);
    if (!_disposed) _events.add(_state);
    _kick();
  }

  void _kick() {
    if (_state.phase == OfflineSyncPhase.authenticationRequired) return;
    if (_nextAttempt != null && _now().isBefore(_nextAttempt!)) return;
    if (!_disposed && _identity() != null && _inFlight == null) {
      unawaited(synchronize().catchError((Object _) {}));
    }
  }

  bool _current(String scope) => !_disposed && _identity()?.scope == scope;
  OfflineIdentity _account() =>
      _identity() ??
      (throw const WorkoutException(WorkoutErrorCode.unauthorized));
  void _requireCurrent(String scope) {
    if (!_current(scope)) {
      throw const WorkoutException(WorkoutErrorCode.unauthorized);
    }
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> d, String key) =>
      (d[key] as List? ?? [])
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();

  Future<void> _publish(
    String scope,
    OfflineSyncPhase phase, {
    bool changed = false,
  }) async {
    final document = await _store.read(scope);
    if (!_current(scope)) return;
    if (phase == OfflineSyncPhase.offline) {
      _failures++;
      final factor = 1 << min(_failures - 1, 5);
      final base = min(retryInterval.inMilliseconds * factor, 300000);
      final jitter = Random.secure().nextInt(max(1, base ~/ 4));
      _nextAttempt = _now().add(Duration(milliseconds: base + jitter));
    } else if (phase == OfflineSyncPhase.ready) {
      _failures = 0;
      _nextAttempt = null;
    }
    if (changed) _revision++;
    _state = OfflineSyncState(
      phase: phase,
      pending: _list(document, 'outbox').length,
      revision: _revision,
    );
    _events.add(_state);
  }

  Future<Map<String, dynamic>> _snapshot(String key) async {
    final scope = _account().scope;
    var document = await _store.read(scope);
    _requireCurrent(scope);
    if (document[key] == null) {
      await synchronize();
      _requireCurrent(scope);
      document = await _store.read(scope);
      if (document[key] == null) {
        throw WorkoutException(
          _canSynchronize()
              ? WorkoutErrorCode.network
              : WorkoutErrorCode.unauthorized,
        );
      }
    } else {
      _kick();
    }
    _requireCurrent(scope);
    return document;
  }

  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async {
    final d = await _snapshot('workouts');
    return _list(d, 'workouts')
        .map(WorkoutLocalCodec.readWorkout)
        .where((w) => activeOnly != true || w.status == 'ACTIVE')
        .toList();
  }

  @override
  String? get currentScope => _identity()?.scope;
  @override
  Future<void> cacheConfirmedWorkout(
    Workout workout, {
    required String expectedScope,
  }) async {
    _requireCurrent(expectedScope);
    if (workout.userId != _account().userId || workout.status != 'ACTIVE') {
      throw const WorkoutException(WorkoutErrorCode.forbidden);
    }
    await _commit(expectedScope, (d) {
      _confirmedRoutineRevision++;
      final cached = _list(
        d,
        'workouts',
      ).where((w) => w['id'] != workout.routineId).toList();
      cached.add(WorkoutLocalCodec.workout(workout));
      d['workouts'] = cached;
    });
  }

  @override
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly}) async {
    final d = await _snapshot('sessions');
    return _list(d, 'sessions')
        .map(WorkoutLocalCodec.readSession)
        .where((s) => activeOnly != true || s.isActive)
        .toList();
  }

  /// Assignments affect subscription quotas and remain an online operation.
  @override
  Future<Workout> assign(AssignWorkoutCommand command) async {
    final scope = _account().scope;
    _requireCurrent(scope);
    if (!_canSynchronize()) {
      throw const WorkoutException(WorkoutErrorCode.unauthorized);
    }
    final result = await _remote.assign(command);
    _requireCurrent(scope);
    _kick();
    return result;
  }

  String _operationId() {
    final r = Random.secure();
    return List.generate(
      16,
      (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<T> _commit<T>(
    String scope,
    T Function(Map<String, dynamic>) change,
  ) async {
    try {
      final value = await _store.update(scope, (d) {
        _requireCurrent(scope);
        final value = change(d);
        if (_list(d, 'outbox').length > 2000) {
          throw StateError(
            'Offline outbox capacity reached; synchronize before continuing',
          );
        }
        return value;
      });
      await _publish(scope, _state.phase, changed: true);
      _kick();
      return value;
    } on WorkoutException {
      rethrow;
    } on Object {
      if (_current(scope)) {
        _state = OfflineSyncState(
          phase: OfflineSyncPhase.storageError,
          pending: _state.pending,
          revision: _revision,
        );
        _events.add(_state);
      }
      rethrow;
    }
  }

  @override
  Future<WorkoutSession> startWorkoutSession(
    StartWorkoutSessionCommand command,
  ) async {
    final account = _account();
    final id = _operationId();
    return _commit(account.scope, (d) {
      final workouts = _list(d, 'workouts')
          .map(WorkoutLocalCodec.readWorkout)
          .where((w) => w.routineId == command.routineId)
          .toList();
      if (workouts.isEmpty || workouts.first.status != 'ACTIVE') {
        throw const WorkoutException(WorkoutErrorCode.invalidInput);
      }
      final workout = workouts.first;
      final plans =
          workout.days
              ?.where((p) => p.day.apiValue == command.scheduledDay)
              .toList() ??
          [];
      if (plans.isEmpty) {
        throw const WorkoutException(WorkoutErrorCode.invalidInput);
      }
      final sessions = _list(d, 'sessions');
      final active = sessions
          .map(WorkoutLocalCodec.readSession)
          .where((s) => s.routineId == workout.routineId && s.isActive)
          .toList();
      if (active.isNotEmpty) return active.first;
      final now = _now().toUtc();
      final session = WorkoutSession(
        id: 'local-$id',
        routineId: workout.routineId,
        userId: workout.userId,
        ownerId: account.ownerId,
        scheduledDay: command.scheduledDay,
        status: 'IN_PROGRESS',
        startedAt: now,
        exercises: plans.first.exercises
            .map(
              (e) => WorkoutSessionExercise(
                exerciseId: e.exerciseId,
                plannedSets: e.sets,
                plannedReps: e.reps,
                plannedRestSeconds: e.restSeconds,
              ),
            )
            .toList(),
      );
      sessions.add(WorkoutLocalCodec.session(session));
      d['sessions'] = sessions;
      final queue = _list(d, 'outbox')
        ..add({
          'id': id,
          'type': 'start',
          'session': session.id,
          'routine': command.routineId,
          'day': command.scheduledDay,
          'user': command.userId,
          'startedAt': now.toIso8601String(),
        });
      d['outbox'] = queue;
      return session;
    });
  }

  @override
  Future<void> recordPerformance(SessionPerformance performance) async {
    final scope = _account().scope;
    await _commit(scope, (d) {
      final sessions = _list(d, 'sessions');
      final session = sessions.firstWhere(
        (s) => s['id'] == performance.sessionId,
        orElse: () =>
            throw const WorkoutException(WorkoutErrorCode.invalidInput),
      );
      final exercises = (session['exercises'] as List).cast<Map>();
      final before = jsonEncode(exercises);
      for (final e in performance.exercises) {
        final matches = exercises
            .where((v) => v['id'] == e.exerciseId)
            .toList();
        if (matches.isEmpty) {
          throw const WorkoutException(WorkoutErrorCode.invalidInput);
        }
        matches.first['recorded'] = e.sets.map(WorkoutLocalCodec.set).toList();
        matches.first['done'] = e.completed;
      }
      if (before == jsonEncode(exercises)) return;
      if (session['status'] == 'COMPLETED') {
        throw const WorkoutException(WorkoutErrorCode.conflict);
      }
      d['sessions'] = sessions;
      final queue = _list(d, 'outbox');
      // Only coalesce adjacent unsent snapshots. Never cross start/pause/finish.
      if (queue.isNotEmpty &&
          queue.last['type'] == 'performance' &&
          queue.last['session'] == performance.sessionId) {
        queue.removeLast();
      }
      queue.add({
        'id': _operationId(),
        'type': 'performance',
        'session': performance.sessionId,
        'value': WorkoutLocalCodec.performance(performance),
      });
      d['outbox'] = queue;
    });
  }

  @override
  Future<WorkoutSession> pauseWorkoutSession(String sessionId) =>
      _transition(sessionId, false);
  @override
  Future<WorkoutSession> finishWorkoutSession(String sessionId) =>
      _transition(sessionId, true);
  Future<WorkoutSession> _transition(String id, bool finish) {
    final scope = _account().scope;
    return _commit(scope, (d) {
      final sessions = _list(d, 'sessions');
      final raw = sessions.firstWhere(
        (s) => s['id'] == id,
        orElse: () =>
            throw const WorkoutException(WorkoutErrorCode.invalidInput),
      );
      final desired = finish ? 'COMPLETED' : 'PAUSED';
      if (raw['status'] == desired) return WorkoutLocalCodec.readSession(raw);
      if (raw['status'] == 'COMPLETED') {
        throw const WorkoutException(WorkoutErrorCode.conflict);
      }
      raw['status'] = desired;
      if (finish) {
        raw['end'] = _now().toUtc().toIso8601String();
        final started = DateTime.tryParse(raw['start'] as String? ?? '');
        if (started != null) {
          raw['duration'] = _now().difference(started).inSeconds;
        }
      }
      d['sessions'] = sessions;
      final queue = _list(d, 'outbox')
        ..add({
          'id': _operationId(),
          'type': finish ? 'finish' : 'pause',
          'session': id,
          'completedAt': raw['end'],
        });
      d['outbox'] = queue;
      return WorkoutLocalCodec.readSession(raw);
    });
  }

  Future<void> synchronize({bool retryBlocked = false}) {
    if (_disposed || _identity() == null) return Future.value();
    if (_inFlight != null) return _inFlight!;
    final scope = _account().scope;
    final next = _synchronize(scope, retryBlocked);
    _inFlight = next;
    return next.whenComplete(() {
      _inFlight = null;
      if (!_disposed && _identity()?.scope != scope) _kick();
    });
  }

  Future<void> _synchronize(String scope, bool retryBlocked) async {
    try {
      if (!_canSynchronize()) {
        await _publish(scope, OfflineSyncPhase.authenticationRequired);
        return;
      }
      await _publish(scope, OfflineSyncPhase.syncing);
      while (_current(scope)) {
        final d = await _store.read(scope);
        final queue = _list(d, 'outbox');
        if (queue.isEmpty) break;
        final op = queue.first;
        if (op['blocked'] != null && !retryBlocked) {
          await _publish(scope, OfflineSyncPhase.conflict);
          return;
        }
        _requireCurrent(scope);
        if (!_canSynchronize()) {
          await _publish(scope, OfflineSyncPhase.authenticationRequired);
          return;
        }
        final aliases = Map<String, dynamic>.from(d['aliases'] as Map? ?? {});
        final localId = op['session'] as String;
        final serverId = aliases[localId] as String? ?? localId;
        WorkoutSession? started;
        try {
          switch (op['type']) {
            case 'start':
              started = await _remote.startWorkoutSession(
                StartWorkoutSessionCommand(
                  routineId: op['routine'] as String,
                  scheduledDay: op['day'] as String,
                  userId: op['user'] as String?,
                  clientRequestId: op['id'] as String,
                  startedAt: DateTime.parse(op['startedAt'] as String),
                ),
              );
            case 'performance':
              await _performance.recordPerformance(
                WorkoutLocalCodec.readPerformance(
                  Map<String, dynamic>.from(op['value'] as Map),
                  serverId,
                ),
              );
            case 'pause':
              await _remote.pauseWorkoutSession(serverId);
            case 'finish':
              if (_remote case TimestampedWorkoutSessionPort timestamped) {
                await timestamped.finishWorkoutSessionAt(
                  serverId,
                  DateTime.parse(op['completedAt'] as String),
                );
              } else {
                await _remote.finishWorkoutSession(serverId);
              }
          }
        } on WorkoutException catch (e) {
          if (e.code == WorkoutErrorCode.unauthorized) {
            await _publish(scope, OfflineSyncPhase.authenticationRequired);
          } else if ({
            WorkoutErrorCode.invalidInput,
            WorkoutErrorCode.forbidden,
            WorkoutErrorCode.conflict,
            WorkoutErrorCode.quotaExceeded,
          }.contains(e.code)) {
            await _persistDuringSync(scope, (latest) {
              final q = _list(latest, 'outbox');
              for (final item in q) {
                if (item['id'] == op['id']) item['blocked'] = e.code.name;
              }
              latest['outbox'] = q;
            });
            await _publish(scope, OfflineSyncPhase.conflict);
          } else {
            await _publish(scope, OfflineSyncPhase.offline);
          }
          return;
        } on ProgressException catch (e) {
          if ({
            ProgressError.invalidInput,
            ProgressError.forbidden,
            ProgressError.conflict,
            ProgressError.historyNotAllowed,
          }.contains(e.code)) {
            await _persistDuringSync(scope, (latest) {
              final q = _list(latest, 'outbox');
              for (final item in q) {
                if (item['id'] == op['id']) item['blocked'] = e.code.name;
              }
              latest['outbox'] = q;
            });
            await _publish(scope, OfflineSyncPhase.conflict);
            return;
          }
          await _publish(
            scope,
            e.code == ProgressError.unauthorized
                ? OfflineSyncPhase.authenticationRequired
                : OfflineSyncPhase.offline,
          );
          return;
        }
        // A logout/account switch may happen while the server mutation is in
        // flight. Never acknowledge that operation against a stale scope: the
        // old account must retain its outbox entry and replay it idempotently
        // when that identity returns.
        _requireCurrent(scope);
        await _persistDuringSync(scope, (latest) {
          if (started != null) {
            final map = Map<String, dynamic>.from(
              latest['aliases'] as Map? ?? {},
            );
            map[localId] = started.id;
            latest['aliases'] = map;
          }
          latest['outbox'] = _list(
            latest,
            'outbox',
          ).where((item) => item['id'] != op['id']).toList();
        });
        await _publish(scope, OfflineSyncPhase.syncing, changed: true);
      }
      _requireCurrent(scope);
      final routineRevision = _confirmedRoutineRevision;
      final workouts = await _remote.getMyWorkouts(activeOnly: false);
      _requireCurrent(scope);
      final sessions = await _remote.getMyWorkoutSessions(activeOnly: false);
      _requireCurrent(scope);
      var changed = false;
      await _persistDuringSync(scope, (d) {
        final before = jsonEncode([d['workouts'], d['sessions']]);
        final aliases = Map<String, dynamic>.from(d['aliases'] as Map? ?? {});
        final reverse = {for (final e in aliases.entries) e.value: e.key};
        final pending = _list(d, 'outbox').map((op) => op['session']).toSet();
        final local = _list(d, 'sessions');
        final merged = <String, Map<String, dynamic>>{};
        for (final session in sessions) {
          final raw = WorkoutLocalCodec.session(session);
          raw['id'] = reverse[session.id] ?? session.id;
          merged[raw['id'] as String] = raw;
        }
        for (final cached in local) {
          if (pending.contains(cached['id'])) {
            merged[cached['id'] as String] = cached;
          } else if (merged[cached['id']]
              case final Map<String, dynamic> remote) {
            for (final previous in cached['exercises'] as List) {
              for (final next in remote['exercises'] as List) {
                if (previous['id'] == next['id'] &&
                    jsonEncode(previous['recorded']) ==
                        jsonEncode(next['recorded'])) {
                  next['done'] = previous['done'] ?? false;
                }
              }
            }
          }
        }
        // Una consulta anterior no debe borrar una rutina recién validada por push.
        if (routineRevision == _confirmedRoutineRevision) {
          d['workouts'] = workouts.map(WorkoutLocalCodec.workout).toList();
        }
        d['sessions'] = merged.values.toList();
        changed = before != jsonEncode([d['workouts'], d['sessions']]);
      });
      await _publish(scope, OfflineSyncPhase.ready, changed: changed);
    } on _OfflineStorageFailure {
      if (_current(scope)) {
        _state = OfflineSyncState(
          phase: OfflineSyncPhase.storageError,
          pending: _state.pending,
          revision: _revision,
        );
        _events.add(_state);
      }
    } on WorkoutException catch (error) {
      if (_current(scope)) {
        await _publish(
          scope,
          error.code == WorkoutErrorCode.unauthorized
              ? OfflineSyncPhase.authenticationRequired
              : OfflineSyncPhase.offline,
        );
      }
    } on Object {
      if (_current(scope)) {
        try {
          await _publish(scope, OfflineSyncPhase.offline);
        } on Object {
          _state = OfflineSyncState(
            phase: OfflineSyncPhase.storageError,
            pending: _state.pending,
            revision: _revision,
          );
          if (!_disposed) _events.add(_state);
        }
      }
    }
  }

  @override
  Future<WorkoutProgress> getProgress(ProgressRequest request) async {
    final scope = _account().scope;
    final key = jsonEncode([
      request.from.toIso8601String(),
      request.to.toIso8601String(),
      request.granularity.name,
      request.timeZone,
      request.exerciseId,
    ]);
    final d = await _store.read(scope);
    _requireCurrent(scope);
    final cache = Map<String, dynamic>.from(d['progress'] as Map? ?? {});
    final cached = cache[key];
    if (cached != null) {
      if (_progressRequests.add('$scope:$key')) {
        unawaited(
          _refreshProgress(scope, key, request)
              .then<void>((_) {})
              .catchError((Object _) {})
              .whenComplete(() => _progressRequests.remove('$scope:$key')),
        );
      }
      return WorkoutLocalCodec.readProgress(
        Map<String, dynamic>.from(cached as Map),
      );
    }
    return _refreshProgress(scope, key, request);
  }

  Future<T> _persistDuringSync<T>(
    String scope,
    T Function(Map<String, dynamic>) change,
  ) async {
    try {
      return await _store.update(scope, change);
    } on Object {
      throw const _OfflineStorageFailure();
    }
  }

  Future<WorkoutProgress> _refreshProgress(
    String scope,
    String key,
    ProgressRequest request,
  ) async {
    _requireCurrent(scope);
    if (!_canSynchronize()) {
      throw const ProgressException(ProgressError.unauthorized);
    }
    try {
      final result = await _progress.getProgress(request);
      _requireCurrent(scope);
      await _store.update(scope, (d) {
        final cache = Map<String, dynamic>.from(d['progress'] as Map? ?? {});
        cache.remove(key);
        cache[key] = WorkoutLocalCodec.progress(result);
        while (cache.length > 12) {
          cache.remove(cache.keys.first);
        }
        d['progress'] = cache;
      });
      return result;
    } on ProgressException catch (e) {
      if (e.code == ProgressError.historyNotAllowed) {
        await _store.update(scope, (d) {
          final cache = Map<String, dynamic>.from(d['progress'] as Map? ?? {});
          cache.remove(key);
          d['progress'] = cache;
        });
      }
      rethrow;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    unawaited(_events.close());
  }
}

class _OfflineStorageFailure implements Exception {
  const _OfflineStorageFailure();
}
