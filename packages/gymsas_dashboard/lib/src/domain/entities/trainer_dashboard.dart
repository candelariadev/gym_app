import 'dashboard_metric.dart';

class TrainerDashboard {
  const TrainerDashboard({
    required this.activeClients,
    required this.assignedWorkouts,
    required this.generatedAt,
  });

  final DashboardMetric activeClients;
  final DashboardMetric assignedWorkouts;
  final DateTime generatedAt;
}
