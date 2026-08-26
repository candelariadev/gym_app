import 'package:flutter/material.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/localization/auth_localizations.dart';
import '../../../workout/application/my_workouts_controller.dart';
import '../../../workout/presentation/pages/workout_calendar_view.dart';

class AdvisedDashboardPage extends StatefulWidget {
  const AdvisedDashboardPage({
    super.key,
    required this.session,
    required this.onLogout,
    required this.onOpenTodayWorkout,
    required this.onOpenMyProgress,
    required this.onOpenMyTrainer,
    required this.myWorkoutsController,
    this.onOpenPlans,
  });

  final AuthSession session;
  final VoidCallback onLogout;
  final VoidCallback onOpenTodayWorkout;
  final VoidCallback onOpenMyProgress;
  final VoidCallback onOpenMyTrainer;
  final MyWorkoutsController myWorkoutsController;
  final VoidCallback? onOpenPlans;

  @override
  State<AdvisedDashboardPage> createState() => _AdvisedDashboardPageState();
}

class _AdvisedDashboardPageState extends State<AdvisedDashboardPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.myWorkoutsController.addListener(_onWorkoutsChanged);
    widget.myWorkoutsController.load();
  }

  @override
  void didUpdateWidget(covariant AdvisedDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.myWorkoutsController == widget.myWorkoutsController) return;
    oldWidget.myWorkoutsController.removeListener(_onWorkoutsChanged);
    widget.myWorkoutsController.addListener(_onWorkoutsChanged);
    widget.myWorkoutsController.load();
  }

  @override
  void dispose() {
    widget.myWorkoutsController.removeListener(_onWorkoutsChanged);
    super.dispose();
  }

  void _onWorkoutsChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      RoleDashboardTemplate(
        appTitle: l10n.appTitle,
        logoutTooltip: l10n.logoutTooltip,
        greeting: l10n.greeting(widget.session.displayName),
        roleLabel: l10n.roleLabel(widget.session.role),
        headline: l10n.advisedHeadline,
        quickActionsTitle: l10n.quickActionsTitle,
        onLogout: widget.onLogout,
        onRefresh: widget.myWorkoutsController.load,
        metrics: [
          MetricCard(
            label: l10n.advisedWorkouts,
            value: '${widget.myWorkoutsController.completedWorkoutsCount}',
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
            onTap: widget.onOpenTodayWorkout,
          ),
          DashboardActionTile(
            title: l10n.myProgressAction,
            subtitle: l10n.myProgressActionDescription,
            icon: Icons.insights_rounded,
            onTap: widget.onOpenMyProgress,
          ),
          DashboardActionTile(
            title: l10n.myTrainerAction,
            subtitle: l10n.myTrainerActionDescription,
            icon: Icons.sports_rounded,
            onTap: widget.onOpenMyTrainer,
          ),
        ],
      ),
      WorkoutCalendarView(
        controller: widget.myWorkoutsController,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          if (index == 2) {
            widget.onOpenPlans?.call();
            return;
          }
          setState(() => _selectedTab = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: l10n.homeTabLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_rounded),
            label: l10n.calendarTabLabel,
          ),
          if (widget.onOpenPlans != null)
            BottomNavigationBarItem(
              icon: const Icon(Icons.workspace_premium_outlined),
              label: l10n.plansTabLabel,
            ),
        ],
      ),
    );
  }
}
