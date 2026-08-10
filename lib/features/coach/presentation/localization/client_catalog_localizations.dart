import 'package:gymsas_clients/gymsas_clients.dart';

import '../../../../l10n/app_localizations.dart';

extension ClientCatalogLocalizations on AppLocalizations {
  String clientCatalogError(ClientCatalogErrorCode code) => switch (code) {
    ClientCatalogErrorCode.unauthorized => clientErrorUnauthorized,
    ClientCatalogErrorCode.unavailable => clientErrorUnavailable,
    ClientCatalogErrorCode.server => clientErrorServer,
    ClientCatalogErrorCode.invalidResponse => clientErrorInvalidResponse,
    ClientCatalogErrorCode.timeout => clientErrorTimeout,
    ClientCatalogErrorCode.network => clientErrorNetwork,
    ClientCatalogErrorCode.unexpected => clientErrorUnexpected,
  };

  String workoutDayLabel(WorkoutDay? day) => switch (day) {
    WorkoutDay.monday => weekdayMonday,
    WorkoutDay.tuesday => weekdayTuesday,
    WorkoutDay.wednesday => weekdayWednesday,
    WorkoutDay.thursday => weekdayThursday,
    WorkoutDay.friday => weekdayFriday,
    WorkoutDay.saturday => weekdaySaturday,
    WorkoutDay.sunday => weekdaySunday,
    null => dayNotAssigned,
  };

  String clientStatusLabel(String status) => switch (status.toUpperCase()) {
    'ACTIVE' => activeStatus,
    'INACTIVE' => inactiveStatus,
    'ASSIGNED' => assignedStatus,
    'PENDING' => pendingStatus,
    'COMPLETED' => completedStatus,
    _ => status,
  };
}
