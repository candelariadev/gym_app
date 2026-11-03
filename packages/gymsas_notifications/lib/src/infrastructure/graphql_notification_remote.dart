import 'package:gymsas_api_client/gymsas_api_client.dart';
import '../domain/notification_models.dart';
import '../domain/notification_repository.dart';

class GraphQlNotificationRemote implements NotificationRemote {
  GraphQlNotificationRemote(this.client);
  final GraphQlClient client;
  static const _fields = 'id status updatedAt providerAccepted failureCode';
  Future<Map<String, dynamic>> _call(
    String document,
    Map<String, dynamic> variables,
    String token,
  ) async {
    try {
      return await client.execute(
        document: document,
        variables: variables,
        accessToken: token,
      );
    } on Object catch (error) {
      throw mapNotificationError(error);
    }
  }

  RemoteNotification _notification(dynamic raw) {
    try {
      final d = Map<String, dynamic>.from(raw as Map);
      final state = switch (d['status']) {
        'pending' => NotificationDeliveryState.pending,
        'processing' => NotificationDeliveryState.processing,
        'provider_accepted' => NotificationDeliveryState.providerAccepted,
        'definitively_failed' => NotificationDeliveryState.definitivelyFailed,
        'uncertain' => NotificationDeliveryState.uncertain,
        _ => throw const FormatException('Unknown notification status'),
      };
      final id = d['id'] as String, updatedAt = d['updatedAt'] as String;
      if (id.isEmpty || DateTime.tryParse(updatedAt) == null) {
        throw const FormatException();
      }
      return RemoteNotification(
        id: id,
        state: state,
        updatedAt: updatedAt,
        providerAccepted: d['providerAccepted'] as bool,
        failureCode: d['failureCode'] as String?,
      );
    } on Object {
      throw const NotificationException(NotificationErrorCode.invalidResponse);
    }
  }

  @override
  Future<RemoteNotification> notify(
    ConfirmedRoutineTarget target,
    String language,
    String key,
    String token,
  ) async => _notification(
    (await _call(
      'mutation NotifyRoutineReady(\$input: NotifyRoutineInput!) { notifyRoutineReady(input: \$input) { $_fields } }',
      {
        'input': {
          'routineId': target.routineId,
          'clientId': target.clientId,
          'language': language,
          'idempotencyKey': key,
          'confirm': true,
        },
      },
      token,
    ))['notifyRoutineReady'],
  );
  @override
  Future<RemoteNotification> status(
    String id,
    String token,
  ) async => _notification(
    (await _call(
      'query NotificationStatus(\$id: ID!) { notification(id: \$id) { $_fields } }',
      {'id': id},
      token,
    ))['notification'],
  );
  @override
  Future<RemoteNotification> retry(
    String id,
    bool risk,
    String token,
  ) async => _notification(
    (await _call(
      'mutation RetryNotification(\$id: ID!, \$risk: Boolean!) { retryNotification(id: \$id, acknowledgeDuplicateRisk: \$risk) { $_fields } }',
      {'id': id, 'risk': risk},
      token,
    ))['retryNotification'],
  );
  @override
  Future<NotificationQuota> quota(String token) async {
    final data = await _call(
      'query NotificationQuota { notificationQuota { enabled reason limit remaining reserved providerAccepted resetsAt } }',
      {},
      token,
    );
    try {
      final d = Map<String, dynamic>.from(data['notificationQuota'] as Map);
      final enabled = d['enabled'] as bool;
      final limit = (d['limit'] as num?)?.toInt(),
          remaining = (d['remaining'] as num?)?.toInt();
      if (enabled &&
          (limit == null ||
              remaining == null ||
              limit < -1 ||
              remaining < -1)) {
        throw const FormatException();
      }
      return NotificationQuota(
        enabled: enabled,
        checkedAt: DateTime.now().toUtc(),
        limit: limit,
        remaining: remaining,
        reserved: (d['reserved'] as num?)?.toInt(),
        providerAccepted: (d['providerAccepted'] as num?)?.toInt(),
        resetsAt: d['resetsAt'] == null
            ? null
            : DateTime.parse(d['resetsAt'] as String),
        reason: d['reason'] as String?,
      );
    } on Object {
      throw const NotificationException(NotificationErrorCode.invalidResponse);
    }
  }

  @override
  Future<void> registerDevice(String id, String value, String token) async {
    final result = await _call(
      'mutation RegisterPushDevice(\$id: ID!, \$token: String!) { registerPushDevice(deviceId: \$id, token: \$token) }',
      {'id': id, 'token': value},
      token,
    );
    if (result['registerPushDevice'] != true) {
      throw const NotificationException(NotificationErrorCode.invalidResponse);
    }
  }

  @override
  Future<void> unregisterDevice(String id, String token) async {
    final result = await _call(
      'mutation UnregisterPushDevice(\$id: ID!) { unregisterPushDevice(deviceId: \$id) }',
      {'id': id},
      token,
    );
    if (result['unregisterPushDevice'] != true) {
      throw const NotificationException(NotificationErrorCode.invalidResponse);
    }
  }
}

NotificationException mapNotificationError(Object e) {
  if (e is NotificationException) return e;
  int? status;
  if (e is GraphQlException && e.errors.isNotEmpty) {
    final raw = e.errors.first.extensions['httpStatus'];
    status = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
  }
  if (e is ApiClientException) {
    status = e.statusCode;
    if (status == null) {
      return NotificationException(switch (e.code) {
        ApiClientErrorCode.network ||
        ApiClientErrorCode.timeout => NotificationErrorCode.network,
        ApiClientErrorCode.invalidResponse =>
          NotificationErrorCode.invalidResponse,
        _ => NotificationErrorCode.unavailable,
      });
    }
  }
  return NotificationException(switch (status) {
    400 => NotificationErrorCode.invalidInput,
    401 => NotificationErrorCode.unauthorized,
    403 || 404 => NotificationErrorCode.forbidden,
    409 => NotificationErrorCode.conflict,
    422 => NotificationErrorCode.policyDisabled,
    429 => NotificationErrorCode.quotaExceeded,
    _ => NotificationErrorCode.unavailable,
  });
}
