import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_offline/gymsas_offline.dart';
import 'infrastructure/offline/offline_workout_repository.dart';
import 'domain/ports/workout_repository.dart';
import 'application/get_workout_progress.dart';
import 'application/get_confirmed_workout_use_case.dart';
import 'application/record_workout_performance.dart';
import 'infrastructure/repositories/workout_progress_repository.dart';

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
    required this.getWorkoutProgress,
    required this.recordWorkoutPerformance,
    required this.getConfirmedWorkout,
    required GraphQlClient client,
    this.offlineRepository,
  }) : _client = client;

  factory WorkoutsModule.production({
    required String graphQlEndpoint,
    required String? Function() accessTokenProvider,
    ApiTrace trace = const DeveloperApiTrace(),
    OfflineDocumentStore? localStore,
    OfflineIdentity? Function()? identityProvider,
    bool Function()? canSynchronize,
  }) {
    final client = HttpGraphQlClient(endpoint: graphQlEndpoint, trace: trace);
    final progress = GraphQlWorkoutProgressRepository(
      client,
      accessTokenProvider,
    );
    final repository = WorkoutRepositoryImpl(
      dataSource: WorkoutGraphQlDataSource(client),
      accessTokenProvider: accessTokenProvider,
      errorMapper: const WorkoutErrorMapper(),
      trace: trace,
    );
    final offline = localStore == null || identityProvider == null
        ? null
        : OfflineWorkoutRepository(
            remote: repository,
            performance: progress,
            progress: progress,
            store: localStore,
            identity: identityProvider,
            canSynchronize:
                canSynchronize ?? () => accessTokenProvider() != null,
          );
    final WorkoutRepository reads = offline ?? repository;
    return WorkoutsModule._(
      assignWorkout: AssignWorkoutUseCase(repository),
      getConfirmedWorkout: GetConfirmedWorkoutUseCase(
        repository,
        cache: offline,
      ),
      getMyWorkouts: GetMyWorkoutsUseCase(reads),
      getMyWorkoutSessions: GetMyWorkoutSessionsUseCase(reads),
      startWorkoutSession: StartWorkoutSessionUseCase(reads),
      pauseWorkoutSession: PauseWorkoutSessionUseCase(reads),
      finishWorkoutSession: FinishWorkoutSessionUseCase(reads),
      getWorkoutProgress: GetWorkoutProgress(offline ?? progress),
      recordWorkoutPerformance: RecordWorkoutPerformance(offline ?? progress),
      offlineRepository: offline,
      client: client,
    );
  }

  final AssignWorkoutUseCase assignWorkout;
  final GetConfirmedWorkoutUseCase getConfirmedWorkout;
  final GetMyWorkoutsUseCase getMyWorkouts;
  final GetMyWorkoutSessionsUseCase getMyWorkoutSessions;
  final StartWorkoutSessionUseCase startWorkoutSession;
  final PauseWorkoutSessionUseCase pauseWorkoutSession;
  final FinishWorkoutSessionUseCase finishWorkoutSession;
  final GetWorkoutProgress getWorkoutProgress;
  final RecordWorkoutPerformance recordWorkoutPerformance;
  final GraphQlClient _client;
  final OfflineWorkoutRepository? offlineRepository;

  void dispose() {
    offlineRepository?.dispose();
    _client.close();
  }
}
