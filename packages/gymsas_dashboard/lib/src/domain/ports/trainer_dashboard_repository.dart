import '../entities/trainer_dashboard.dart';

abstract interface class TrainerDashboardRepository {
  Future<TrainerDashboard> getDashboard();
}
