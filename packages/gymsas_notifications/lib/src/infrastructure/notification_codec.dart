import '../domain/notification_models.dart';

class NotificationCodec {
  static Map<String, dynamic> write(RoutineNotification n) => {
    'routineId': n.target.routineId,
    'clientId': n.target.clientId,
    'clientName': n.target.clientName,
    'routineName': n.target.routineName,
    'key': n.idempotencyKey,
    'state': n.state.name,
    'language': n.language,
    'createdAt': n.createdAt.toUtc().toIso8601String(),
    'serverId': n.serverId,
    'serverUpdatedAt': n.serverUpdatedAt,
    'confirmedAt': n.confirmedAt?.toUtc().toIso8601String(),
    'error': n.error?.name,
    'retryBaseUpdatedAt': n.retryBaseUpdatedAt,
    'providerAccepted': n.providerAccepted,
    'failureCode': n.failureCode,
  };
  static RoutineNotification read(Map<String, dynamic> d) =>
      RoutineNotification(
        target: ConfirmedRoutineTarget(
          routineId: d['routineId'] as String,
          clientId: d['clientId'] as String,
          clientName: d['clientName'] as String,
          routineName: d['routineName'] as String,
        ),
        idempotencyKey: d['key'] as String,
        state: NotificationDeliveryState.values.byName(d['state'] as String),
        language: d['language'] as String,
        createdAt: DateTime.parse(d['createdAt'] as String),
        serverId: d['serverId'] as String?,
        serverUpdatedAt: d['serverUpdatedAt'] as String?,
        confirmedAt: d['confirmedAt'] == null
            ? null
            : DateTime.parse(d['confirmedAt'] as String),
        error: d['error'] == null
            ? null
            : NotificationErrorCode.values.byName(d['error'] as String),
        retryBaseUpdatedAt: d['retryBaseUpdatedAt'] as String?,
        providerAccepted: d['providerAccepted'] as bool? ?? false,
        failureCode: d['failureCode'] as String?,
      );
  static Map<String, dynamic> writeQuota(NotificationQuota q) => {
    'enabled': q.enabled,
    'checkedAt': q.checkedAt.toUtc().toIso8601String(),
    'limit': q.limit,
    'remaining': q.remaining,
    'reserved': q.reserved,
    'providerAccepted': q.providerAccepted,
    'resetsAt': q.resetsAt?.toUtc().toIso8601String(),
    'reason': q.reason,
  };
  static NotificationQuota readQuota(Map<String, dynamic> d) =>
      NotificationQuota(
        enabled: d['enabled'] as bool,
        checkedAt: DateTime.parse(d['checkedAt'] as String),
        limit: (d['limit'] as num?)?.toInt(),
        remaining: (d['remaining'] as num?)?.toInt(),
        reserved: (d['reserved'] as num?)?.toInt(),
        providerAccepted: (d['providerAccepted'] as num?)?.toInt(),
        resetsAt: d['resetsAt'] == null
            ? null
            : DateTime.parse(d['resetsAt'] as String),
        reason: d['reason'] as String?,
      );
}
