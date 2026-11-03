import 'package:gymsas_api_client/gymsas_api_client.dart';
import '../../domain/entities/workout_progress.dart';
import '../../domain/entities/session_performance.dart';
import '../../domain/ports/workout_progress_repository.dart';

class GraphQlWorkoutProgressRepository
    implements WorkoutProgressQueryPort, SessionPerformanceCommandPort {
  const GraphQlWorkoutProgressRepository(this._client, this._token);
  final GraphQlClient _client;
  final String? Function() _token;

  Future<Map<String, dynamic>> _execute(
    String document,
    Map<String, dynamic> variables,
  ) async {
    final token = _token();
    if (token == null || token.isEmpty) {
      throw const ProgressException(ProgressError.unauthorized);
    }
    try {
      return await _client.execute(
        document: document,
        variables: variables,
        accessToken: token,
      );
    } on GraphQlException catch (error) {
      if (error.errors.any((e) => e.message.contains('HISTORY_NOT_ALLOWED'))) {
        throw const ProgressException(ProgressError.historyNotAllowed);
      }
      final status = error.errors.isEmpty
          ? null
          : error.errors.first.extensions['httpStatus'];
      throw ProgressException(_errorForStatus(int.tryParse('$status')));
    } on ApiClientException catch (error) {
      throw ProgressException(_errorForStatus(error.statusCode));
    } on Object {
      throw const ProgressException(ProgressError.unavailable);
    }
  }

  ProgressError _errorForStatus(int? status) => switch (status) {
    400 || 422 => ProgressError.invalidInput,
    401 => ProgressError.unauthorized,
    403 => ProgressError.forbidden,
    404 || 409 => ProgressError.conflict,
    _ => ProgressError.unavailable,
  };

  @override
  Future<WorkoutProgress> getProgress(ProgressRequest request) async {
    final data = await _execute(
      r'''
      query MyWorkoutProgress($from: String!, $to: String!, $granularity: String!, $timeZone: String!, $exerciseId: ID) {
        myWorkoutProgress(from: $from, to: $to, granularity: $granularity, timeZone: $timeZone, exerciseId: $exerciseId) {
          from to earliestDate historyMonths
          points { date completedSets repetitions maxWeightKg volumeKg sessions trainingDays unrecordedSessions }
        }
      }
    ''',
      {
        'from': _date(request.from),
        'to': _date(request.to),
        'granularity': request.granularity.name.toUpperCase(),
        'timeZone': request.timeZone,
        'exerciseId': request.exerciseId,
      },
    );
    try {
      final raw = data['myWorkoutProgress'] as Map<String, dynamic>;
      return WorkoutProgress(
        from: DateTime.parse(raw['from'] as String),
        to: DateTime.parse(raw['to'] as String),
        earliestDate: raw['earliestDate'] == null
            ? null
            : DateTime.parse(raw['earliestDate'] as String),
        historyMonths: raw['historyMonths'] as int,
        points: List.unmodifiable(
          (raw['points'] as List).map((value) {
            final p = value as Map<String, dynamic>;
            return ProgressPoint(
              date: DateTime.parse(p['date'] as String),
              completedSets: (p['completedSets'] as num).toInt(),
              repetitions: (p['repetitions'] as num).toInt(),
              maxWeightKg: (p['maxWeightKg'] as num?)?.toDouble(),
              volumeKg: (p['volumeKg'] as num).toDouble(),
              sessions: (p['sessions'] as num).toInt(),
              trainingDays: (p['trainingDays'] as num).toInt(),
              unrecordedSessions: (p['unrecordedSessions'] as num).toInt(),
            );
          }),
        ),
      );
    } on Object {
      throw const ProgressException(ProgressError.unavailable);
    }
  }

  @override
  Future<void> recordPerformance(SessionPerformance performance) async {
    final data = await _execute(
      r'''
      mutation RecordWorkoutPerformance($sessionId: ID!, $input: SessionPerformanceInput!) {
        recordWorkoutPerformance(sessionId: $sessionId, input: $input)
      }
    ''',
      {
        'sessionId': performance.sessionId,
        'input': {
          'exercises': performance.exercises
              .map(
                (e) => {
                  'exerciseId': e.exerciseId,
                  'sets': e.sets
                      .map(
                        (s) => {
                          'setNumber': s.setNumber,
                          'weightKg': s.weightKg,
                          'reps': s.reps,
                          'restSeconds': s.restSeconds,
                          'durationSeconds': s.durationSeconds,
                          'completed': s.completed,
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
        },
      },
    );
    if (data['recordWorkoutPerformance'] != true) {
      throw const ProgressException(ProgressError.unavailable);
    }
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
