import 'package:gymsas_exercises/gymsas_exercises.dart';

import '../../../../l10n/app_localizations.dart';

extension ExerciseCatalogLocalizations on AppLocalizations {
  String exerciseCatalogError(ExerciseCatalogErrorCode code) => switch (code) {
    ExerciseCatalogErrorCode.unauthorized => exerciseErrorUnauthorized,
    ExerciseCatalogErrorCode.unavailable => exerciseErrorUnavailable,
    ExerciseCatalogErrorCode.server => exerciseErrorServer,
    ExerciseCatalogErrorCode.invalidResponse => exerciseErrorInvalidResponse,
    ExerciseCatalogErrorCode.timeout => exerciseErrorTimeout,
    ExerciseCatalogErrorCode.network => exerciseErrorNetwork,
    ExerciseCatalogErrorCode.unexpected => exerciseErrorUnexpected,
  };

  String exerciseTaxonomy(String value) => switch (value.toLowerCase()) {
    'beginner' => exerciseFilterBeginner,
    'intermediate' => exerciseFilterIntermediate,
    'expert' => exerciseFilterExpert,
    'strength' => exerciseFilterStrength,
    'stretching' => exerciseFilterStretching,
    'cardio' => exerciseFilterCardio,
    'powerlifting' => exerciseFilterPowerlifting,
    'plyometrics' => exerciseFilterPlyometrics,
    'olympic weightlifting' => exerciseFilterOlympicWeightlifting,
    'strongman' => exerciseFilterStrongman,
    'bands' => exerciseFilterBands,
    'barbell' => exerciseFilterBarbell,
    'body only' => exerciseFilterBodyOnly,
    'cable' => exerciseFilterCable,
    'dumbbell' => exerciseFilterDumbbell,
    'e-z curl bar' => exerciseFilterEzCurlBar,
    'exercise ball' => exerciseFilterExerciseBall,
    'foam roll' => exerciseFilterFoamRoll,
    'kettlebells' => exerciseFilterKettlebells,
    'machine' => exerciseFilterMachine,
    'medicine ball' => exerciseFilterMedicineBall,
    'other' => exerciseFilterOther,
    'abdominals' => exerciseFilterAbdominals,
    'abductors' => exerciseFilterAbductors,
    'adductors' => exerciseFilterAdductors,
    'biceps' => exerciseFilterBiceps,
    'calves' => exerciseFilterCalves,
    'chest' => exerciseFilterChest,
    'forearms' => exerciseFilterForearms,
    'glutes' => exerciseFilterGlutes,
    'hamstrings' => exerciseFilterHamstrings,
    'lats' => exerciseFilterLats,
    'lower back' => exerciseFilterLowerBack,
    'middle back' => exerciseFilterMiddleBack,
    'neck' => exerciseFilterNeck,
    'quadriceps' => exerciseFilterQuadriceps,
    'shoulders' => exerciseFilterShoulders,
    'traps' => exerciseFilterTraps,
    'triceps' => exerciseFilterTriceps,
    _ => value,
  };
}
