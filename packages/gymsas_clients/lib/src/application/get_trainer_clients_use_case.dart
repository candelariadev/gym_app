import '../domain/entities/trainer_client.dart';
import '../domain/ports/trainer_client_repository.dart';

class GetTrainerClientsUseCase {
  const GetTrainerClientsUseCase(this._repository);

  final TrainerClientRepository _repository;

  Future<List<TrainerClient>> call() => _repository.getClients();
}
