import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/workout_error.dart';

class WorkoutErrorMapper {
  const WorkoutErrorMapper();

  WorkoutException from(Object error) {
    if (error is WorkoutException) return error;
    if (error is GraphQlException) {
      final status = _status(error);
      final message = error.errors.isEmpty ? null : error.errors.first.message;
      return WorkoutException(switch (status) {
        400 => WorkoutErrorCode.invalidInput,
        401 => WorkoutErrorCode.unauthorized,
        403 => WorkoutErrorCode.forbidden,
        402 => WorkoutErrorCode.quotaExceeded,
        409 => WorkoutErrorCode.conflict,
        502 || 503 || 504 => WorkoutErrorCode.unavailable,
        _ => WorkoutErrorCode.server,
      }, message);
    }
    if (error is ApiClientException) {
      return WorkoutException(switch (error.code) {
        ApiClientErrorCode.server => WorkoutErrorCode.server,
        ApiClientErrorCode.invalidResponse => WorkoutErrorCode.invalidResponse,
        ApiClientErrorCode.timeout => WorkoutErrorCode.timeout,
        ApiClientErrorCode.network => WorkoutErrorCode.network,
      });
    }
    if (error is FormatException || error is TypeError) {
      return const WorkoutException(WorkoutErrorCode.invalidResponse);
    }
    return const WorkoutException(WorkoutErrorCode.unexpected);
  }

  int? _status(GraphQlException error) {
    if (error.errors.isEmpty) return null;
    final raw = error.errors.first.extensions['httpStatus'];
    return raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
  }
}
