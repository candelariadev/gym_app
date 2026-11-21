// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get routineAssignmentInvalid =>
      'Revisa los días, ejercicios y valores de la rutina.';

  @override
  String get routineAssignmentAuth =>
      'Tu sesión expiró. Inicia sesión nuevamente.';

  @override
  String get routineAssignmentForbidden =>
      'No tienes permisos para asignar esta rutina.';

  @override
  String get routineAssignmentConflict =>
      'La rutina cambió o ya existe. Actualiza e intenta de nuevo.';

  @override
  String get routineAssignmentQuota =>
      'Alcanzaste el límite de rutinas de tu plan.';

  @override
  String get routineAssignmentNetwork =>
      'No fue posible conectar con el servicio. Intenta nuevamente.';

  @override
  String get routineAssignmentError => 'No fue posible asignar la rutina.';

  @override
  String get routineAssignmentMissing =>
      'Primero crea una rutina para poder asignarla.';

  @override
  String get routineAssignmentNoClients =>
      'No hay clientes activos para asignar.';

  @override
  String routineTrainingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de entrenamiento',
      one: '1 día de entrenamiento',
    );
    return '$_temp0';
  }

  @override
  String get pushRemovalPending =>
      'Desactivación pendiente en el servidor. Se reintentará al recuperar conexión con esta cuenta.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsDescription =>
      'Permisos del dispositivo y estado de solicitudes';

  @override
  String get notificationQuotaTitle => 'Cuota de notificaciones';

  @override
  String get notificationQuotaLoading => 'Consultando cuota…';

  @override
  String get notificationQuotaUnavailable =>
      'No se pudo comprobar la cuota. Actualiza antes de confirmar.';

  @override
  String get notificationQuotaDisabled =>
      'Las notificaciones no están habilitadas en este plan.';

  @override
  String get notificationQuotaUnlimited =>
      'Notificaciones sin límite. El servidor revalidará los permisos.';

  @override
  String notificationQuotaRemaining(int remaining, int reserved) {
    return 'Disponibles: $remaining. Reservadas: $reserved.';
  }

  @override
  String get notificationQuotaStale =>
      'Cuota guardada, sin comprobar ahora. Se revalidará al recuperar conexión.';

  @override
  String notificationQuotaReset(String date) {
    return 'Reinicio de cuota: $date UTC';
  }

  @override
  String get notificationQuotaExhausted =>
      'No quedan notificaciones disponibles en este período.';

  @override
  String get notificationRefresh => 'Actualizar estado y cuota';

  @override
  String get notificationNotifyClient => 'Notificar al cliente';

  @override
  String get notificationConfirmTitle => '¿Notificar al cliente?';

  @override
  String get notificationConfirmBody =>
      'La rutina ya está confirmada en el servidor. Si no hay conexión, guardaremos tu decisión para enviarla cuando vuelva, revalidando permisos y cuota.';

  @override
  String get notificationConfirm => 'Confirmar notificación';

  @override
  String get notificationCancel => 'Ahora no';

  @override
  String get notificationReady =>
      'Rutina confirmada en el servidor. No se ha solicitado una notificación.';

  @override
  String get notificationQueued =>
      'Decisión guardada en este dispositivo; esperando confirmación del servidor.';

  @override
  String get notificationPending =>
      'Solicitud aceptada por GymSAS; envío pendiente.';

  @override
  String get notificationProcessing => 'El servidor está procesando el envío.';

  @override
  String get notificationAccepted =>
      'Aceptada por el proveedor push. No confirma entrega ni lectura.';

  @override
  String get notificationFailed =>
      'El envío falló definitivamente. La rutina sigue disponible.';

  @override
  String get notificationUncertain =>
      'Resultado incierto. La cuota sigue reservada; no se repetirá automáticamente.';

  @override
  String get notificationNoDevices =>
      'El cliente no tiene dispositivos registrados para recibir notificaciones.';

  @override
  String get notificationRetry => 'Reintentar la misma solicitud';

  @override
  String get notificationRiskTitle => 'El cliente podría recibir un duplicado';

  @override
  String get notificationRiskBody =>
      'El proveedor pudo aceptar el envío anterior. Este reintento requiere tu confirmación y conservará la misma solicitud y cuota.';

  @override
  String get notificationHistoryEmpty =>
      'Aquí aparecerán las rutinas confirmadas y sus notificaciones.';

  @override
  String get notificationErrorNetwork =>
      'Sin conexión con el servicio. La decisión permanece guardada.';

  @override
  String get notificationErrorAuth =>
      'Inicia sesión nuevamente para enviar o consultar notificaciones.';

  @override
  String get notificationErrorForbidden =>
      'No tienes acceso a esta solicitud o la suscripción no está activa.';

  @override
  String get notificationErrorConflict =>
      'El servidor no permite este reintento. Actualiza el estado y revisa la solicitud.';

  @override
  String get notificationErrorStorage =>
      'No se pudo guardar en el dispositivo. No se ha confirmado un nuevo envío.';

  @override
  String get notificationErrorGeneric =>
      'No se pudo completar la operación de notificación. La rutina no se modifica.';

  @override
  String get pushDeviceTitle => 'Recibir notificaciones en este dispositivo';

  @override
  String get pushEnable => 'Activar notificaciones';

  @override
  String get pushDisable => 'Desactivar en este dispositivo';

  @override
  String get pushDisabled =>
      'Desactivadas. Puedes seguir usando tus rutinas sin conexión.';

  @override
  String get pushRegistered => 'Dispositivo registrado para esta cuenta.';

  @override
  String get pushRegistering => 'Registrando el dispositivo…';

  @override
  String get pushWaiting =>
      'Permiso concedido. Registro pendiente; se reintentará al recuperar conexión.';

  @override
  String get pushDenied =>
      'Permiso denegado. Actívalo en los ajustes del dispositivo y vuelve a comprobar.';

  @override
  String get pushUnsupported =>
      'Las notificaciones push están disponibles en Android y iOS.';

  @override
  String get pushReceived =>
      'Hay una actualización de una rutina. Abre para comprobar tu acceso.';

  @override
  String get pushOpenRoutine => 'Abrir rutina';

  @override
  String get pushVerifying => 'Comprobando acceso a la rutina en el servidor…';

  @override
  String get pushAccessUnavailable =>
      'No se pudo comprobar tu acceso. Conéctate y vuelve a intentarlo. Tus rutinas descargadas siguen disponibles desde Inicio.';

  @override
  String routineAssignmentPartial(int count) {
    return 'Rutinas confirmadas: $count. Puedes reintentar las asignaciones pendientes sin repetir las completadas.';
  }

  @override
  String offlinePending(int count) {
    return '$count cambios guardados en este dispositivo, pendientes de sincronizar.';
  }

  @override
  String get offlineDisconnected =>
      'Sin conexión con el servidor. Los cambios locales se enviarán al reconectar.';

  @override
  String get offlineSyncing => 'Sincronizando tus rutinas y entrenamientos…';

  @override
  String get offlineAuthRequired =>
      'Puedes usar tus datos locales. Inicia sesión de nuevo para sincronizar.';

  @override
  String get offlineConflict =>
      'El servidor rechazó un cambio. Se conservó localmente; revisa antes de reintentar.';

  @override
  String get offlineStorageError =>
      'No se pudo guardar en este dispositivo. No cierres la app; reintenta.';

  @override
  String get offlineRetry => 'Reintentar';

  @override
  String get offlineSignIn => 'Ingresar';

  @override
  String get loginGoogleButton => 'Continuar con Google';

  @override
  String get loginLoading => 'Iniciando sesión…';

  @override
  String get loginGoogleLoading => 'Conectando con Google…';

  @override
  String get authLoadingMessage =>
      'Estamos verificando tu acceso. Esto puede tardar unos momentos.';

  @override
  String get onboardingLoading => 'Creando tu cuenta…';

  @override
  String get onboardingCreateButton => 'Crear cuenta individual';

  @override
  String get sessionRestoring => 'Recuperando tu sesión…';

  @override
  String get loadingData => 'Cargando información…';

  @override
  String get progressRangeTooLong =>
      'Selecciona como máximo un año por consulta; puedes consultar periodos anteriores dentro de tu plan.';

  @override
  String get progressSets => 'Series completadas';

  @override
  String get progressRepetitions => 'Repeticiones';

  @override
  String get progressWeight => 'Peso máximo (kg)';

  @override
  String get progressVolume => 'Volumen de carga (kg × reps)';

  @override
  String get progressSessions => 'Sesiones';

  @override
  String get progressTrainingDays => 'Días de entrenamiento';

  @override
  String get progressDaily => 'Diario';

  @override
  String get progressWeekly => 'Semanal';

  @override
  String get progressMonthly => 'Mensual';

  @override
  String get progressMetric => 'Métrica';

  @override
  String get progressExercise => 'Ejercicio';

  @override
  String get progressAllExercises => 'Todos los ejercicios';

  @override
  String get progressNoMeasurement => 'Sin medición de carga';

  @override
  String get progressHistoryDenied =>
      'Tu suscripción no permite consultar este periodo.';

  @override
  String get progressLoadError =>
      'No pudimos cargar tu progreso. Intenta de nuevo.';

  @override
  String get progressRetry => 'Reintentar';

  @override
  String get progressEmpty =>
      'Aún no hay sesiones completadas en este periodo.';

  @override
  String get progressLegacyWarning =>
      'Hay sesiones sin series registradas. Cuentan para frecuencia, pero su peso y repeticiones no se pueden recuperar.';

  @override
  String get progressDetails => 'Ver valores por periodo';

  @override
  String get progressUnlimited =>
      'Historial sin límite por plan. Consulta hasta un año a la vez.';

  @override
  String progressHistoryMonths(int months) {
    return 'Tu plan permite consultar los últimos $months meses.';
  }

  @override
  String get progressMetricHelp =>
      'Se incluyen series marcadas como terminadas de sesiones completadas. El volumen suma kg × repeticiones con carga registrada. La semana inicia el lunes; se usa el huso horario actual del dispositivo.';

  @override
  String get progressInvalidSet =>
      'Ingresa repeticiones mayores a cero y un peso válido (kg). Deja el peso vacío si no aplica.';

  @override
  String get progressSaveError =>
      'No se pudo guardar en este dispositivo. Reintenta antes de salir.';

  @override
  String get progressSaving => 'Guardando en este dispositivo…';

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
  String get onboardingBirthdateLabel => 'Fecha de nacimiento';

  @override
  String get onboardingBirthdateRequired => 'Selecciona tu fecha de nacimiento';

  @override
  String get onboardingGenderLabel => 'Sexo';

  @override
  String get onboardingGenderRequired => 'Selecciona tu sexo';

  @override
  String get onboardingGenderMale => 'Masculino';

  @override
  String get onboardingGenderFemale => 'Femenino';

  @override
  String get onboardingGenderOther => 'Otro';

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
  String get homeTabLabel => 'Inicio';

  @override
  String get calendarTabLabel => 'Calendario';

  @override
  String get plansTabLabel => 'Planes';

  @override
  String completedWorkoutsStat(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutinas completadas',
      one: '1 rutina completada',
      zero: '0 rutinas completadas',
    );
    return '$_temp0';
  }

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
  String get trainerSummaryNotFound =>
      'No se encontró la información del entrenador.';

  @override
  String get myTrainersEmpty => 'No tienes entrenadores asignados.';

  @override
  String get trainerSummaryAboutTitle => 'Acerca del entrenador';

  @override
  String get trainerSummaryDetailsTitle => 'Información profesional';

  @override
  String get trainerSummaryPlanLabel => 'Plan';

  @override
  String get trainerSummaryStatusLabel => 'Estado';

  @override
  String get trainerSummaryExperienceLabel => 'Experiencia';

  @override
  String trainerSummaryExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get trainerSummaryCertificationsTitle => 'Certificaciones';

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
  String get completeSetAction => 'Marcar serie como terminada';

  @override
  String get setCompletedStatus => 'Serie terminada';

  @override
  String get completeAndContinue => 'Completar y seguir';

  @override
  String get restBetweenSets => 'Descanso entre series';

  @override
  String get restBlockedMessage =>
      'Puedes continuar cuando quieras o saltar el descanso.';

  @override
  String get skipRestLabel => 'Saltar descanso';

  @override
  String get sessionDurationLabel => 'Tiempo de sesión';

  @override
  String get workoutCompleted => 'Has completado la rutina de hoy';

  @override
  String get workoutCompletedDescription =>
      'Buen trabajo. Puedes volver al listado de ejercicios.';

  @override
  String get workoutSessionEmpty =>
      'Esta sesión todavía no contiene ejercicios.';

  @override
  String get workoutDayFallback => 'Día de entrenamiento';

  @override
  String exerciseForceMetadata(Object value) {
    return 'Tipo: $value';
  }

  @override
  String exerciseLevelMetadata(Object value) {
    return 'Nivel: $value';
  }

  @override
  String exerciseMechanicMetadata(Object value) {
    return 'Mecánica: $value';
  }

  @override
  String exerciseEquipmentMetadata(Object value) {
    return 'Equipo: $value';
  }

  @override
  String exerciseCategoryMetadata(Object value) {
    return 'Categoría: $value';
  }

  @override
  String exercisePrimaryMusclesMetadata(Object value) {
    return 'Músculos: $value';
  }

  @override
  String exerciseSecondaryMusclesMetadata(Object value) {
    return 'Secundarios: $value';
  }

  @override
  String get pauseSessionAction => 'Pausar sesión';

  @override
  String get finishWorkoutAction => 'Finalizar rutina';

  @override
  String sessionActionsIncomplete(Object completed, Object total) {
    return '$completed de $total ejercicios completados. Completa todos para finalizar.';
  }

  @override
  String get sessionActionsReady =>
      'Todos los ejercicios están completos. Ya puedes finalizar.';

  @override
  String get finishWorkoutConfirmationTitle => '¿Finalizar esta rutina?';

  @override
  String get finishWorkoutConfirmationDescription =>
      'La sesión se marcará como completada y ya no podrás registrar más series.';

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
  String get myAssignedRoutinesEmpty => 'Aún no tienes rutinas asignadas.';

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
  String get pauseLabel => 'Pausar';

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
