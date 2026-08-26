import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

import '../../features/auth/presentation/controllers/login_form_controller.dart';
import '../../features/auth/presentation/controllers/federated_auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/individual_onboarding_page.dart';
import '../../features/coach/presentation/pages/coach_assign_routine_page.dart';
import '../../features/coach/presentation/pages/coach_client_profile_page.dart';
import '../../features/coach/presentation/pages/coach_clients_page.dart';
import '../../features/coach/presentation/pages/coach_create_routine_page.dart';
import '../../features/coach/presentation/pages/coach_exercise_library_page.dart';
import '../../features/coach/presentation/pages/coach_routine_detail_page.dart';
import '../../features/dashboard/presentation/pages/advised_dashboard_page.dart';
import '../../features/advised/presentation/pages/my_progress_page.dart';
import '../../features/advised/presentation/pages/my_trainers_page.dart';
import '../../features/advised/presentation/pages/my_trainer_detail_page.dart';
import '../../features/dashboard/presentation/pages/trainer_dashboard_page.dart';
import '../../features/workout/presentation/pages/workout_session_page.dart';
import '../../features/workout/presentation/pages/workout_today_page.dart';
import '../../features/payments/presentation/pages/plans_checkout_page.dart';
import '../app_dependencies.dart';

enum GymRoutePath {
  loading('/'),
  login('/login'),
  onboarding('/onboarding'),
  trainer('/trainer'),
  advised('/advised');

  const GymRoutePath(this.location);

  final String location;
}

class GymRouteInformationParser extends RouteInformationParser<GymRoutePath> {
  const GymRouteInformationParser();

  @override
  Future<GymRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final path = routeInformation.uri.path;
    final route = GymRoutePath.values.firstWhere(
      (candidate) => candidate.location == path,
      orElse: () => GymRoutePath.login,
    );
    return SynchronousFuture(route);
  }

  @override
  RouteInformation? restoreRouteInformation(GymRoutePath configuration) {
    return RouteInformation(uri: Uri(path: configuration.location));
  }
}

class GymRouterDelegate extends RouterDelegate<GymRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<GymRoutePath> {
  GymRouterDelegate({required AppDependencies dependencies})
    : _dependencies = dependencies,
      _loginController = LoginFormController(
        loginUseCase: dependencies.loginUseCase,
        ownerId: dependencies.config.ownerId,
      ),
      _federatedController =
          dependencies.signInWithGoogleUseCase == null ||
              dependencies.completeIndividualOnboardingUseCase == null
          ? null
          : FederatedAuthController(
              dependencies.signInWithGoogleUseCase!,
              dependencies.completeIndividualOnboardingUseCase!,
              dependencies.trace,
            ) {
    _dependencies.sessionController.addListener(_onSessionChanged);
    _federatedController?.addListener(_onFederatedFlowChanged);
  }

  final AppDependencies _dependencies;
  final LoginFormController _loginController;
  final FederatedAuthController? _federatedController;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GymRoutePath? _lastTracedRoute;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  GymRoutePath get currentConfiguration {
    final controller = _dependencies.sessionController;
    if (controller.isRestoring) return GymRoutePath.loading;
    if (_federatedController?.needsOnboarding == true &&
        controller.session == null) {
      return GymRoutePath.onboarding;
    }
    return switch (controller.session?.role) {
      UserRole.trainer => GymRoutePath.trainer,
      UserRole.advised => GymRoutePath.advised,
      null => GymRoutePath.login,
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = _dependencies.sessionController;
    final session = controller.session;
    final route = currentConfiguration;
    if (_lastTracedRoute != route) {
      _lastTracedRoute = route;
      _dependencies.trace.record('navigation_route_resolved', {
        'route': route.location,
        'role': session?.role.backendValue,
      });
    }
    final page = switch (route) {
      GymRoutePath.loading => const MaterialPage<void>(
        key: ValueKey('loading'),
        name: '/',
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GymRoutePath.login => MaterialPage<void>(
        key: const ValueKey('login'),
        name: '/login',
        child: LoginPage(
          controller: _loginController,
          onAuthenticated: controller.authenticated,
          federatedController: _federatedController,
        ),
      ),
      GymRoutePath.onboarding => MaterialPage<void>(
        key: const ValueKey('individual-onboarding'),
        name: '/onboarding',
        child: IndividualOnboardingPage(
          controller: _federatedController!,
          onAuthenticated: controller.authenticated,
        ),
      ),
      GymRoutePath.trainer => MaterialPage<void>(
        key: const ValueKey('trainer'),
        name: '/trainer',
        child: TrainerDashboardPage(
          session: session!,
          getTrainerDashboard: _dependencies.getTrainerDashboardUseCase,
          onLogout: controller.logout,
          onOpenClients: () => _pushNamed(CoachClientsPage.routeName),
          onCreateRoutine: () => _pushNamed(CoachCreateRoutinePage.routeName),
          onOpenExerciseCatalog: () =>
              _pushNamed(CoachExerciseLibraryPage.routeName),
          onOpenPlans: session.canManageSubscription
              ? () => _pushNamed(PlansCheckoutPage.routeName)
              : null,
        ),
      ),
      GymRoutePath.advised => MaterialPage<void>(
        key: const ValueKey('advised'),
        name: '/advised',
        child: AdvisedDashboardPage(
          session: session!,
          onLogout: controller.logout,
          onOpenTodayWorkout: () => _pushNamed(WorkoutTodayPage.routeName),
          onOpenMyProgress: () => _pushNamed(MyProgressPage.routeName),
          onOpenMyTrainer: () => _pushNamed(MyTrainersPage.routeName),
          onOpenPlans: session.canManageSubscription
              ? () => _pushNamed(PlansCheckoutPage.routeName)
              : null,
          myWorkoutsController: _dependencies.myWorkoutsController,
        ),
      ),
    };

    return Navigator(
      key: navigatorKey,
      pages: [page],
      onGenerateRoute: _onGenerateFeatureRoute,
      onDidRemovePage: (_) {},
    );
  }

  @override
  Future<void> setNewRoutePath(GymRoutePath configuration) {
    // Session state is the route guard. A URL cannot grant another role.
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() =>
      _navigatorKey.currentState?.maybePop() ?? SynchronousFuture(false);

  Route<dynamic>? _onGenerateFeatureRoute(RouteSettings settings) {
    final session = _dependencies.sessionController.session;
    final role = session?.role;
    if (settings.name == PlansCheckoutPage.routeName) {
      if (session?.canManageSubscription != true) return null;
      return MaterialPageRoute<dynamic>(
        builder: (_) => PlansCheckoutPage(
          controller: _dependencies.createCheckoutController(),
        ),
        settings: settings,
      );
    }
    final builder = switch ((role, settings.name)) {
      (UserRole.trainer, CoachClientProfilePage.routeName) =>
        (_) => const CoachClientProfilePage(),
      (UserRole.trainer, CoachClientsPage.routeName) => (_) => CoachClientsPage(
        getTrainerClients: _dependencies.getTrainerClientsUseCase,
      ),
      (UserRole.trainer, CoachCreateRoutinePage.routeName) =>
        (_) => CoachCreateRoutinePage(
          getExercisesUseCase: _dependencies.getExercisesUseCase,
        ),
      (UserRole.trainer, CoachAssignRoutinePage.routeName) =>
        (_) => CoachAssignRoutinePage(
          getTrainerClients: _dependencies.getTrainerClientsUseCase,
          assignWorkout: _dependencies.assignWorkoutUseCase,
        ),
      (UserRole.trainer, CoachExerciseLibraryPage.routeName) =>
        (_) => CoachExerciseLibraryPage(
          getExercisesUseCase: _dependencies.getExercisesUseCase,
          selectionMode: settings.arguments == true,
        ),
      (UserRole.trainer, CoachRoutineDetailPage.routeName) =>
        (_) => const CoachRoutineDetailPage(),
      (UserRole.advised, WorkoutTodayPage.routeName) => (_) => WorkoutTodayPage(
        myWorkoutsController: _dependencies.myWorkoutsController,
        store: _dependencies.workoutSessionStore,
      ),
      (UserRole.advised, MyProgressPage.routeName) =>
        (_) => const MyProgressPage(),
      (UserRole.advised, WorkoutSessionPage.routeName) =>
        (_) => WorkoutSessionPage(store: _dependencies.workoutSessionStore),
      (UserRole.advised, MyTrainersPage.routeName) => (_) => MyTrainersPage(
        getMyTrainers: _dependencies.getMyTrainersUseCase,
      ),
      (UserRole.advised, MyTrainerDetailPage.routeName) =>
        (_) => const MyTrainerDetailPage(),
      _ => null,
    };

    if (builder == null) return null;
    return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
  }

  void _pushNamed(String routeName, {Object? arguments}) {
    _navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  void _onSessionChanged() {
    if (_dependencies.sessionController.session == null) {
      _dependencies.workoutSessionStore.reset();
      _dependencies.myWorkoutsController.load();
    }
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    notifyListeners();
  }

  void _onFederatedFlowChanged() => notifyListeners();

  @override
  void dispose() {
    _dependencies.sessionController.removeListener(_onSessionChanged);
    _federatedController?.removeListener(_onFederatedFlowChanged);
    _federatedController?.dispose();
    _loginController.dispose();
    super.dispose();
  }
}
