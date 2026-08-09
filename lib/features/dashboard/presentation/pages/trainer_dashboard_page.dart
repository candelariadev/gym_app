import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/localization/auth_localizations.dart';

class TrainerDashboardPage extends StatelessWidget {
  const TrainerDashboardPage({
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
      headline: l10n.trainerHeadline,
      quickActionsTitle: l10n.quickActionsTitle,
      onLogout: onLogout,
      metrics: [
        MetricCard(
          label: l10n.trainerActiveClients,
          value: l10n.metricUnavailable,
          icon: Icons.groups_rounded,
          color: const Color(0xFF5B5CF6),
        ),
        MetricCard(
          label: l10n.trainerAssignedWorkouts,
          value: l10n.metricUnavailable,
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFF0C9B75),
        ),
        MetricCard(
          label: l10n.trainerPending,
          value: l10n.metricUnavailable,
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFFF28C38),
        ),
      ],
      content: [
        DashboardActionTile(
          title: l10n.trainerClientsAction,
          subtitle: l10n.trainerClientsActionDescription,
          icon: Icons.people_alt_outlined,
        ),
        DashboardActionTile(
          title: l10n.trainerCreateWorkoutAction,
          subtitle: l10n.trainerCreateWorkoutActionDescription,
          icon: Icons.add_task_rounded,
        ),
        DashboardActionTile(
          title: l10n.exerciseCatalogAction,
          subtitle: l10n.exerciseCatalogActionDescription,
          icon: Icons.menu_book_rounded,
        ),
      ],
    );
  }
}
