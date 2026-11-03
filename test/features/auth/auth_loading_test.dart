import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/auth/presentation/controllers/federated_auth_controller.dart';
import 'package:gym_app/features/auth/presentation/controllers/login_form_controller.dart';
import 'package:gym_app/features/auth/presentation/pages/login_page.dart';
import 'package:gym_app/features/auth/presentation/pages/individual_onboarding_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets(
    'Google mantiene el loader durante Firebase, BFF y persistencia',
    (tester) async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      await tester.pumpWidget(harness.app());
      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();
      expect(find.text('Conectando con Google…'), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
      expect(await harness.federated.signInWithGoogle(), isNull);
      expect(harness.provider.calls, 1);

      harness.provider.result.complete('token');
      await tester.pump();
      expect(harness.repository.calls, 1);
      expect(find.text('Conectando con Google…'), findsOneWidget);
      harness.repository.result.complete(_flow());
      await tester.pump();
      expect(harness.sessions.saveCalls, 1);
      expect(find.text('Conectando con Google…'), findsOneWidget);
      expect(harness.authenticated, isNull);

      harness.sessions.saved.complete();
      await tester.pumpAndSettle();
      expect(find.text('Conectando con Google…'), findsNothing);
      expect(harness.authenticated, isNotNull);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isTrue);
    },
  );

  testWidgets('un error de Google se muestra y permite reintentar', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.tap(find.text('Continuar con Google'));
    await tester.pump();
    harness.provider.result.completeError(
      const AuthException(AuthErrorCode.network),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GymLoadingStatus), findsNothing);
    final l10n = AppLocalizations.of(tester.element(find.byType(LoginPage)));
    expect(find.text(l10n.errorNetwork), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );

    harness.provider.result = Completer<String>();
    await tester.ensureVisible(find.text('Continuar con Google'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar con Google'));
    await tester.pump();
    expect(find.text(l10n.errorNetwork), findsNothing);
    expect(find.text('Conectando con Google…'), findsOneWidget);
    harness.provider.result.complete('retry-token');
    harness.repository.result.complete(_flow());
    harness.sessions.saved.complete();
    await tester.pumpAndSettle();
    expect(harness.authenticated, isNotNull);
    expect(harness.provider.calls, 2);
  });

  testWidgets('login normal bloquea duplicados y Google mientras espera', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app());
    await tester.enterText(find.byType(TextFormField).at(0), 'tester');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Iniciando sesión…'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(
      await harness.login.submit(user: 'tester', password: '123456'),
      isNull,
    );
    expect(harness.password.calls, 1);
    harness.password.result.completeError(
      const AuthException(AuthErrorCode.invalidCredentials),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GymLoadingStatus), findsNothing);
    expect(find.text('Usuario o contraseña incorrectos'), findsOneWidget);
  });

  testWidgets('el loader de Google se localiza en ingles', (tester) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(harness.app(locale: const Locale('en')));
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(find.text('Connecting to Google…'), findsOneWidget);
    harness.provider.result.completeError(
      const AuthException(AuthErrorCode.network),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GymLoadingStatus), findsNothing);
  });

  testWidgets('registro conserva el loader hasta guardar la sesion', (
    tester,
  ) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: IndividualOnboardingPage(
          controller: harness.federated,
          onAuthenticated: (_) {},
        ),
      ),
    );
    final pending = harness.federated.complete(
      const IndividualOnboarding(
        idToken: '',
        nickname: 'Test',
        password: '123456',
        role: UserRole.trainer,
      ),
    );
    await tester.pump();
    expect(find.text('Creando tu cuenta…'), findsWidgets);
    expect(
      tester
          .widget<GymLoadingOverlay>(find.byType(GymLoadingOverlay))
          .isLoading,
      isTrue,
    );
    harness.provider.result.complete('token');
    harness.repository.result.complete(_flow());
    await tester.pump();
    expect(harness.sessions.saveCalls, 1);
    expect(
      tester
          .widget<GymLoadingOverlay>(find.byType(GymLoadingOverlay))
          .isLoading,
      isTrue,
    );
    harness.sessions.saved.complete();
    expect(await pending, isNotNull);
    await tester.pumpAndSettle();
    expect(find.byType(GymLoadingStatus), findsNothing);
  });

  test(
    'finalizar despues de dispose no notifica un controlador destruido',
    () async {
      final harness = _Harness();
      final pending = harness.federated.signInWithGoogle();
      harness.dispose();
      harness.provider.result.completeError(
        const AuthException(AuthErrorCode.network),
      );
      expect(await pending, isNull);
    },
  );
}

class _Harness {
  final provider = _Provider();
  final repository = _FederatedRepository();
  final sessions = _Sessions();
  final password = _PasswordRepository();
  late final federated = FederatedAuthController(
    SignInWithGoogleUseCase(provider, repository, sessions),
    CompleteIndividualOnboardingUseCase(provider, repository, sessions),
    const NoopApiTrace(),
  );
  late final login = LoginFormController(
    loginUseCase: LoginUseCase(
      authRepository: password,
      sessionRepository: sessions,
    ),
    ownerId: 'tenant',
  );
  AuthSession? authenticated;

  Widget app({Locale locale = const Locale('es')}) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LoginPage(
      controller: login,
      federatedController: federated,
      onAuthenticated: (session) => authenticated = session,
    ),
  );

  void dispose() {
    login.dispose();
    federated.dispose();
  }
}

class _Provider implements ExternalIdentityProvider {
  var result = Completer<String>();
  int calls = 0;
  @override
  Future<String> signInWithGoogle() {
    calls++;
    return result.future;
  }

  @override
  Future<String> refreshIdToken() => result.future;
  @override
  Future<void> signOut() async {}
}

class _FederatedRepository implements FederatedAuthRepository {
  final result = Completer<FederatedAuthFlow>();
  int calls = 0;
  @override
  Future<FederatedAuthFlow> signIn(String idToken) {
    calls++;
    return result.future;
  }

  @override
  Future<FederatedAuthFlow> completeOnboarding(
    IndividualOnboarding onboarding,
  ) => result.future;
}

class _PasswordRepository implements AuthRepository {
  final result = Completer<AuthSession>();
  int calls = 0;
  @override
  Future<AuthSession> login(AuthCredentials credentials) {
    calls++;
    return result.future;
  }
}

class _Sessions implements SessionRepository {
  final saved = Completer<void>();
  int saveCalls = 0;
  @override
  Future<void> save(AuthSession session) {
    saveCalls++;
    return saved.future;
  }

  @override
  Future<AuthSession?> read() async => null;
  @override
  Future<void> clear() async {}
}

FederatedAuthFlow _flow() => FederatedAuthFlow(
  state: FederatedAuthState.authenticated,
  identity: const FederatedIdentity(
    uid: 'uid',
    email: 'user@example.com',
    name: 'Test',
    onboardingCompleted: true,
    role: 'ADVISED',
  ),
  session: AuthSession(
    accessToken: 'access',
    accessTokenExpiresAt: DateTime(2030),
    refreshToken: 'refresh',
    refreshTokenExpiresAt: DateTime(2030),
    ownerId: 'tenant',
    user: 'tester',
    role: UserRole.advised,
  ),
);
