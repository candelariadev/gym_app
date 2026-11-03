enum NotificationErrorCode {
  network,
  unauthorized,
  forbidden,
  quotaExceeded,
  policyDisabled,
  conflict,
  invalidInput,
  storage,
  invalidResponse,
  unavailable,
  unsupported,
}

class NotificationException implements Exception {
  const NotificationException(this.code);
  final NotificationErrorCode code;
}

enum NotificationDeliveryState {
  ready,
  queued,
  pending,
  processing,
  providerAccepted,
  definitivelyFailed,
  uncertain,
}

class ConfirmedRoutineTarget {
  const ConfirmedRoutineTarget({
    required this.routineId,
    required this.clientId,
    required this.clientName,
    required this.routineName,
  });
  final String routineId, clientId, clientName, routineName;
  String get key => '$routineId/$clientId';
  bool get isValid =>
      routineId.isNotEmpty &&
      clientId.isNotEmpty &&
      !routineId.startsWith('local') &&
      !routineId.startsWith('tmp');
}

class RoutineNotification {
  const RoutineNotification({
    required this.target,
    required this.idempotencyKey,
    required this.state,
    required this.language,
    required this.createdAt,
    this.serverId,
    this.serverUpdatedAt,
    this.confirmedAt,
    this.error,
    this.retryBaseUpdatedAt,
    this.providerAccepted = false,
    this.failureCode,
  });
  final ConfirmedRoutineTarget target;
  final String idempotencyKey, language;
  final NotificationDeliveryState state;
  final DateTime createdAt;
  final String? serverId, serverUpdatedAt, retryBaseUpdatedAt, failureCode;
  final DateTime? confirmedAt;
  final NotificationErrorCode? error;
  final bool providerAccepted;
  bool get isWatching =>
      state == NotificationDeliveryState.pending ||
      state == NotificationDeliveryState.processing;
  bool get isTerminal =>
      state == NotificationDeliveryState.providerAccepted ||
      state == NotificationDeliveryState.definitivelyFailed;
  bool get needsSubmit =>
      confirmedAt != null && serverId == null && error == null;
}

class NotificationQuota {
  const NotificationQuota({
    required this.enabled,
    required this.checkedAt,
    this.limit,
    this.remaining,
    this.reserved,
    this.providerAccepted,
    this.resetsAt,
    this.reason,
  });
  final bool enabled;
  final int? limit, remaining, reserved, providerAccepted;
  final DateTime checkedAt;
  final DateTime? resetsAt;
  final String? reason;
  bool get unlimited => limit == -1;
  bool get exhausted => enabled && !unlimited && remaining == 0;
}

// Credenciales sólo en memoria; nunca se serializa este objeto.
class NotificationAccount {
  const NotificationAccount({
    required this.scope,
    required this.accessToken,
    required this.canRequest,
    required this.isTrainer,
  });
  final String scope, accessToken;
  final bool canRequest, isTrainer;
}

class RemoteNotification {
  const RemoteNotification({
    required this.id,
    required this.state,
    required this.updatedAt,
    required this.providerAccepted,
    this.failureCode,
  });
  final String id, updatedAt;
  final NotificationDeliveryState state;
  final bool providerAccepted;
  final String? failureCode;
}
