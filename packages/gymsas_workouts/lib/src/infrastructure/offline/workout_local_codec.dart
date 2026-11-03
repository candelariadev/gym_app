import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/workout_day_plan.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_session_exercise.dart';
import '../../domain/entities/session_performance.dart';
import '../../domain/entities/workout_progress.dart';

/// Persistence format is independent from GraphQL DTOs and presentation models.
abstract final class WorkoutLocalCodec {
  static Map<String, dynamic> workout(Workout w) => {
    'id': w.routineId,
    'user': w.userId,
    'name': w.name,
    'status': w.status,
    'start': w.startDate?.toIso8601String(),
    'end': w.endDate?.toIso8601String(),
    'weeks': w.durationWeeks,
    'current': w.isCurrentMonthPlan,
    'notes': w.notes,
    'days': w.days
        ?.map(
          (d) => {
            'day': d.day.name,
            'exercises': d.exercises
                .map(
                  (e) => {
                    'id': e.exerciseId,
                    'name': e.name,
                    'sets': e.sets,
                    'reps': e.reps,
                    'rest': e.restSeconds,
                    'notes': e.notes,
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };
  static Workout readWorkout(Map<String, dynamic> w) => Workout(
    routineId: w['id'] as String,
    userId: w['user'] as String,
    name: w['name'] as String,
    status: w['status'] as String,
    startDate: _date(w['start']),
    endDate: _date(w['end']),
    durationWeeks: w['weeks'] as int?,
    isCurrentMonthPlan: w['current'] as bool?,
    notes: w['notes'] as String?,
    days: (w['days'] as List?)?.map((raw) {
      final d = Map<String, dynamic>.from(raw as Map);
      return WorkoutDayPlan(
        day: WorkoutDay.values.byName(d['day'] as String),
        exercises: (d['exercises'] as List).map((raw) {
          final e = Map<String, dynamic>.from(raw as Map);
          return WorkoutExercise(
            exerciseId: e['id'] as String,
            name: e['name'] as String,
            sets: e['sets'] as int,
            reps: e['reps'] as int,
            restSeconds: e['rest'] as int,
            notes: e['notes'] as String?,
          );
        }).toList(),
      );
    }).toList(),
  );
  static Map<String, dynamic> set(WorkoutSet s) => {
    'number': s.setNumber,
    'weight': s.weightKg,
    'reps': s.reps,
    'rest': s.restSeconds,
    'duration': s.durationSeconds,
    'done': s.completed,
  };
  static WorkoutSet readSet(dynamic s) => WorkoutSet(
    setNumber: s['number'] as int,
    weightKg: (s['weight'] as num?)?.toDouble(),
    reps: s['reps'] as int?,
    restSeconds: s['rest'] as int?,
    durationSeconds: s['duration'] as int?,
    completed: s['done'] as bool,
  );
  static Map<String, dynamic> session(WorkoutSession s) => {
    'id': s.id,
    'owner': s.ownerId,
    'routine': s.routineId,
    'day': s.scheduledDay,
    'user': s.userId,
    'status': s.status,
    'notes': s.notes,
    'duration': s.totalDurationSeconds,
    'start': s.startedAt?.toIso8601String(),
    'end': s.completedAt?.toIso8601String(),
    'exercises': s.exercises
        .map(
          (e) => {
            'id': e.exerciseId,
            'sets': e.plannedSets,
            'reps': e.plannedReps,
            'rest': e.plannedRestSeconds,
            'recorded': e.sets.map(set).toList(),
            'done': e.isCompleted,
          },
        )
        .toList(),
  };
  static WorkoutSession readSession(Map<String, dynamic> s) => WorkoutSession(
    id: s['id'] as String,
    ownerId: s['owner'] as String?,
    routineId: s['routine'] as String,
    scheduledDay: s['day'] as String?,
    userId: s['user'] as String,
    status: s['status'] as String,
    notes: s['notes'] as String?,
    totalDurationSeconds: s['duration'] as int?,
    startedAt: _date(s['start']),
    completedAt: _date(s['end']),
    exercises: (s['exercises'] as List)
        .map(
          (e) => WorkoutSessionExercise(
            exerciseId: e['id'] as String,
            plannedSets: e['sets'] as int?,
            plannedReps: e['reps'] as int?,
            plannedRestSeconds: e['rest'] as int?,
            sets: (e['recorded'] as List).map(readSet).toList(),
            isCompleted: e['done'] as bool? ?? false,
          ),
        )
        .toList(),
  );
  static Map<String, dynamic> performance(SessionPerformance p) => {
    'session': p.sessionId,
    'exercises': p.exercises
        .map(
          (e) => {
            'id': e.exerciseId,
            'sets': e.sets.map(set).toList(),
            'done': e.completed,
          },
        )
        .toList(),
  };
  static SessionPerformance readPerformance(
    Map<String, dynamic> p,
    String id,
  ) => SessionPerformance(
    sessionId: id,
    exercises: (p['exercises'] as List)
        .map(
          (e) => ExercisePerformance(
            exerciseId: e['id'] as String,
            sets: (e['sets'] as List).map(readSet).toList(),
            completed: e['done'] as bool? ?? false,
          ),
        )
        .toList(),
  );
  static Map<String, dynamic> progress(WorkoutProgress p) => {
    'from': p.from.toIso8601String(),
    'to': p.to.toIso8601String(),
    'earliest': p.earliestDate?.toIso8601String(),
    'months': p.historyMonths,
    'points': p.points
        .map(
          (v) => {
            'date': v.date.toIso8601String(),
            'sets': v.completedSets,
            'reps': v.repetitions,
            'weight': v.maxWeightKg,
            'volume': v.volumeKg,
            'sessions': v.sessions,
            'days': v.trainingDays,
            'unrecorded': v.unrecordedSessions,
          },
        )
        .toList(),
  };
  static WorkoutProgress readProgress(Map<String, dynamic> p) =>
      WorkoutProgress(
        from: DateTime.parse(p['from'] as String),
        to: DateTime.parse(p['to'] as String),
        earliestDate: _date(p['earliest']),
        historyMonths: p['months'] as int,
        points: (p['points'] as List)
            .map(
              (v) => ProgressPoint(
                date: DateTime.parse(v['date'] as String),
                completedSets: v['sets'] as int,
                repetitions: v['reps'] as int,
                maxWeightKg: (v['weight'] as num?)?.toDouble(),
                volumeKg: (v['volume'] as num).toDouble(),
                sessions: v['sessions'] as int,
                trainingDays: v['days'] as int,
                unrecordedSessions: v['unrecorded'] as int,
              ),
            )
            .toList(),
      );
  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.parse(v as String);
}
