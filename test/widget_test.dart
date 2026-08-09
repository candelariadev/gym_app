import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app/app_dependencies.dart';
import 'package:gym_app/app/gym_app.dart';
import 'package:gym_app/app/navigation/gym_router.dart';
import 'package:gym_app/core/config/app_config.dart';
import 'package:gym_app/features/auth/presentation/controllers/session_controller.dart';
import 'package:gym_app/features/auth/presentation/pages/login_page.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

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
    expect(find.text('Entrenamiento de hoy'), findsNothing);
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

AppDependencies _dependencies(UserRole role, {void Function()? onDispose}) {
  final sessions = _MemorySessionRepository();
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
    onDispose: onDispose,
  );
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
