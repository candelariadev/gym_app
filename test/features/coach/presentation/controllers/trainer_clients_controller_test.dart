import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/coach/presentation/controllers/trainer_clients_controller.dart';
import 'package:gymsas_clients/gymsas_clients.dart';

void main() {
  test('expone clientes cargados por el caso de uso', () async {
    final controller = TrainerClientsController(
      getTrainerClients: GetTrainerClientsUseCase(_FakeRepository()),
    );

    await controller.load();

    expect(controller.isLoading, isFalse);
    expect(controller.errorCode, isNull);
    expect(controller.clients.single.name, 'Kevin');
    controller.dispose();
  });

  test('expone un codigo estructurado cuando falla el servicio', () async {
    final controller = TrainerClientsController(
      getTrainerClients: GetTrainerClientsUseCase(_FailingRepository()),
    );

    await controller.load();

    expect(controller.clients, isEmpty);
    expect(controller.errorCode, ClientCatalogErrorCode.network);
    controller.dispose();
  });
}

class _FakeRepository implements TrainerClientRepository {
  @override
  Future<List<TrainerClient>> getClients() async => const [
    TrainerClient(
      id: '1',
      ownerId: 'gym',
      name: 'Kevin',
      email: 'kevin@example.com',
      goals: [],
      user: 'kevin',
      assignedTrainers: [],
      assignedWorkouts: [],
      status: 'ACTIVE',
    ),
  ];
}

class _FailingRepository implements TrainerClientRepository {
  @override
  Future<List<TrainerClient>> getClients() {
    throw const ClientCatalogException(ClientCatalogErrorCode.network);
  }
}
