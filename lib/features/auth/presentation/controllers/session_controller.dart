import 'package:flutter/foundation.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required SessionRepository sessionRepository,
    required LogoutUseCase logoutUseCase,
    ApiTrace trace = const DeveloperApiTrace(),
  }) : _sessionRepository = sessionRepository,
       _logoutUseCase = logoutUseCase,
       _trace = trace;

  final SessionRepository _sessionRepository;
  final LogoutUseCase _logoutUseCase;
  final ApiTrace _trace;

  AuthSession? _session;
  bool _isRestoring = true;
  bool _isDisposed = false;

  AuthSession? get session => _session;
  bool get isRestoring => _isRestoring;

  Future<void> restore() async {
    try {
      _session = await _sessionRepository.read();
      _trace.record('session_restore_completed', {
        'has_session': _session != null,
        'role': _session?.role.backendValue,
      });
    } on Object {
      _session = null;
      _trace.record('session_restore_failed', const {});
    } finally {
      _isRestoring = false;
      _notifyListeners();
    }
  }

  void authenticated(AuthSession session) {
    _session = session;
    _trace.record('session_authenticated', {
      'role': session.role.backendValue,
      'destination': session.role == UserRole.trainer ? '/trainer' : '/advised',
    });
    _notifyListeners();
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _session = null;
    _trace.record('session_logout_completed', const {});
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
