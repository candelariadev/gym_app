import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/localization/auth_localizations.dart';

class AdvisedDashboardPage extends StatelessWidget {
  const AdvisedDashboardPage({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoleDashboardTemplate(
      appTitle: l10n.appTitle,
      logoutTooltip: l10n.logoutTooltip,
      greeting: l10n.greeting(session.user),
      roleLabel: l10n.roleLabel(session.role),
      headline: l10n.advisedHeadline,
      quickActionsTitle: l10n.quickActionsTitle,
      onLogout: onLogout,
      metrics: [
        MetricCard(
          label: l10n.advisedWorkouts,
          value: l10n.metricUnavailable,
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF5B5CF6),
        ),
        MetricCard(
          label: l10n.advisedWeeklyStreak,
          value: l10n.metricUnavailable,
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFF05A47),
        ),
        MetricCard(
          label: l10n.advisedProgress,
          value: l10n.metricUnavailable,
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF0C9B75),
        ),
      ],
      content: [
        DashboardActionTile(
          title: l10n.todayWorkoutAction,
          subtitle: l10n.todayWorkoutActionDescription,
          icon: Icons.play_circle_outline_rounded,
        ),
        DashboardActionTile(
          title: l10n.myProgressAction,
          subtitle: l10n.myProgressActionDescription,
          icon: Icons.insights_rounded,
        ),
        DashboardActionTile(
          title: l10n.myTrainerAction,
          subtitle: l10n.myTrainerActionDescription,
          icon: Icons.sports_rounded,
        ),
      ],
    );
  }
}
