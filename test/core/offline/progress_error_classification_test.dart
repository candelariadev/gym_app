import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:gymsas_workouts/src/infrastructure/repositories/workout_progress_repository.dart';

void main() {
  for (final entry in {
    401: ProgressError.unauthorized,
    403: ProgressError.forbidden,
    409: ProgressError.conflict,
    400: ProgressError.invalidInput,
    503: ProgressError.unavailable,
  }.entries) {
    test('HTTP ${entry.key} no se confunde con un fallo transitorio', () async {
      final repository = GraphQlWorkoutProgressRepository(
        _Client(entry.key),
        () => 'synthetic-token',
      );
      await expectLater(
        repository.recordPerformance(
          const SessionPerformance(sessionId: 'session', exercises: []),
        ),
        throwsA(
          isA<ProgressException>().having((e) => e.code, 'code', entry.value),
        ),
      );
    });
  }
}

class _Client implements GraphQlClient {
  _Client(this.status);
  final int status;
  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async =>
      throw ApiClientException(ApiClientErrorCode.server, statusCode: status);
  @override
  void close() {}
}
