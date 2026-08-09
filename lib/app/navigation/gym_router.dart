import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

import '../../features/auth/presentation/controllers/login_form_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/advised_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/trainer_dashboard_page.dart';
import '../app_dependencies.dart';

enum GymRoutePath {
  loading('/'),
  login('/login'),
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
      ) {
    _dependencies.sessionController.addListener(_onSessionChanged);
  }

  final AppDependencies _dependencies;
  final LoginFormController _loginController;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  GymRoutePath get currentConfiguration {
    final controller = _dependencies.sessionController;
    if (controller.isRestoring) return GymRoutePath.loading;
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
        ),
      ),
      GymRoutePath.trainer => MaterialPage<void>(
        key: const ValueKey('trainer'),
        name: '/trainer',
        child: TrainerDashboardPage(
          session: session!,
          onLogout: controller.logout,
        ),
      ),
      GymRoutePath.advised => MaterialPage<void>(
        key: const ValueKey('advised'),
        name: '/advised',
        child: AdvisedDashboardPage(
          session: session!,
          onLogout: controller.logout,
        ),
      ),
    };

    return Navigator(key: navigatorKey, pages: [page], onDidRemovePage: (_) {});
  }

  @override
  Future<void> setNewRoutePath(GymRoutePath configuration) {
    // Session state is the route guard. A URL cannot grant another role.
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  void _onSessionChanged() => notifyListeners();

  @override
  void dispose() {
    _dependencies.sessionController.removeListener(_onSessionChanged);
    _loginController.dispose();
    super.dispose();
  }
}
