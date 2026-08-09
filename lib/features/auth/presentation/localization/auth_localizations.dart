import 'package:gymsas_auth/gymsas_auth.dart';

import '../../../../l10n/app_localizations.dart';

extension AuthLocalizations on AppLocalizations {
  String roleLabel(UserRole role) {
    return switch (role) {
      UserRole.trainer => trainerRole,
      UserRole.advised => advisedRole,
    };
  }

  String errorMessage(AuthErrorCode code) {
    return switch (code) {
      AuthErrorCode.configurationMissing => errorConfigMissing,
      AuthErrorCode.invalidCredentials => errorInvalidCredentials,
      AuthErrorCode.authUnavailable => errorAuthUnavailable,
      AuthErrorCode.server => errorServer,
      AuthErrorCode.invalidResponse => errorInvalidResponse,
      AuthErrorCode.timeout => errorTimeout,
      AuthErrorCode.network => errorNetwork,
      AuthErrorCode.invalidSession => errorInvalidSession,
      AuthErrorCode.incompleteSession => errorIncompleteSession,
      AuthErrorCode.unexpected => errorUnexpected,
    };
  }
}
