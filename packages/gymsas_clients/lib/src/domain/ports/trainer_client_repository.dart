import '../entities/trainer_client.dart';

abstract interface class TrainerClientRepository {
  Future<List<TrainerClient>> getClients();
}
