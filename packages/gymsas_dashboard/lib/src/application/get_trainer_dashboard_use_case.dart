import '../domain/entities/trainer_dashboard.dart';
import '../domain/ports/trainer_dashboard_repository.dart';

class GetTrainerDashboardUseCase {
  const GetTrainerDashboardUseCase(this._repository);

  final TrainerDashboardRepository _repository;

  Future<TrainerDashboard> call() => _repository.getDashboard();
}
