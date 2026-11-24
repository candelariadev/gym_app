import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:gymsas_payments/gymsas_payments.dart';
import 'package:gymsas_firebase_auth/gymsas_firebase_auth.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';
import 'package:gymsas_offline/gymsas_offline_flutter.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:gymsas_firebase_messaging/gymsas_firebase_messaging.dart';
import '../features/notifications/application/notifications_controller.dart';
import 'dart:convert';
import '../core/offline/offline_sync_controller.dart';
import '../core/branding/tenant_branding_controller.dart';

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
    this.getWorkoutProgress,
    this.offlineSyncController,
    this.notificationsController,
    this.brandingController,
    this.getConfirmedWorkout,
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
    NotificationsController? notificationsController;
    final sessionController = SessionController(
      sessionRepository: authModule.sessionRepository,
      logoutUseCase: authModule.logoutUseCase,
      trace: trace,
      beforeLogout: () async {
        await notificationsController?.beforeLogout();
      },
    );
    final brandingController = TenantBrandingController(
      client: HttpGraphQlClient(endpoint: config.graphQlUrl, trace: trace),
      session: () {
        final value = sessionController.session;
        return value == null
            ? null
            : (ownerId: value.ownerId, accessToken: value.accessToken);
      },
    );
    final localStore = SerializedOfflineDocumentStore(
      createProductionOfflineStorage(),
    );
    OfflineIdentity? identity() {
      final session = sessionController.session;
      if (session == null) return null;
      return OfflineIdentity(
        scope: jsonEncode([config.graphQlUrl, session.ownerId, session.user]),
        ownerId: session.ownerId,
        userId: session.user,
      );
    }

    OfflineWorkoutRepository? offlineWorkouts;
    NotificationAccount? notificationAccount() {
      final session = sessionController.session;
      if (session == null) return null;
      return NotificationAccount(
        scope: jsonEncode([config.graphQlUrl, session.ownerId, session.user]),
        accessToken: session.accessToken,
        canRequest: !session.isExpired,
        isTrainer: session.role == UserRole.trainer,
      );
    }

    final notificationsModule = NotificationsModule.production(
      graphQlEndpoint: config.graphQlUrl,
      store: localStore,
      account: notificationAccount,
      trace: trace,
    );
    notificationsController = NotificationsController(
      repository: notificationsModule.repository,
      account: notificationAccount,
      push: FirebasePushDevice(),
    );
    final exercisesModule = ExerciseCatalogModule.production(
      graphQlEndpoint: config.graphQlUrl,
      accessTokenProvider: () => sessionController.session?.accessToken,
      queryClient: LocalFirstQueryClient(
        remote: HttpGraphQlClient(endpoint: config.graphQlUrl),
        store: localStore,
        scope: () => identity()?.scope,
        canRequest: () =>
            sessionController.session?.isExpired == false &&
            offlineWorkouts?.state.phase != OfflineSyncPhase.offline,
        cacheable: (document) => document.contains('query Exercises('),
      ),
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
      localStore: localStore,
      identityProvider: identity,
      canSynchronize: () => sessionController.session?.isExpired == false,
    );
    offlineWorkouts = workoutsModule.offlineRepository;
    final workoutStore = WorkoutSessionStore(
      recordPerformance: workoutsModule.recordWorkoutPerformance,
    );
    final myWorkouts = MyWorkoutsController(
      getMyWorkouts: workoutsModule.getMyWorkouts,
      getMyWorkoutSessions: workoutsModule.getMyWorkoutSessions,
      startWorkoutSession: workoutsModule.startWorkoutSession,
      pauseWorkoutSession: workoutsModule.pauseWorkoutSession,
      finishWorkoutSession: workoutsModule.finishWorkoutSession,
      exerciseMetadataResolver: WorkoutExerciseMetadataResolver(
        getExercisesUseCase: exercisesModule.getExercisesUseCase,
        exerciseImageBaseUrl: config.graphQlUrl,
      ),
    );
    final sync = OfflineSyncController(
      workoutsModule.offlineRepository!,
      onDataChanged: () {
        if (sessionController.session != null) myWorkouts.load();
      },
    );
    void onAccountChanged() {
      workoutStore.reset();
      myWorkouts.clear();
      workoutsModule.offlineRepository!.accountChanged();
      notificationsModule.accountChanged();
      notificationsController!.accountChanged();
      brandingController.accountChanged();
    }

    sessionController.addListener(onAccountChanged);
    return AppDependencies(
      config: config,
      loginUseCase: authModule.loginUseCase,
      sessionController: sessionController,
      workoutSessionStore: workoutStore,
      offlineSyncController: sync,
      notificationsController: notificationsController,
      brandingController: brandingController,
      getConfirmedWorkout: workoutsModule.getConfirmedWorkout,
      getWorkoutProgress: workoutsModule.getWorkoutProgress,
      getTrainerClientsUseCase: clientsModule.getTrainerClientsUseCase,
      getMyTrainersUseCase: clientsModule.getMyTrainersUseCase,
      getTrainerDashboardUseCase: dashboardModule.getTrainerDashboardUseCase,
      getExercisesUseCase: exercisesModule.getExercisesUseCase,
      assignWorkoutUseCase: workoutsModule.assignWorkout,
      myWorkoutsController: myWorkouts,
      signInWithGoogleUseCase: authModule.signInWithGoogleUseCase,
      completeIndividualOnboardingUseCase:
          authModule.completeIndividualOnboardingUseCase,
      trace: trace,
      onDispose: () {
        sessionController.removeListener(onAccountChanged);
        clientsModule.dispose();
        dashboardModule.dispose();
        exercisesModule.dispose();
        workoutsModule.dispose();
        notificationsModule.dispose();
        authModule.dispose();
        brandingController.dispose();
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
  final GetWorkoutProgress? getWorkoutProgress;
  final OfflineSyncController? offlineSyncController;
  final NotificationsController? notificationsController;
  final TenantBrandingController? brandingController;
  final GetConfirmedWorkoutUseCase? getConfirmedWorkout;
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
    offlineSyncController?.dispose();
    notificationsController?.dispose();
    sessionController.dispose();
    workoutSessionStore.dispose();
    myWorkoutsController.dispose();
    paymentsModule.dispose();
    _onDispose?.call();
  }
}
