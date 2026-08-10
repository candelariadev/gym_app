import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../dto/trainer_client_dto.dart';

class TrainerClientsGraphQlDataSource {
  const TrainerClientsGraphQlDataSource(this._client);

  static const document = r'''
    query TrainerClients {
      clients {
        id
        ownerId
        name
        email
        birthdate
        gender
        weight
        goals
        notes
        user
        status
        createdAt
        updatedAt
        assignedTrainers { userId assignedAt }
        assignedWorkouts {
          routineId
          ownerId
          callerId
          userId
          name
          days {
            day
            exercises { exerciseId sets reps restSeconds notes }
          }
          startDate
          durationWeeks
          notes
          status
          createdAt
        }
      }
    }
  ''';

  final GraphQlClient _client;

  Future<List<TrainerClientDto>> getClients({
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: document,
      accessToken: accessToken,
    );
    final rawClients = data['clients'];
    if (rawClients is! List) throw const FormatException('clients');
    return rawClients
        .map((raw) {
          if (raw is! Map<String, dynamic>) {
            throw const FormatException('client');
          }
          return TrainerClientDto.fromJson(raw);
        })
        .toList(growable: false);
  }
}
