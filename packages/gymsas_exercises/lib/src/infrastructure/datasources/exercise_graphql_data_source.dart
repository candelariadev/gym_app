import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/entities/exercise_catalog_request.dart';
import '../dto/exercise_catalog_dto.dart';

class ExerciseGraphQlDataSource {
  const ExerciseGraphQlDataSource(this._client);

  static const document = r'''
    query Exercises(
      $search: String
      $level: String
      $category: String
      $equipment: String
      $muscle: String
      $page: Int
      $size: Int
    ) {
      exercises(
        search: $search
        level: $level
        category: $category
        equipment: $equipment
        muscle: $muscle
        page: $page
        size: $size
      ) {
        content {
          id
          exerciseId
          name { en es }
          force
          level
          mechanic
          equipment
          primaryMuscles
          secondaryMuscles
          instructions { en es }
          category
          images
        }
        page
        size
        total
        totalPages
      }
    }
  ''';

  final GraphQlClient _client;

  Future<ExerciseCatalogPageDto> getPage({
    required ExerciseCatalogRequest request,
    required String accessToken,
  }) async {
    final data = await _client.execute(
      document: document,
      accessToken: accessToken,
      variables: {
        'search': request.search,
        'level': request.level,
        'category': request.category,
        'equipment': request.equipment,
        'muscle': request.muscle,
        'page': request.page,
        'size': request.size,
      },
    );
    final rawPage = data['exercises'];
    if (rawPage is! Map<String, dynamic>) {
      throw const FormatException('exercises');
    }
    return ExerciseCatalogPageDto.fromJson(rawPage);
  }
}
