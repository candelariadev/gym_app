import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notifications_controller.dart';
import 'notification_localizations.dart';
import 'routine_notification_panel.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.controller});
  static const routeName = '/notifications';
  final NotificationsController controller;
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refresh();
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller, l = AppLocalizations.of(context);
      final status = !c.supported
          ? l.pushUnsupported
          : c.deviceRemovalPending
          ? l.pushRemovalPending
          : c.registering
          ? l.pushRegistering
          : c.permission == PushPermission.denied
          ? l.pushDenied
          : !c.pushEnabled
          ? l.pushDisabled
          : c.pushRegistered
          ? l.pushRegistered
          : l.pushWaiting;
      return Scaffold(
        appBar: AppBar(title: Text(l.notificationsTitle)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            children: [
              GymActionStatusCard(
                title: l.pushDeviceTitle,
                status: status,
                detail: c.pushError == null
                    ? null
                    : l.notificationError(c.pushError!),
                busy: c.registering,
                warning:
                    c.pushError != null ||
                    c.permission == PushPermission.denied,
                actionLabel: c.pushEnabled ? l.pushDisable : l.pushEnable,
                onAction: !c.supported
                    ? null
                    : c.pushEnabled
                    ? c.disablePush
                    : c.enablePush,
              ),
              const SizedBox(height: AppSpacing.medium),
              if (c.isTrainer) ...[
                NotificationQuotaSection(controller: c),
                const SizedBox(height: AppSpacing.medium),
                if (c.entries.isEmpty)
                  Text(l.notificationHistoryEmpty)
                else
                  RoutineNotificationPanel(
                    controller: c,
                    showQuota: false,
                    targets: c.entries.map((n) => n.target).toList(),
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
