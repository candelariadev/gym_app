import 'package:flutter/foundation.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

class FederatedAuthController extends ChangeNotifier {
  FederatedAuthController(this._signIn, this._complete, this._trace);
  final SignInWithGoogleUseCase _signIn;
  final CompleteIndividualOnboardingUseCase _complete;
  final ApiTrace _trace;

  FederatedAuthFlow? _flow;
  bool _loading = false;
  AuthErrorCode? _errorCode;

  FederatedAuthFlow? get flow => _flow;
  bool get needsOnboarding =>
      _flow?.state == FederatedAuthState.onboardingRequired;
  bool get isLoading => _loading;
  AuthErrorCode? get errorCode => _errorCode;

  Future<AuthSession?> signInWithGoogle() async {
    return _run('firebase_sign_in', () async {
      _flow = await _signIn();
      final session = _flow!.sessionForContinuation();
      _trace.record('federated_auth_resolved', {
        'operation': 'firebase_sign_in',
        'state': _flow!.state.name,
        'role': session?.role.backendValue,
      });
      return session;
    });
  }

  Future<AuthSession?> complete(IndividualOnboarding onboarding) async {
    return _run('complete_individual_onboarding', () async {
      _flow = await _complete(onboarding);
      final session = _flow!.sessionForContinuation();
      _trace.record('federated_auth_resolved', {
        'operation': 'complete_individual_onboarding',
        'state': _flow!.state.name,
        'role': session?.role.backendValue,
      });
      return session;
    });
  }

  Future<AuthSession?> _run(
    String operation,
    Future<AuthSession?> Function() action,
  ) async {
    _loading = true;
    _errorCode = null;
    _trace.record('federated_auth_started', {'operation': operation});
    notifyListeners();
    try {
      return await action();
    } on AuthException catch (error) {
      _errorCode = error.code;
      _trace.record('federated_auth_failed', {
        'operation': operation,
        'error_code': error.code.name,
      });
      return null;
    } on Object {
      _errorCode = AuthErrorCode.unexpected;
      _trace.record('federated_auth_failed', {
        'operation': operation,
        'error_code': AuthErrorCode.unexpected.name,
      });
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
