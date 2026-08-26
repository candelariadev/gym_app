import '../domain/entities/advised_trainer.dart';
import '../domain/ports/advised_trainer_repository.dart';

class GetMyTrainersUseCase {
  const GetMyTrainersUseCase(this._repository);

  final AdvisedTrainerRepository _repository;

  Future<List<AdvisedTrainer>> call() => _repository.getTrainers();
}

