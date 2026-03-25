import 'package:flutter/material.dart';

import '../../../auth/domain/user_role.dart';
import '../widgets/coach_dashboard_view.dart';
import '../widgets/trainee_dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as UserRole?;
    final effectiveRole = role ?? UserRole.trainee;

    return switch (effectiveRole) {
      UserRole.coach => const CoachDashboardView(),
      UserRole.trainee => const TraineeDashboardView(),
    };
  }
}
