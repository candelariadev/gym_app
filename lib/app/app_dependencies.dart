import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:gymsas_payments/gymsas_payments.dart';
import 'package:gymsas_firebase_auth/gymsas_firebase_auth.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

import '../core/config/app_config.dart';
import '../features/workout/application/my_workouts_controller.dart';
import '../features/workout/application/workout_exercise_metadata_resolver.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/workout/application/workout_session_store.dart';
import '../features/payments/application/checkout_controller.dart';
import '../firebase_options.dart';

class AppDependencies {
  AppDependencies({
    required this.config,
    required this.loginUseCase,
    required this.sessionController,
    required this.workoutSessionStore,
    required this.myWorkoutsController,
    required this.getTrainerClientsUseCase,
    required this.getMyTrainersUseCase,
    required this.getTrainerDashboardUseCase,
    required this.getExercisesUseCase,
    required this.assignWorkoutUseCase,
    this.signInWithGoogleUseCase,
    this.completeIndividualOnboardingUseCase,
    this.trace = const DeveloperApiTrace(),
    PaymentsModule? paymentsModule,
    void Function()? onDispose,
  }) : paymentsModule =
           paymentsModule ??
           PaymentsModule.mercadoPago(
             graphQlUrl: config.graphQlUrl,
             publicKey: config.mercadoPagoPublicKey,
             accessTokenProvider: () => sessionController.session?.accessToken,
           ),
       _onDispose = onDispose;

  static Future<AppDependencies> production() async {
    final config = AppConfig.fromEnvironment();
    const trace = DeveloperApiTrace();
    final firebaseProvider = await FirebaseGoogleIdentityProvider.initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final authModule = AuthModule.production(
      graphQlEndpoint: config.graphQlUrl,
      externalIdentityProvider: firebaseProvider,
      trace: trace,
    );
    final sessionController = SessionController(
      sessionRepository: authModule.sessionRepository,
      logoutUseCase: authModule.logoutUseCase,
      trace: trace,
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
      final workoutsModule = WorkoutsModule.production(
        graphQlEndpoint: config.graphQlUrl,
        accessTokenProvider: () => sessionController.session?.accessToken,
        trace: trace,
      );
      return AppDependencies(
        config: config,
        loginUseCase: authModule.loginUseCase,
        sessionController: sessionController,
        workoutSessionStore: WorkoutSessionStore(),
        getTrainerClientsUseCase: clientsModule.getTrainerClientsUseCase,
        getMyTrainersUseCase: clientsModule.getMyTrainersUseCase,
        getTrainerDashboardUseCase: dashboardModule.getTrainerDashboardUseCase,
        getExercisesUseCase: exercisesModule.getExercisesUseCase,
        assignWorkoutUseCase: workoutsModule.assignWorkout,
        myWorkoutsController: MyWorkoutsController(
          getMyWorkouts: workoutsModule.getMyWorkouts,
          getMyWorkoutSessions: workoutsModule.getMyWorkoutSessions,
          startWorkoutSession: workoutsModule.startWorkoutSession,
          pauseWorkoutSession: workoutsModule.pauseWorkoutSession,
          finishWorkoutSession: workoutsModule.finishWorkoutSession,
          exerciseMetadataResolver: WorkoutExerciseMetadataResolver(
            getExercisesUseCase: exercisesModule.getExercisesUseCase,
            exerciseImageBaseUrl: config.graphQlUrl,
          ),
        ),
        signInWithGoogleUseCase: authModule.signInWithGoogleUseCase,
        completeIndividualOnboardingUseCase:
            authModule.completeIndividualOnboardingUseCase,
      trace: trace,
      onDispose: () {
        clientsModule.dispose();
        dashboardModule.dispose();
        exercisesModule.dispose();
        workoutsModule.dispose();
        authModule.dispose();
      },
    );
  }

  final AppConfig config;
  final LoginUseCase loginUseCase;
  final SessionController sessionController;
  final WorkoutSessionStore workoutSessionStore;
  final MyWorkoutsController myWorkoutsController;
  final GetTrainerClientsUseCase getTrainerClientsUseCase;
  final GetMyTrainersUseCase getMyTrainersUseCase;
  final GetTrainerDashboardUseCase getTrainerDashboardUseCase;
  final GetExercisesUseCase getExercisesUseCase;
  final AssignWorkoutUseCase assignWorkoutUseCase;
  final SignInWithGoogleUseCase? signInWithGoogleUseCase;
  final CompleteIndividualOnboardingUseCase?
      completeIndividualOnboardingUseCase;
  final ApiTrace trace;
  final PaymentsModule paymentsModule;
  final void Function()? _onDispose;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  CheckoutController createCheckoutController() =>
      CheckoutController(payments: paymentsModule);

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    sessionController.dispose();
    workoutSessionStore.dispose();
    myWorkoutsController.dispose();
    paymentsModule.dispose();
    _onDispose?.call();
  }
}
