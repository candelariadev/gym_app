import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/exercise_catalog_error.dart';

class ExerciseCatalogErrorMapper {
  const ExerciseCatalogErrorMapper();

  ExerciseCatalogException from(Object error) {
    if (error is ExerciseCatalogException) return error;
    if (error is GraphQlException) {
      final status = _status(error);
      return ExerciseCatalogException(switch (status) {
        401 || 403 => ExerciseCatalogErrorCode.unauthorized,
        502 || 503 || 504 => ExerciseCatalogErrorCode.unavailable,
        _ => ExerciseCatalogErrorCode.server,
      });
    }
    if (error is ApiClientException) {
      return ExerciseCatalogException(switch (error.code) {
        ApiClientErrorCode.server => ExerciseCatalogErrorCode.server,
        ApiClientErrorCode.invalidResponse =>
          ExerciseCatalogErrorCode.invalidResponse,
        ApiClientErrorCode.timeout => ExerciseCatalogErrorCode.timeout,
        ApiClientErrorCode.network => ExerciseCatalogErrorCode.network,
      });
    }
    if (error is FormatException || error is TypeError) {
      return const ExerciseCatalogException(
        ExerciseCatalogErrorCode.invalidResponse,
      );
    }
    return const ExerciseCatalogException(ExerciseCatalogErrorCode.unexpected);
  }

  int? _status(GraphQlException error) {
    if (error.errors.isEmpty) return null;
    final raw = error.errors.first.extensions['httpStatus'];
    return raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
  }
}
