import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_dashboard/gymsas_dashboard.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/localization/auth_localizations.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({
    super.key,
    required this.session,
    required this.getTrainerDashboard,
    required this.onLogout,
    required this.onOpenClients,
    required this.onCreateRoutine,
    required this.onOpenExerciseCatalog,
    this.onOpenPlans,
  });

  final AuthSession session;
  final GetTrainerDashboardUseCase getTrainerDashboard;
  final VoidCallback onLogout;
  final VoidCallback onOpenClients;
  final VoidCallback onCreateRoutine;
  final VoidCallback onOpenExerciseCatalog;
  final VoidCallback? onOpenPlans;

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  late Future<TrainerDashboard> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = widget.getTrainerDashboard();
  }

  Future<void> _refreshDashboard() async {
    final next = widget.getTrainerDashboard();
    setState(() {
      _dashboard = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: FutureBuilder<TrainerDashboard>(
        future: _dashboard,
        builder: (context, snapshot) {
          final dashboard = snapshot.data;
          return RoleDashboardTemplate(
            appTitle: l10n.appTitle,
            logoutTooltip: l10n.logoutTooltip,
            greeting: l10n.greeting(widget.session.displayName),
            roleLabel: l10n.roleLabel(widget.session.role),
            headline: l10n.trainerHeadline,
            quickActionsTitle: l10n.quickActionsTitle,
            onLogout: widget.onLogout,
            onRefresh: _refreshDashboard,
            metrics: [
              MetricCard(
                label: l10n.trainerActiveClients,
                value: _metricValue(dashboard?.activeClients, l10n),
                icon: Icons.groups_rounded,
                color: const Color(0xFF5B5CF6),
              ),
              MetricCard(
                label: l10n.trainerAssignedWorkouts,
                value: _metricValue(dashboard?.assignedWorkouts, l10n),
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF0C9B75),
              ),
            ],
            content: [
              DashboardActionTile(
                title: l10n.trainerClientsAction,
                subtitle: l10n.trainerClientsActionDescription,
                icon: Icons.people_alt_outlined,
                onTap: widget.onOpenClients,
              ),
              DashboardActionTile(
                title: l10n.trainerCreateWorkoutAction,
                subtitle: l10n.trainerCreateWorkoutActionDescription,
                icon: Icons.add_task_rounded,
                onTap: widget.onCreateRoutine,
              ),
              DashboardActionTile(
                title: l10n.exerciseCatalogAction,
                subtitle: l10n.exerciseCatalogActionDescription,
                icon: Icons.menu_book_rounded,
                onTap: widget.onOpenExerciseCatalog,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.onOpenPlans == null
          ? null
          : BottomNavigationBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) widget.onOpenPlans!();
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: l10n.homeTabLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: l10n.plansTabLabel,
                ),
              ],
            ),
    );
  }

  String _metricValue(DashboardMetric? metric, AppLocalizations l10n) {
    if (metric == null || !metric.isAvailable || metric.value == null) {
      return l10n.metricUnavailable;
    }
    return metric.value.toString();
  }
}
