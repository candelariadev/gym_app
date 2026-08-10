// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FitCoach';

  @override
  String get loginSubtitle =>
      'Ingresa con el usuario que te proporcionó tu gimnasio';

  @override
  String get usernameLabel => 'Usuario';

  @override
  String get usernameHint => 'tu_usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Tu contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get roleAutoDetected =>
      'El tipo de acceso se detecta automáticamente.';

  @override
  String get validationUserRequired => 'Ingresa tu usuario';

  @override
  String validationUserMinLength(int min) {
    return 'El usuario debe tener al menos $min caracteres';
  }

  @override
  String get validationPasswordRequired => 'Ingresa tu contraseña';

  @override
  String validationPasswordMinLength(int min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get errorConfigMissing =>
      'La configuración del gimnasio está incompleta';

  @override
  String get errorInvalidCredentials => 'Usuario o contraseña incorrectos';

  @override
  String get errorAuthUnavailable => 'El servicio de acceso no está disponible';

  @override
  String get errorServer => 'El servidor no pudo completar la solicitud';

  @override
  String get errorInvalidResponse => 'La respuesta del servidor no es válida';

  @override
  String get errorTimeout => 'El servidor tardó demasiado en responder';

  @override
  String get errorNetwork =>
      'No se pudo conectar con el servidor. Revisa tu conexión.';

  @override
  String get errorInvalidSession => 'El servidor devolvió una sesión no válida';

  @override
  String get errorIncompleteSession =>
      'El servidor devolvió una sesión incompleta';

  @override
  String get errorUnexpected => 'Ocurrió un error inesperado';

  @override
  String get logoutTooltip => 'Cerrar sesión';

  @override
  String get trainerRole => 'Entrenador';

  @override
  String get advisedRole => 'Asesorado';

  @override
  String greeting(String user) {
    return 'Hola, $user';
  }

  @override
  String get quickActionsTitle => 'Accesos rápidos';

  @override
  String get metricUnavailable => '--';

  @override
  String get trainerHeadline =>
      'Gestiona a tus asesorados y prepara sus próximas rutinas.';

  @override
  String get trainerActiveClients => 'Asesorados activos';

  @override
  String get trainerAssignedWorkouts => 'Rutinas asignadas';

  @override
  String get trainerPending => 'Pendientes';

  @override
  String get trainerClientsAction => 'Mis asesorados';

  @override
  String get trainerClientsActionDescription =>
      'Consulta perfiles y seguimiento';

  @override
  String get trainerCreateWorkoutAction => 'Crear rutina';

  @override
  String get trainerCreateWorkoutActionDescription =>
      'Arma y asigna un nuevo entrenamiento';

  @override
  String get exerciseCatalogAction => 'Catálogo de ejercicios';

  @override
  String get exerciseCatalogActionDescription =>
      'Explora ejercicios por músculo y nivel';

  @override
  String get advisedHeadline =>
      'Tu entrenamiento y progreso, en un solo lugar.';

  @override
  String get advisedWorkouts => 'Entrenamientos';

  @override
  String get advisedWeeklyStreak => 'Racha semanal';

  @override
  String get advisedProgress => 'Progreso';

  @override
  String get todayWorkoutAction => 'Entrenamiento de hoy';

  @override
  String get todayWorkoutActionDescription =>
      'Consulta ejercicios, series y repeticiones';

  @override
  String get myProgressAction => 'Mi progreso';

  @override
  String get myProgressActionDescription => 'Revisa tus avances y registros';

  @override
  String get myTrainerAction => 'Mi entrenador';

  @override
  String get myTrainerActionDescription =>
      'Consulta la información de tu entrenador';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonFinish => 'Finalizar';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonUse => 'Usar';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get searchExercisesHint => 'Buscar ejercicios...';

  @override
  String get muscleGroupLabel => 'Grupo muscular';

  @override
  String get equipmentLabel => 'Equipo';

  @override
  String get noExercisesFound =>
      'No se encontraron ejercicios con esos filtros.';

  @override
  String get clientNotFound => 'No se encontró el asesorado.';

  @override
  String get assignRoutineAction => 'Asignar rutina';

  @override
  String clientSince(Object date) {
    return 'Cliente desde: $date';
  }

  @override
  String get ageLabel => 'Edad';

  @override
  String get currentWeightLabel => 'Peso actual';

  @override
  String get goalLabel => 'Objetivo';

  @override
  String get currentRoutineTitle => 'Rutina actual';

  @override
  String get routineHistoryTitle => 'Historial de rutinas';

  @override
  String get routineHistorySubtitle => 'Rutinas anteriores completadas';

  @override
  String get activeStatus => 'Activa';

  @override
  String get startLabel => 'Inicio';

  @override
  String get daysPerWeekLabel => 'Días/semana';

  @override
  String get progressLabel => 'Progreso';

  @override
  String get endLabel => 'Finaliza';

  @override
  String exerciseCount(Object count) {
    return '$count ejercicios';
  }

  @override
  String levelValue(Object level) {
    return 'Nivel: $level';
  }

  @override
  String routineHistoryEntry(Object date, Object duration) {
    return '$duration - Completado: $date';
  }

  @override
  String get assignRoutineTitle => 'Asignar rutina';

  @override
  String get selectSavedRoutine => 'Selecciona una rutina ya creada';

  @override
  String get startDateLabel => 'Fecha de inicio';

  @override
  String get durationWeeksLabel => 'Duración (semanas)';

  @override
  String get availableRoutinesTitle => 'Rutinas disponibles';

  @override
  String get selectClientsTitle => 'Seleccionar asesorado(s)';

  @override
  String selectedClientsCount(Object count) {
    return '$count asesorado(s) seleccionado(s)';
  }

  @override
  String get sendNotificationTitle => 'Enviar notificación';

  @override
  String get sendNotificationDescription =>
      'Los asesorados recibirán una notificación de la nueva rutina';

  @override
  String get summaryTitle => 'Resumen';

  @override
  String get routineLabel => 'Rutina';

  @override
  String get noSelection => 'Sin seleccionar';

  @override
  String get durationLabel => 'Duración';

  @override
  String get exercisesLabel => 'Ejercicios';

  @override
  String get clientsLabel => 'Asesorados';

  @override
  String weeksValue(Object count) {
    return '$count semanas';
  }

  @override
  String routinePublished(Object count) {
    return 'Rutina publicada para $count asesorado(s).';
  }

  @override
  String get publishRoutineAction => 'Publicar rutina';

  @override
  String get selectedAction => 'Seleccionada';

  @override
  String routineMetadata(Object exercises, Object weeks) {
    return '$weeks semanas - $exercises ejercicios';
  }

  @override
  String get createRoutineNameRequired =>
      'Agrega un nombre antes de guardar la rutina.';

  @override
  String createRoutineMinimumDuration(Object count) {
    return 'La rutina semanal debe asignarse por al menos $count semanas.';
  }

  @override
  String createRoutineIncompleteDays(Object count, Object days) {
    return 'No se puede guardar. Cada día de la semana debe tener mínimo $count ejercicios. Revisa: $days.';
  }

  @override
  String get saveRoutineAction => 'Guardar rutina';

  @override
  String get routineNameLabel => 'Nombre de la rutina';

  @override
  String get newRoutineHint => 'Nueva rutina';

  @override
  String weeklyRoutineRules(Object exercises, Object weeks) {
    return 'Se guarda como rutina semanal. Debe durar al menos $weeks semanas y cada día necesita mínimo $exercises ejercicios.';
  }

  @override
  String minimumExercisesHint(Object count) {
    return 'Mínimo $count ejercicios para poder guardar la semana.';
  }

  @override
  String get addExerciseAction => 'Agregar ejercicio';

  @override
  String get searchExerciseAction => 'Buscar ejercicio';

  @override
  String get emptyRoutineDay =>
      'Todavía no hay ejercicios en este día. Usa «Buscar ejercicio» para agregar uno.';

  @override
  String get exerciseLabel => 'Ejercicio';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get setsLabel => 'Series';

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightLabel => 'Peso';

  @override
  String get restLabel => 'Descanso';

  @override
  String get todayRoutineTitle => 'Rutina de hoy';

  @override
  String exerciseProgress(Object completed, Object total) {
    return '$completed de $total ejercicios';
  }

  @override
  String get completedStatus => 'Completada';

  @override
  String get estimatedDurationLabel => 'Duración estimada';

  @override
  String minutesValue(Object count) {
    return '$count minutos';
  }

  @override
  String get totalSetsLabel => 'Total de series';

  @override
  String setsValue(Object count) {
    return '$count series';
  }

  @override
  String exercisePosition(Object current, Object total) {
    return 'Ejercicio $current de $total';
  }

  @override
  String setLabel(Object number) {
    return 'Serie $number';
  }

  @override
  String get completeAndContinue => 'Completar y seguir';

  @override
  String get restBetweenSets => 'Descanso entre series';

  @override
  String get restBlockedMessage =>
      'No puedes marcar otra serie hasta que termine el descanso.';

  @override
  String get workoutCompleted => 'Has completado la rutina de hoy';

  @override
  String get workoutCompletedDescription =>
      'Buen trabajo. Puedes volver al listado de ejercicios.';

  @override
  String get nextLabel => 'Siguiente:';

  @override
  String nextExerciseSummary(Object reps, Object sets) {
    return '$sets series x $reps reps';
  }

  @override
  String selectedClientLabel(Object name) {
    return 'Asesorado seleccionado: $name';
  }

  @override
  String get exerciseCatalogTitle => 'Catálogo de ejercicios';

  @override
  String get exerciseSearchHint => 'Buscar por nombre o identificador...';

  @override
  String exerciseResultsCount(Object count) {
    return '$count ejercicios';
  }

  @override
  String get exerciseFiltersAction => 'Filtrar';

  @override
  String get exerciseApplyFilters => 'Aplicar filtros';

  @override
  String get exerciseClearFilters => 'Limpiar filtros';

  @override
  String get exerciseLoadMore => 'Cargar más';

  @override
  String get exerciseEmptyTitle => 'No encontramos ejercicios';

  @override
  String get exerciseEmptyDescription =>
      'Prueba con otra búsqueda o elimina algunos filtros.';

  @override
  String get exerciseRetry => 'Reintentar';

  @override
  String get exerciseDetailsTitle => 'Detalle del ejercicio';

  @override
  String get exerciseInstructionsTitle => 'Instrucciones';

  @override
  String get exerciseNoInstructions =>
      'No hay instrucciones disponibles en este idioma.';

  @override
  String get exerciseLevelLabel => 'Nivel';

  @override
  String get exerciseCategoryLabel => 'Categoría';

  @override
  String get exerciseMuscleLabel => 'Músculo principal';

  @override
  String get exerciseAllFilter => 'Todos';

  @override
  String get exerciseErrorUnauthorized =>
      'Tu sesión ya no permite consultar el catálogo.';

  @override
  String get exerciseErrorUnavailable =>
      'El catálogo no está disponible por el momento.';

  @override
  String get exerciseErrorServer => 'No se pudo consultar el catálogo.';

  @override
  String get exerciseErrorInvalidResponse =>
      'El catálogo devolvió una respuesta inválida.';

  @override
  String get exerciseErrorTimeout =>
      'El catálogo tardó demasiado en responder.';

  @override
  String get exerciseErrorNetwork => 'No se pudo conectar con el catálogo.';

  @override
  String get exerciseErrorUnexpected =>
      'Ocurrió un error inesperado al consultar ejercicios.';

  @override
  String get exerciseFilterBeginner => 'Principiante';

  @override
  String get exerciseFilterIntermediate => 'Intermedio';

  @override
  String get exerciseFilterExpert => 'Experto';

  @override
  String get exerciseFilterStrength => 'Fuerza';

  @override
  String get exerciseFilterStretching => 'Estiramiento';

  @override
  String get exerciseFilterCardio => 'Cardio';

  @override
  String get exerciseFilterPowerlifting => 'Powerlifting';

  @override
  String get exerciseFilterPlyometrics => 'Pliometría';

  @override
  String get exerciseFilterOlympicWeightlifting => 'Halterofilia olímpica';

  @override
  String get exerciseFilterStrongman => 'Strongman';

  @override
  String get exerciseFilterBands => 'Bandas';

  @override
  String get exerciseFilterBarbell => 'Barra';

  @override
  String get exerciseFilterBodyOnly => 'Peso corporal';

  @override
  String get exerciseFilterCable => 'Cable';

  @override
  String get exerciseFilterDumbbell => 'Mancuernas';

  @override
  String get exerciseFilterEzCurlBar => 'Barra Z';

  @override
  String get exerciseFilterExerciseBall => 'Pelota de ejercicio';

  @override
  String get exerciseFilterFoamRoll => 'Rodillo de espuma';

  @override
  String get exerciseFilterKettlebells => 'Kettlebells';

  @override
  String get exerciseFilterMachine => 'Máquina';

  @override
  String get exerciseFilterMedicineBall => 'Balón medicinal';

  @override
  String get exerciseFilterOther => 'Otro';

  @override
  String get exerciseFilterAbdominals => 'Abdominales';

  @override
  String get exerciseFilterAbductors => 'Abductores';

  @override
  String get exerciseFilterAdductors => 'Aductores';

  @override
  String get exerciseFilterBiceps => 'Bíceps';

  @override
  String get exerciseFilterCalves => 'Pantorrillas';

  @override
  String get exerciseFilterChest => 'Pecho';

  @override
  String get exerciseFilterForearms => 'Antebrazos';

  @override
  String get exerciseFilterGlutes => 'Glúteos';

  @override
  String get exerciseFilterHamstrings => 'Isquiotibiales';

  @override
  String get exerciseFilterLats => 'Dorsales';

  @override
  String get exerciseFilterLowerBack => 'Espalda baja';

  @override
  String get exerciseFilterMiddleBack => 'Espalda media';

  @override
  String get exerciseFilterNeck => 'Cuello';

  @override
  String get exerciseFilterQuadriceps => 'Cuádriceps';

  @override
  String get exerciseFilterShoulders => 'Hombros';

  @override
  String get exerciseFilterTraps => 'Trapecios';

  @override
  String get exerciseFilterTriceps => 'Tríceps';

  @override
  String get clientsEmptyTitle => 'No hay asesorados asignados';

  @override
  String get clientsEmptyDescription =>
      'Aquí aparecerán los asesorados que tengas asignados.';

  @override
  String assignedWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutinas asignadas',
      one: '1 rutina asignada',
      zero: 'Sin rutinas asignadas',
    );
    return '$_temp0';
  }

  @override
  String get clientDetailsTitle => 'Datos del asesorado';

  @override
  String get assignedRoutinesTitle => 'Rutinas asignadas';

  @override
  String get assignedRoutinesSubtitle =>
      'Entrenamientos asignados por este entrenador';

  @override
  String get assignedRoutinesEmpty =>
      'Este asesorado todavía no tiene rutinas asignadas.';

  @override
  String get birthdateLabel => 'Fecha de nacimiento';

  @override
  String get clientCreatedAtLabel => 'Registrado';

  @override
  String get goalsTitle => 'Objetivos';

  @override
  String get goalsEmpty => 'No se han registrado objetivos.';

  @override
  String get valueNotAvailable => 'No disponible';

  @override
  String weightKilograms(double weight) {
    return '$weight kg';
  }

  @override
  String workoutMetadata(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$day · $count ejercicios',
      one: '$day · 1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String workoutPlannedMetadata(int count, String date, String day, int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$day · $count ejercicios',
      one: '$day · 1 ejercicio',
    );
    String _temp1 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semanas',
      one: '1 semana',
    );
    return '$_temp0 · $_temp1 · Inicia $date';
  }

  @override
  String workoutWeeklyMetadata(
    int days,
    String date,
    int exercises,
    int weeks,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    String _temp1 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises ejercicios',
      one: '1 ejercicio',
    );
    String _temp2 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semanas',
      one: '1 semana',
    );
    return '$_temp0 · $_temp1 · $_temp2 · Inicia $date';
  }

  @override
  String workoutDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String workoutExerciseDay(String day, String exerciseId) {
    return '$day: $exerciseId';
  }

  @override
  String workoutExerciseDaySetsReps(
    String day,
    String exerciseId,
    int sets,
    int reps,
  ) {
    return '$day: $exerciseId · $sets × $reps';
  }

  @override
  String workoutExerciseSetsReps(String exerciseId, int sets, int reps) {
    return '$exerciseId: $sets × $reps';
  }

  @override
  String get viewRoutineDetails => 'Ver detalle';

  @override
  String get routineDetailTitle => 'Detalle de rutina';

  @override
  String get routineNotFound => 'No se encontró la rutina.';

  @override
  String routineAssignedTo(String name) {
    return 'Asignada a $name';
  }

  @override
  String get weeklyPlanTitle => 'Plan semanal';

  @override
  String get weeklyPlanSubtitle =>
      'Abre cada día para consultar ejercicios, series, repeticiones y descanso.';

  @override
  String routineDayExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios programados',
      one: '1 ejercicio programado',
    );
    return '$_temp0';
  }

  @override
  String restSecondsValue(int count) {
    return '$count s';
  }

  @override
  String get inactiveStatus => 'Inactivo';

  @override
  String get assignedStatus => 'Asignada';

  @override
  String get pendingStatus => 'Pendiente';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get dayNotAssigned => 'Día sin asignar';

  @override
  String get clientErrorUnauthorized =>
      'Tu sesión ya no permite consultar asesorados.';

  @override
  String get clientErrorUnavailable =>
      'El servicio de asesorados no está disponible por el momento.';

  @override
  String get clientErrorServer => 'No se pudieron consultar los asesorados.';

  @override
  String get clientErrorInvalidResponse =>
      'El servicio de asesorados devolvió una respuesta inválida.';

  @override
  String get clientErrorTimeout =>
      'El servicio de asesorados tardó demasiado en responder.';

  @override
  String get clientErrorNetwork =>
      'No se pudo conectar con el servicio de asesorados.';

  @override
  String get clientErrorUnexpected =>
      'Ocurrió un error inesperado al consultar asesorados.';
}
