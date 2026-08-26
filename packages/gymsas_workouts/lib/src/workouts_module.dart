import 'package:gymsas_api_client/gymsas_api_client.dart';

import 'application/assign_workout_use_case.dart';
import 'application/get_my_workout_sessions_use_case.dart';
import 'application/get_my_workouts_use_case.dart';
import 'application/finish_workout_session_use_case.dart';
import 'application/pause_workout_session_use_case.dart';
import 'application/start_workout_session_use_case.dart';
import 'infrastructure/datasources/workout_graphql_data_source.dart';
import 'infrastructure/mappers/workout_error_mapper.dart';
import 'infrastructure/repositories/workout_repository_impl.dart';

class WorkoutsModule {
  WorkoutsModule._({
    required this.assignWorkout,
    required this.getMyWorkouts,
    required this.getMyWorkoutSessions,
    required this.startWorkoutSession,
    required this.pauseWorkoutSession,
    required this.finishWorkoutSession,
    required GraphQlClient client,
  })
    : _client = client;

  factory WorkoutsModule.production({
    required String graphQlEndpoint,
    required String? Function() accessTokenProvider,
    ApiTrace trace = const DeveloperApiTrace(),
  }) {
    final client = HttpGraphQlClient(endpoint: graphQlEndpoint, trace: trace);
    final repository = WorkoutRepositoryImpl(
      dataSource: WorkoutGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
      errorMapper: const WorkoutErrorMapper(),
      trace: trace,
    );
    return WorkoutsModule._(
      assignWorkout: AssignWorkoutUseCase(repository),
      getMyWorkouts: GetMyWorkoutsUseCase(repository),
      getMyWorkoutSessions: GetMyWorkoutSessionsUseCase(repository),
      startWorkoutSession: StartWorkoutSessionUseCase(repository),
      pauseWorkoutSession: PauseWorkoutSessionUseCase(repository),
      finishWorkoutSession: FinishWorkoutSessionUseCase(repository),
      client: client,
    );
  }

  final AssignWorkoutUseCase assignWorkout;
  final GetMyWorkoutsUseCase getMyWorkouts;
  final GetMyWorkoutSessionsUseCase getMyWorkoutSessions;
  final StartWorkoutSessionUseCase startWorkoutSession;
  final PauseWorkoutSessionUseCase pauseWorkoutSession;
  final FinishWorkoutSessionUseCase finishWorkoutSession;
  final GraphQlClient _client;

  void dispose() => _client.close();
}
