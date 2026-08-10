import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

import '../core/config/app_config.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/workout/application/workout_session_store.dart';
import '../features/workout/infrastructure/workout_demo_data.dart';

class AppDependencies {
  AppDependencies({
    required this.config,
    required this.loginUseCase,
    required this.sessionController,
    required this.workoutSessionStore,
    required this.getTrainerClientsUseCase,
    required this.getTrainerDashboardUseCase,
    required this.getExercisesUseCase,
    void Function()? onDispose,
  }) : _onDispose = onDispose;

  factory AppDependencies.production() {
    final config = AppConfig.fromEnvironment();
    final authModule = AuthModule.production(
      graphQlEndpoint: config.graphQlUrl,
    );
    final sessionController = SessionController(
      sessionRepository: authModule.sessionRepository,
      logoutUseCase: authModule.logoutUseCase,
    );
    final exercisesModule = ExerciseCatalogModule.production(
      graphQlEndpoint: config.graphQlUrl,
      accessTokenProvider: () => sessionController.session?.accessToken,
    );
    final clientsModule = TrainerClientsModule.production(
      graphQlEndpoint: config.graphQlUrl,
      accessTokenProvider: () => sessionController.session?.accessToken,
    );
    final dashboardModule = TrainerDashboardModule.production(
      graphQlEndpoint: config.graphQlUrl,
      accessTokenProvider: () => sessionController.session?.accessToken,
    );
    return AppDependencies(
      config: config,
      loginUseCase: authModule.loginUseCase,
      sessionController: sessionController,
      workoutSessionStore: WorkoutSessionStore(
        initialSession: WorkoutDemoData.session,
      ),
      getTrainerClientsUseCase: clientsModule.getTrainerClientsUseCase,
      getTrainerDashboardUseCase: dashboardModule.getTrainerDashboardUseCase,
      getExercisesUseCase: exercisesModule.getExercisesUseCase,
      onDispose: () {
        clientsModule.dispose();
        dashboardModule.dispose();
        exercisesModule.dispose();
        authModule.dispose();
      },
    );
  }

  final AppConfig config;
  final LoginUseCase loginUseCase;
  final SessionController sessionController;
  final WorkoutSessionStore workoutSessionStore;
  final GetTrainerClientsUseCase getTrainerClientsUseCase;
  final GetTrainerDashboardUseCase getTrainerDashboardUseCase;
  final GetExercisesUseCase getExercisesUseCase;
  final void Function()? _onDispose;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    sessionController.dispose();
    workoutSessionStore.dispose();
    _onDispose?.call();
  }
}
