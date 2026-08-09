import 'package:gymsas_auth/gymsas_auth.dart';

import '../core/config/app_config.dart';
import '../features/auth/presentation/controllers/session_controller.dart';

class AppDependencies {
  AppDependencies({
    required this.config,
    required this.loginUseCase,
    required this.sessionController,
    void Function()? onDispose,
  }) : _onDispose = onDispose;

  factory AppDependencies.production() {
    final config = AppConfig.fromEnvironment();
    final authModule = AuthModule.production(
      graphQlEndpoint: config.graphQlUrl,
    );
    return AppDependencies(
      config: config,
      loginUseCase: authModule.loginUseCase,
      sessionController: SessionController(
        sessionRepository: authModule.sessionRepository,
        logoutUseCase: authModule.logoutUseCase,
      ),
      onDispose: authModule.dispose,
    );
  }

  final AppConfig config;
  final LoginUseCase loginUseCase;
  final SessionController sessionController;
  final void Function()? _onDispose;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    sessionController.dispose();
    _onDispose?.call();
  }
}
