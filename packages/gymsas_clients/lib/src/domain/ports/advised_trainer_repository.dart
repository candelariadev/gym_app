import '../entities/advised_trainer.dart';

abstract interface class AdvisedTrainerRepository {
  Future<List<AdvisedTrainer>> getTrainers();
}

