import 'package:gymsas_notifications/gymsas_notifications.dart';
import '../../../l10n/app_localizations.dart';

extension NotificationLocalizations on AppLocalizations {
  String notificationError(NotificationErrorCode code) => switch (code) {
    NotificationErrorCode.network ||
    NotificationErrorCode.unavailable => notificationErrorNetwork,
    NotificationErrorCode.unauthorized => notificationErrorAuth,
    NotificationErrorCode.forbidden => notificationErrorForbidden,
    NotificationErrorCode.quotaExceeded => notificationQuotaExhausted,
    NotificationErrorCode.policyDisabled => notificationQuotaDisabled,
    NotificationErrorCode.conflict => notificationErrorConflict,
    NotificationErrorCode.storage => notificationErrorStorage,
    _ => notificationErrorGeneric,
  };
  String notificationState(NotificationDeliveryState state) => switch (state) {
    NotificationDeliveryState.ready => notificationReady,
    NotificationDeliveryState.queued => notificationQueued,
    NotificationDeliveryState.pending => notificationPending,
    NotificationDeliveryState.processing => notificationProcessing,
    NotificationDeliveryState.providerAccepted => notificationAccepted,
    NotificationDeliveryState.definitivelyFailed => notificationFailed,
    NotificationDeliveryState.uncertain => notificationUncertain,
  };
}
