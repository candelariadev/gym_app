import 'package:flutter/foundation.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

class LoginFormController extends ChangeNotifier {
  LoginFormController({
    required LoginUseCase loginUseCase,
    required String ownerId,
  }) : _loginUseCase = loginUseCase,
       _ownerId = ownerId;

  final LoginUseCase _loginUseCase;
  final String _ownerId;

  bool _isLoading = false;
  AuthErrorCode? _errorCode;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  AuthErrorCode? get errorCode => _errorCode;

  Future<AuthSession?> submit({
    required String user,
    required String password,
  }) async {
    _isLoading = true;
    _errorCode = null;
    _notifyListeners();
    try {
      return await _loginUseCase(
        AuthCredentials(
          ownerId: _ownerId,
          user: user.trim(),
          password: password,
        ),
      );
    } on AuthException catch (error) {
      _errorCode = error.code;
      return null;
    } on Object {
      _errorCode = AuthErrorCode.unexpected;
      return null;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
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
