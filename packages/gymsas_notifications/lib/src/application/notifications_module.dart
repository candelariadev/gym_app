import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_offline/gymsas_offline.dart';
import '../domain/notification_models.dart';
import '../domain/notification_repository.dart';
import '../infrastructure/durable_notifications_repository.dart';
import '../infrastructure/graphql_notification_remote.dart';

class NotificationsModule {
  NotificationsModule._(this.repository, this._client, this._durable);
  factory NotificationsModule.production({
    required String graphQlEndpoint,
    required OfflineDocumentStore store,
    required NotificationAccount? Function() account,
    ApiTrace trace = const DeveloperApiTrace(),
  }) {
    final client = HttpGraphQlClient(
      endpoint: graphQlEndpoint,
      trace: trace,
      timeout: const Duration(seconds: 12),
    );
    final repository = DurableNotificationsRepository(
      store: store,
      remote: GraphQlNotificationRemote(client),
      account: account,
    );
    return NotificationsModule._(repository, client, repository);
  }
  final NotificationsRepository repository;
  final GraphQlClient _client;
  final DurableNotificationsRepository _durable;
  void accountChanged() => _durable.accountChanged();
  void dispose() {
    _durable.dispose();
    _client.close();
  }
}
