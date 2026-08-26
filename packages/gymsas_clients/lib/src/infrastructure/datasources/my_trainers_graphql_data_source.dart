import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../dto/my_trainer_dto.dart';

class MyTrainersGraphQlDataSource {
  const MyTrainersGraphQlDataSource(this._client);

  static const document = r'''
    query MyTrainers {
      myTrainers {
        user
        name
        email
        plan
        status
        profile {
          bio
          certifications
          experience
        }
      }
    }
  ''';

  final GraphQlClient _client;

  Future<List<MyTrainerDto>> getTrainers({required String accessToken}) async {
    final data = await _client.execute(
      document: document,
      accessToken: accessToken,
    );
    final rawTrainers = data['myTrainers'];
    if (rawTrainers is! List) {
      throw const FormatException('myTrainers');
    }
    return rawTrainers
        .map((raw) {
          if (raw is! Map<String, dynamic>) {
            throw const FormatException('myTrainer');
          }
          return MyTrainerDto.fromJson(raw);
        })
        .toList(growable: false);
  }
}
