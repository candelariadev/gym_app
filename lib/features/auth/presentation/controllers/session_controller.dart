import 'package:flutter/foundation.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required SessionRepository sessionRepository,
    required LogoutUseCase logoutUseCase,
  }) : _sessionRepository = sessionRepository,
       _logoutUseCase = logoutUseCase;

  final SessionRepository _sessionRepository;
  final LogoutUseCase _logoutUseCase;

  AuthSession? _session;
  bool _isRestoring = true;
  bool _isDisposed = false;

  AuthSession? get session => _session;
  bool get isRestoring => _isRestoring;

  Future<void> restore() async {
    try {
      _session = await _sessionRepository.read();
    } on Object {
      _session = null;
    } finally {
      _isRestoring = false;
      _notifyListeners();
    }
  }

  void authenticated(AuthSession session) {
    _session = session;
    _notifyListeners();
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _session = null;
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
