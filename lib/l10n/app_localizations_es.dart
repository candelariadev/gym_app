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
}
