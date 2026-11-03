import 'package:flutter/material.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_notifications/gymsas_notifications.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../application/notifications_controller.dart';
import 'notification_localizations.dart';

class NotificationQuotaSection extends StatelessWidget {
  const NotificationQuotaSection({super.key, required this.controller});
  final NotificationsController controller;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), q = controller.quota;
    final status = controller.loadingQuota
        ? l.notificationQuotaLoading
        : q == null
        ? l.notificationQuotaUnavailable
        : !q.enabled
        ? l.notificationQuotaDisabled
        : q.unlimited
        ? l.notificationQuotaUnlimited
        : q.exhausted
        ? l.notificationQuotaExhausted
        : l.notificationQuotaRemaining(q.remaining ?? 0, q.reserved ?? 0);
    final details = [
      if (q != null && !controller.quotaFresh) l.notificationQuotaStale,
      if (q?.resetsAt != null)
        l.notificationQuotaReset(
          DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_Hm().format(q!.resetsAt!.toUtc()),
        ),
    ];
    return GymActionStatusCard(
      title: l.notificationQuotaTitle,
      status: status,
      detail: details.isEmpty ? null : details.join('\n'),
      busy: controller.loadingQuota,
      warning:
          !controller.quotaFresh || q?.enabled != true || q?.exhausted == true,
      actionLabel: l.notificationRefresh,
      onAction: () => controller.refresh(),
    );
  }
}

class RoutineNotificationPanel extends StatelessWidget {
  const RoutineNotificationPanel({
    super.key,
    required this.controller,
    required this.targets,
    this.showQuota = true,
  });
  final NotificationsController controller;
  final List<ConfirmedRoutineTarget> targets;
  final bool showQuota;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showQuota) ...[
            NotificationQuotaSection(controller: controller),
            const SizedBox(height: AppSpacing.medium),
          ],
          if (controller.error != null) ...[
            GymStatusMessage(
              label: l.notificationError(controller.error!),
              warning: true,
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          for (final target in targets) ...[
            _card(context, target),
            const SizedBox(height: AppSpacing.medium),
          ],
        ],
      );
    },
  );
  Widget _card(BuildContext context, ConfirmedRoutineTarget target) {
    final l = AppLocalizations.of(context),
        n = controller.entry(target.key),
        q = controller.quota;
    final state = n?.state ?? NotificationDeliveryState.ready;
    final ready = state == NotificationDeliveryState.ready;
    final canConfirm =
        ready && q?.enabled == true && !(controller.quotaFresh && q!.exhausted);
    final retry =
        n != null &&
        n.confirmedAt != null &&
        !n.providerAccepted &&
        (n.error != null ||
            state == NotificationDeliveryState.definitivelyFailed ||
            state == NotificationDeliveryState.uncertain);
    return GymActionStatusCard(
      key: ValueKey('notification-${target.key}'),
      title: target.clientName,
      subtitle: target.routineName,
      status: n?.providerAccepted == true
          ? l.notificationAccepted
          : l.notificationState(state),
      detail: n?.error != null
          ? l.notificationError(n!.error!)
          : n?.failureCode == 'no_devices'
          ? l.notificationNoDevices
          : null,
      busy: controller.busy.contains(target.key),
      warning:
          n?.error != null ||
          state == NotificationDeliveryState.uncertain ||
          state == NotificationDeliveryState.definitivelyFailed,
      actionLabel: ready
          ? l.notificationNotifyClient
          : retry
          ? l.notificationRetry
          : null,
      onAction: canConfirm
          ? () => _confirm(context, target)
          : retry
          ? () => _retry(context, n)
          : null,
    );
  }

  Future<void> _confirm(
    BuildContext context,
    ConfirmedRoutineTarget target,
  ) async {
    final l = AppLocalizations.of(context),
        language = Localizations.localeOf(context).languageCode;
    final consent = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.notificationConfirmTitle),
        content: Text(l.notificationConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.notificationCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.notificationConfirm),
          ),
        ],
      ),
    );
    if (consent == true && context.mounted) {
      await controller.confirm(target, language);
    }
  }

  Future<void> _retry(BuildContext context, RoutineNotification n) async {
    var risk = false;
    if (n.state == NotificationDeliveryState.uncertain) {
      final l = AppLocalizations.of(context);
      risk =
          await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l.notificationRiskTitle),
              content: Text(l.notificationRiskBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(l.notificationCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(l.notificationRetry),
                ),
              ],
            ),
          ) ==
          true;
      if (!risk) return;
    }
    if (context.mounted) {
      await controller.retry(n, acknowledgeDuplicateRisk: risk);
    }
  }
}
