import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app/app_dependencies.dart';
import 'package:gym_app/app/gym_app.dart';
import 'package:gym_app/app/navigation/gym_router.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:gym_app/features/auth/presentation/pages/login_page.dart';
import 'package:gym_app/features/workout/application/my_workouts_controller.dart';
import 'package:gym_app/features/workout/application/workout_exercise_metadata_resolver.dart';
import 'package:gym_app/features/workout/application/workout_session_store.dart';
import 'package:gym_app/features/workout/infrastructure/workout_demo_data.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_clients/gymsas_clients.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

void main() {
  testWidgets('valida usuario y contrasena vacios', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.advised),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu usuario'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('muestra la experiencia firmada del entrenador', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.trainer),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'coach_demo');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('ENTRENADOR'), findsOneWidget);
    expect(find.text('Mis asesorados'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Pendientes'), findsNothing);
    expect(find.text('Entrenamiento de hoy'), findsNothing);
  });

  testWidgets('abre el flujo modular de rutinas del entrenador', (
    tester,
  ) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.trainer),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'coach_demo');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Crear rutina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear rutina'));
    await tester.pumpAndSettle();

    expect(find.text('Guardar rutina'), findsOneWidget);
    expect(find.text('Nombre de la rutina'), findsOneWidget);
  });

  testWidgets('muestra la experiencia firmada del asesorado', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.advised),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'advised_demo');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('ASESORADO'), findsOneWidget);
    expect(find.text('Entrenamiento de hoy'), findsOneWidget);
    expect(find.text('Mis asesorados'), findsNothing);
    expect(find.text('Planes'), findsNothing);
  });

  testWidgets('OAuth existente redirige segun el rol devuelto por el BFF', (
    tester,
  ) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(
          UserRole.trainer,
          federatedRole: UserRole.advised,
        ),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();

    expect(find.text('ASESORADO'), findsOneWidget);
    expect(find.text('Entrenamiento de hoy'), findsOneWidget);
    expect(find.text('ENTRENADOR'), findsNothing);
    expect(find.text('Planes'), findsOneWidget);
  });

  testWidgets('abre el listado modular de rutinas asignadas', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.advised),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'advised_demo');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Entrenamiento de hoy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrenamiento de hoy'));
    await tester.pumpAndSettle();

    expect(find.text('Rutinas asignadas'), findsOneWidget);
    expect(find.text('Aún no tienes rutinas asignadas.'), findsOneWidget);
  });

  testWidgets('presenta la interfaz en ingles', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.advised),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('una ruta profunda no omite el guard de sesion', (tester) async {
    await tester.pumpWidget(
      GymApp(
        dependencies: _dependencies(UserRole.advised),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    final router = Router.of(tester.element(find.byType(LoginPage)));
    final delegate = router.routerDelegate as GymRouterDelegate;
    await delegate.setNewRoutePath(GymRoutePath.trainer);
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('ENTRENADOR'), findsNothing);
  });

  testWidgets('GymApp libera las dependencias que posee', (tester) async {
    var moduleDisposed = false;
    final dependencies = _dependencies(
      UserRole.advised,
      onDispose: () => moduleDisposed = true,
    );
    await tester.pumpWidget(
      GymApp(dependencies: dependencies, locale: const Locale('es')),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());

    expect(dependencies.isDisposed, isTrue);
    expect(moduleDisposed, isTrue);
  });
}

AppDependencies _dependencies(
  UserRole role, {
  UserRole? federatedRole,
  void Function()? onDispose,
}) {
  final sessions = _MemorySessionRepository();
  final identityProvider = _FakeExternalIdentityProvider();
  final federatedRepository = federatedRole == null
      ? null
      : _FakeFederatedAuthRepository(federatedRole);
  return AppDependencies(
    config: const AppConfig(
      graphQlUrl: 'http://localhost/graphql',
      ownerId: 'tenant_1',
    ),
    loginUseCase: LoginUseCase(
      authRepository: _FakeAuthRepository(role),
      sessionRepository: sessions,
    ),
    sessionController: SessionController(
      sessionRepository: sessions,
      logoutUseCase: LogoutUseCase(sessions),
    ),
    workoutSessionStore: WorkoutSessionStore(
      initialSession: WorkoutDemoData.session,
    ),
    getTrainerClientsUseCase: GetTrainerClientsUseCase(
      _FakeTrainerClientRepository(),
    ),
    getMyTrainersUseCase: GetMyTrainersUseCase(_FakeAdvisedTrainerRepository()),
    getTrainerDashboardUseCase: GetTrainerDashboardUseCase(
      _FakeTrainerDashboardRepository(),
    ),
    getExercisesUseCase: GetExercisesUseCase(_FakeExerciseCatalogRepository()),
    assignWorkoutUseCase: AssignWorkoutUseCase(_FakeWorkoutRepository()),
    myWorkoutsController: MyWorkoutsController(
      getMyWorkouts: GetMyWorkoutsUseCase(_FakeWorkoutRepository()),
      getMyWorkoutSessions: GetMyWorkoutSessionsUseCase(
        _FakeWorkoutRepository(),
      ),
      startWorkoutSession: StartWorkoutSessionUseCase(_FakeWorkoutRepository()),
      pauseWorkoutSession: PauseWorkoutSessionUseCase(_FakeWorkoutRepository()),
      finishWorkoutSession: FinishWorkoutSessionUseCase(
        _FakeWorkoutRepository(),
      ),
      exerciseMetadataResolver: WorkoutExerciseMetadataResolver(
        getExercisesUseCase: GetExercisesUseCase(
          _FakeExerciseCatalogRepository(),
        ),
      ),
    ),
    signInWithGoogleUseCase: federatedRepository == null
        ? null
        : SignInWithGoogleUseCase(
            identityProvider,
            federatedRepository,
            sessions,
          ),
    completeIndividualOnboardingUseCase: federatedRepository == null
        ? null
        : CompleteIndividualOnboardingUseCase(
            identityProvider,
            federatedRepository,
            sessions,
          ),
    onDispose: onDispose,
  );
}

class _FakeExternalIdentityProvider implements ExternalIdentityProvider {
  @override
  Future<String> signInWithGoogle() async => 'firebase-id-token';

  @override
  Future<String> refreshIdToken() async => 'refreshed-firebase-id-token';

  @override
  Future<void> signOut() async {}
}

class _FakeFederatedAuthRepository implements FederatedAuthRepository {
  const _FakeFederatedAuthRepository(this.role);

  final UserRole role;

  @override
  Future<FederatedAuthFlow> signIn(String idToken) async => _flow();

  @override
  Future<FederatedAuthFlow> completeOnboarding(
    IndividualOnboarding onboarding,
  ) async => _flow();

  FederatedAuthFlow _flow() {
    final session = AuthSession(
      accessToken: 'access',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshToken: 'refresh',
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 1)),
      ownerId: 'individual-account',
      user: 'oauth-user',
      role: role,
      nickname: 'Kevin',
      firebaseUid: 'firebase-uid',
      plan: 'INDIVIDUAL',
    );
    return FederatedAuthFlow(
      state: FederatedAuthState.authenticated,
      identity: FederatedIdentity(
        uid: 'firebase-uid',
        email: 'user@example.com',
        name: 'Kevin',
        nickname: 'Kevin',
        role: role.backendValue,
        onboardingCompleted: true,
      ),
      session: session,
    );
  }
}

class _FakeTrainerDashboardRepository implements TrainerDashboardRepository {
  @override
  Future<TrainerDashboard> getDashboard() async => TrainerDashboard(
    activeClients: const DashboardMetric(
      value: 2,
      status: DashboardMetricStatus.available,
    ),
    assignedWorkouts: const DashboardMetric(
      value: 4,
      status: DashboardMetricStatus.available,
    ),
    generatedAt: DateTime.utc(2026, 8, 9),
  );
}

class _FakeTrainerClientRepository implements TrainerClientRepository {
  @override
  Future<List<TrainerClient>> getClients() async => const [];
}

class _FakeAdvisedTrainerRepository implements AdvisedTrainerRepository {
  @override
  Future<List<AdvisedTrainer>> getTrainers() async => const [];
}

class _FakeExerciseCatalogRepository implements ExerciseCatalogRepository {
  @override
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request) async {
    return ExerciseCatalogPage(
      items: const [],
      page: request.page,
      size: request.size,
      total: 0,
      totalPages: 0,
    );
  }
}

class _FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<Workout> assign(AssignWorkoutCommand command) async => Workout(
    routineId: 'routine-1',
    userId: command.userId,
    name: command.name,
    status: 'ACTIVE',
  );

  @override
  Future<List<Workout>> getMyWorkouts({bool? activeOnly}) async => const [];

  @override
  Future<List<WorkoutSession>> getMyWorkoutSessions({bool? activeOnly}) async =>
      const [];

  @override
  Future<WorkoutSession> startWorkoutSession(
    StartWorkoutSessionCommand command,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<WorkoutSession> pauseWorkoutSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<WorkoutSession> finishWorkoutSession(String sessionId) {
    throw UnimplementedError();
  }
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.role);

  final UserRole role;

  @override
  Future<AuthSession> login(AuthCredentials credentials) async {
    return AuthSession(
      accessToken: 'access',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshToken: 'refresh',
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 1)),
      ownerId: credentials.ownerId,
      user: credentials.user,
      role: role,
    );
  }
}

class _MemorySessionRepository implements SessionRepository {
  AuthSession? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<AuthSession?> read() async => value;

  @override
  Future<void> save(AuthSession session) async => value = session;
}
