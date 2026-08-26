import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'FitCoach'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa con el usuario que te proporcionó tu gimnasio'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In es, this message translates to:
  /// **'tu_usuario'**
  String get usernameHint;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @roleAutoDetected.
  ///
  /// In es, this message translates to:
  /// **'El tipo de acceso se detecta automáticamente.'**
  String get roleAutoDetected;

  /// No description provided for @validationUserRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu usuario'**
  String get validationUserRequired;

  /// No description provided for @validationUserMinLength.
  ///
  /// In es, this message translates to:
  /// **'El usuario debe tener al menos {min} caracteres'**
  String validationUserMinLength(int min);

  /// No description provided for @validationPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {min} caracteres'**
  String validationPasswordMinLength(int min);

  /// No description provided for @errorConfigMissing.
  ///
  /// In es, this message translates to:
  /// **'La configuración del gimnasio está incompleta'**
  String get errorConfigMissing;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Usuario o contraseña incorrectos'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAuthUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El servicio de acceso no está disponible'**
  String get errorAuthUnavailable;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'El servidor no pudo completar la solicitud'**
  String get errorServer;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In es, this message translates to:
  /// **'La respuesta del servidor no es válida'**
  String get errorInvalidResponse;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servidor tardó demasiado en responder'**
  String get errorTimeout;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con el servidor. Revisa tu conexión.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidSession.
  ///
  /// In es, this message translates to:
  /// **'El servidor devolvió una sesión no válida'**
  String get errorInvalidSession;

  /// No description provided for @errorIncompleteSession.
  ///
  /// In es, this message translates to:
  /// **'El servidor devolvió una sesión incompleta'**
  String get errorIncompleteSession;

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get errorUnexpected;

  /// No description provided for @logoutTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutTooltip;

  /// No description provided for @trainerRole.
  ///
  /// In es, this message translates to:
  /// **'Entrenador'**
  String get trainerRole;

  /// No description provided for @advisedRole.
  ///
  /// In es, this message translates to:
  /// **'Asesorado'**
  String get advisedRole;

  /// No description provided for @onboardingBirthdateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get onboardingBirthdateLabel;

  /// No description provided for @onboardingBirthdateRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu fecha de nacimiento'**
  String get onboardingBirthdateRequired;

  /// No description provided for @onboardingGenderLabel.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get onboardingGenderLabel;

  /// No description provided for @onboardingGenderRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu sexo'**
  String get onboardingGenderRequired;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get onboardingGenderOther;

  /// No description provided for @greeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {user}'**
  String greeting(String user);

  /// No description provided for @quickActionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Accesos rápidos'**
  String get quickActionsTitle;

  /// No description provided for @metricUnavailable.
  ///
  /// In es, this message translates to:
  /// **'--'**
  String get metricUnavailable;

  /// No description provided for @trainerHeadline.
  ///
  /// In es, this message translates to:
  /// **'Gestiona a tus asesorados y prepara sus próximas rutinas.'**
  String get trainerHeadline;

  /// No description provided for @trainerActiveClients.
  ///
  /// In es, this message translates to:
  /// **'Asesorados activos'**
  String get trainerActiveClients;

  /// No description provided for @trainerAssignedWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Rutinas asignadas'**
  String get trainerAssignedWorkouts;

  /// No description provided for @trainerPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get trainerPending;

  /// No description provided for @trainerClientsAction.
  ///
  /// In es, this message translates to:
  /// **'Mis asesorados'**
  String get trainerClientsAction;

  /// No description provided for @trainerClientsActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Consulta perfiles y seguimiento'**
  String get trainerClientsActionDescription;

  /// No description provided for @trainerCreateWorkoutAction.
  ///
  /// In es, this message translates to:
  /// **'Crear rutina'**
  String get trainerCreateWorkoutAction;

  /// No description provided for @trainerCreateWorkoutActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Arma y asigna un nuevo entrenamiento'**
  String get trainerCreateWorkoutActionDescription;

  /// No description provided for @exerciseCatalogAction.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de ejercicios'**
  String get exerciseCatalogAction;

  /// No description provided for @exerciseCatalogActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Explora ejercicios por músculo y nivel'**
  String get exerciseCatalogActionDescription;

  /// No description provided for @advisedHeadline.
  ///
  /// In es, this message translates to:
  /// **'Tu entrenamiento y progreso, en un solo lugar.'**
  String get advisedHeadline;

  /// No description provided for @advisedWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Entrenamientos'**
  String get advisedWorkouts;

  /// No description provided for @advisedWeeklyStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha semanal'**
  String get advisedWeeklyStreak;

  /// No description provided for @advisedProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get advisedProgress;

  /// No description provided for @todayWorkoutAction.
  ///
  /// In es, this message translates to:
  /// **'Entrenamiento de hoy'**
  String get todayWorkoutAction;

  /// No description provided for @todayWorkoutActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Consulta ejercicios, series y repeticiones'**
  String get todayWorkoutActionDescription;

  /// No description provided for @homeTabLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTabLabel;

  /// No description provided for @calendarTabLabel.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendarTabLabel;

  /// No description provided for @plansTabLabel.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get plansTabLabel;

  /// No description provided for @completedWorkoutsStat.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0 {0 rutinas completadas} =1 {1 rutina completada} other {{count} rutinas completadas}}'**
  String completedWorkoutsStat(num count);

  /// No description provided for @myProgressAction.
  ///
  /// In es, this message translates to:
  /// **'Mi progreso'**
  String get myProgressAction;

  /// No description provided for @myProgressActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Revisa tus avances y registros'**
  String get myProgressActionDescription;

  /// No description provided for @myTrainerAction.
  ///
  /// In es, this message translates to:
  /// **'Mi entrenador'**
  String get myTrainerAction;

  /// No description provided for @myTrainerActionDescription.
  ///
  /// In es, this message translates to:
  /// **'Consulta la información de tu entrenador'**
  String get myTrainerActionDescription;

  /// No description provided for @trainerSummaryNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la información del entrenador.'**
  String get trainerSummaryNotFound;

  /// No description provided for @myTrainersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes entrenadores asignados.'**
  String get myTrainersEmpty;

  /// No description provided for @trainerSummaryAboutTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca del entrenador'**
  String get trainerSummaryAboutTitle;

  /// No description provided for @trainerSummaryDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Información profesional'**
  String get trainerSummaryDetailsTitle;

  /// No description provided for @trainerSummaryPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get trainerSummaryPlanLabel;

  /// No description provided for @trainerSummaryStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get trainerSummaryStatusLabel;

  /// No description provided for @trainerSummaryExperienceLabel.
  ///
  /// In es, this message translates to:
  /// **'Experiencia'**
  String get trainerSummaryExperienceLabel;

  /// No description provided for @trainerSummaryExperienceYears.
  ///
  /// In es, this message translates to:
  /// **'{years, plural, =1 {1 año} other {{years} años}}'**
  String trainerSummaryExperienceYears(int years);

  /// No description provided for @trainerSummaryCertificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Certificaciones'**
  String get trainerSummaryCertificationsTitle;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get commonFinish;

  /// No description provided for @commonAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get commonAdd;

  /// No description provided for @commonUse.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get commonUse;

  /// No description provided for @filtersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filtersTitle;

  /// No description provided for @searchExercisesHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar ejercicios...'**
  String get searchExercisesHint;

  /// No description provided for @muscleGroupLabel.
  ///
  /// In es, this message translates to:
  /// **'Grupo muscular'**
  String get muscleGroupLabel;

  /// No description provided for @equipmentLabel.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get equipmentLabel;

  /// No description provided for @noExercisesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron ejercicios con esos filtros.'**
  String get noExercisesFound;

  /// No description provided for @clientNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el asesorado.'**
  String get clientNotFound;

  /// No description provided for @assignRoutineAction.
  ///
  /// In es, this message translates to:
  /// **'Asignar rutina'**
  String get assignRoutineAction;

  /// No description provided for @clientSince.
  ///
  /// In es, this message translates to:
  /// **'Cliente desde: {date}'**
  String clientSince(Object date);

  /// No description provided for @ageLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get ageLabel;

  /// No description provided for @currentWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso actual'**
  String get currentWeightLabel;

  /// No description provided for @goalLabel.
  ///
  /// In es, this message translates to:
  /// **'Objetivo'**
  String get goalLabel;

  /// No description provided for @currentRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutina actual'**
  String get currentRoutineTitle;

  /// No description provided for @routineHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de rutinas'**
  String get routineHistoryTitle;

  /// No description provided for @routineHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Rutinas anteriores completadas'**
  String get routineHistorySubtitle;

  /// No description provided for @activeStatus.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get activeStatus;

  /// No description provided for @startLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get startLabel;

  /// No description provided for @daysPerWeekLabel.
  ///
  /// In es, this message translates to:
  /// **'Días/semana'**
  String get daysPerWeekLabel;

  /// No description provided for @progressLabel.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressLabel;

  /// No description provided for @endLabel.
  ///
  /// In es, this message translates to:
  /// **'Finaliza'**
  String get endLabel;

  /// No description provided for @exerciseCount.
  ///
  /// In es, this message translates to:
  /// **'{count} ejercicios'**
  String exerciseCount(Object count);

  /// No description provided for @levelValue.
  ///
  /// In es, this message translates to:
  /// **'Nivel: {level}'**
  String levelValue(Object level);

  /// No description provided for @routineHistoryEntry.
  ///
  /// In es, this message translates to:
  /// **'{duration} - Completado: {date}'**
  String routineHistoryEntry(Object date, Object duration);

  /// No description provided for @assignRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar rutina'**
  String get assignRoutineTitle;

  /// No description provided for @selectSavedRoutine.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una rutina ya creada'**
  String get selectSavedRoutine;

  /// No description provided for @startDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get startDateLabel;

  /// No description provided for @durationWeeksLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración (semanas)'**
  String get durationWeeksLabel;

  /// No description provided for @availableRoutinesTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutinas disponibles'**
  String get availableRoutinesTitle;

  /// No description provided for @selectClientsTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar asesorado(s)'**
  String get selectClientsTitle;

  /// No description provided for @selectedClientsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} asesorado(s) seleccionado(s)'**
  String selectedClientsCount(Object count);

  /// No description provided for @sendNotificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar notificación'**
  String get sendNotificationTitle;

  /// No description provided for @sendNotificationDescription.
  ///
  /// In es, this message translates to:
  /// **'Los asesorados recibirán una notificación de la nueva rutina'**
  String get sendNotificationDescription;

  /// No description provided for @summaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get summaryTitle;

  /// No description provided for @routineLabel.
  ///
  /// In es, this message translates to:
  /// **'Rutina'**
  String get routineLabel;

  /// No description provided for @noSelection.
  ///
  /// In es, this message translates to:
  /// **'Sin seleccionar'**
  String get noSelection;

  /// No description provided for @durationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get durationLabel;

  /// No description provided for @exercisesLabel.
  ///
  /// In es, this message translates to:
  /// **'Ejercicios'**
  String get exercisesLabel;

  /// No description provided for @clientsLabel.
  ///
  /// In es, this message translates to:
  /// **'Asesorados'**
  String get clientsLabel;

  /// No description provided for @weeksValue.
  ///
  /// In es, this message translates to:
  /// **'{count} semanas'**
  String weeksValue(Object count);

  /// No description provided for @routinePublished.
  ///
  /// In es, this message translates to:
  /// **'Rutina publicada para {count} asesorado(s).'**
  String routinePublished(Object count);

  /// No description provided for @publishRoutineAction.
  ///
  /// In es, this message translates to:
  /// **'Publicar rutina'**
  String get publishRoutineAction;

  /// No description provided for @selectedAction.
  ///
  /// In es, this message translates to:
  /// **'Seleccionada'**
  String get selectedAction;

  /// No description provided for @routineMetadata.
  ///
  /// In es, this message translates to:
  /// **'{weeks} semanas - {exercises} ejercicios'**
  String routineMetadata(Object exercises, Object weeks);

  /// No description provided for @createRoutineNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Agrega un nombre antes de guardar la rutina.'**
  String get createRoutineNameRequired;

  /// No description provided for @createRoutineMinimumDuration.
  ///
  /// In es, this message translates to:
  /// **'La rutina semanal debe asignarse por al menos {count} semanas.'**
  String createRoutineMinimumDuration(Object count);

  /// No description provided for @createRoutineIncompleteDays.
  ///
  /// In es, this message translates to:
  /// **'No se puede guardar. Cada día de la semana debe tener mínimo {count} ejercicios. Revisa: {days}.'**
  String createRoutineIncompleteDays(Object count, Object days);

  /// No description provided for @saveRoutineAction.
  ///
  /// In es, this message translates to:
  /// **'Guardar rutina'**
  String get saveRoutineAction;

  /// No description provided for @routineNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la rutina'**
  String get routineNameLabel;

  /// No description provided for @newRoutineHint.
  ///
  /// In es, this message translates to:
  /// **'Nueva rutina'**
  String get newRoutineHint;

  /// No description provided for @weeklyRoutineRules.
  ///
  /// In es, this message translates to:
  /// **'Se guarda como rutina semanal. Debe durar al menos {weeks} semanas y cada día necesita mínimo {exercises} ejercicios.'**
  String weeklyRoutineRules(Object exercises, Object weeks);

  /// No description provided for @minimumExercisesHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {count} ejercicios para poder guardar la semana.'**
  String minimumExercisesHint(Object count);

  /// No description provided for @addExerciseAction.
  ///
  /// In es, this message translates to:
  /// **'Agregar ejercicio'**
  String get addExerciseAction;

  /// No description provided for @searchExerciseAction.
  ///
  /// In es, this message translates to:
  /// **'Buscar ejercicio'**
  String get searchExerciseAction;

  /// No description provided for @emptyRoutineDay.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ejercicios en este día. Usa «Buscar ejercicio» para agregar uno.'**
  String get emptyRoutineDay;

  /// No description provided for @exerciseLabel.
  ///
  /// In es, this message translates to:
  /// **'Ejercicio'**
  String get exerciseLabel;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @setsLabel.
  ///
  /// In es, this message translates to:
  /// **'Series'**
  String get setsLabel;

  /// No description provided for @repsLabel.
  ///
  /// In es, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @weightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get weightLabel;

  /// No description provided for @restLabel.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get restLabel;

  /// No description provided for @todayRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutina de hoy'**
  String get todayRoutineTitle;

  /// No description provided for @exerciseProgress.
  ///
  /// In es, this message translates to:
  /// **'{completed} de {total} ejercicios'**
  String exerciseProgress(Object completed, Object total);

  /// No description provided for @completedStatus.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get completedStatus;

  /// No description provided for @estimatedDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada'**
  String get estimatedDurationLabel;

  /// No description provided for @minutesValue.
  ///
  /// In es, this message translates to:
  /// **'{count} minutos'**
  String minutesValue(Object count);

  /// No description provided for @totalSetsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total de series'**
  String get totalSetsLabel;

  /// No description provided for @setsValue.
  ///
  /// In es, this message translates to:
  /// **'{count} series'**
  String setsValue(Object count);

  /// No description provided for @exercisePosition.
  ///
  /// In es, this message translates to:
  /// **'Ejercicio {current} de {total}'**
  String exercisePosition(Object current, Object total);

  /// No description provided for @setLabel.
  ///
  /// In es, this message translates to:
  /// **'Serie {number}'**
  String setLabel(Object number);

  /// No description provided for @completeAndContinue.
  ///
  /// In es, this message translates to:
  /// **'Completar y seguir'**
  String get completeAndContinue;

  /// No description provided for @restBetweenSets.
  ///
  /// In es, this message translates to:
  /// **'Descanso entre series'**
  String get restBetweenSets;

  /// No description provided for @restBlockedMessage.
  ///
  /// In es, this message translates to:
  /// **'Puedes continuar cuando quieras o saltar el descanso.'**
  String get restBlockedMessage;

  /// No description provided for @skipRestLabel.
  ///
  /// In es, this message translates to:
  /// **'Saltar descanso'**
  String get skipRestLabel;

  /// No description provided for @sessionDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de sesión'**
  String get sessionDurationLabel;

  /// No description provided for @workoutCompleted.
  ///
  /// In es, this message translates to:
  /// **'Has completado la rutina de hoy'**
  String get workoutCompleted;

  /// No description provided for @workoutCompletedDescription.
  ///
  /// In es, this message translates to:
  /// **'Buen trabajo. Puedes volver al listado de ejercicios.'**
  String get workoutCompletedDescription;

  /// No description provided for @nextLabel.
  ///
  /// In es, this message translates to:
  /// **'Siguiente:'**
  String get nextLabel;

  /// No description provided for @nextExerciseSummary.
  ///
  /// In es, this message translates to:
  /// **'{sets} series x {reps} reps'**
  String nextExerciseSummary(Object reps, Object sets);

  /// No description provided for @selectedClientLabel.
  ///
  /// In es, this message translates to:
  /// **'Asesorado seleccionado: {name}'**
  String selectedClientLabel(Object name);

  /// No description provided for @exerciseCatalogTitle.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de ejercicios'**
  String get exerciseCatalogTitle;

  /// No description provided for @exerciseSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o identificador...'**
  String get exerciseSearchHint;

  /// No description provided for @exerciseResultsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} ejercicios'**
  String exerciseResultsCount(Object count);

  /// No description provided for @exerciseFiltersAction.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get exerciseFiltersAction;

  /// No description provided for @exerciseApplyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get exerciseApplyFilters;

  /// No description provided for @exerciseClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get exerciseClearFilters;

  /// No description provided for @exerciseLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get exerciseLoadMore;

  /// No description provided for @exerciseEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos ejercicios'**
  String get exerciseEmptyTitle;

  /// No description provided for @exerciseEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra búsqueda o elimina algunos filtros.'**
  String get exerciseEmptyDescription;

  /// No description provided for @exerciseRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get exerciseRetry;

  /// No description provided for @exerciseDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del ejercicio'**
  String get exerciseDetailsTitle;

  /// No description provided for @exerciseInstructionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Instrucciones'**
  String get exerciseInstructionsTitle;

  /// No description provided for @exerciseNoInstructions.
  ///
  /// In es, this message translates to:
  /// **'No hay instrucciones disponibles en este idioma.'**
  String get exerciseNoInstructions;

  /// No description provided for @exerciseLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get exerciseLevelLabel;

  /// No description provided for @exerciseCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get exerciseCategoryLabel;

  /// No description provided for @exerciseMuscleLabel.
  ///
  /// In es, this message translates to:
  /// **'Músculo principal'**
  String get exerciseMuscleLabel;

  /// No description provided for @exerciseAllFilter.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get exerciseAllFilter;

  /// No description provided for @exerciseErrorUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ya no permite consultar el catálogo.'**
  String get exerciseErrorUnauthorized;

  /// No description provided for @exerciseErrorUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El catálogo no está disponible por el momento.'**
  String get exerciseErrorUnavailable;

  /// No description provided for @exerciseErrorServer.
  ///
  /// In es, this message translates to:
  /// **'No se pudo consultar el catálogo.'**
  String get exerciseErrorServer;

  /// No description provided for @exerciseErrorInvalidResponse.
  ///
  /// In es, this message translates to:
  /// **'El catálogo devolvió una respuesta inválida.'**
  String get exerciseErrorInvalidResponse;

  /// No description provided for @exerciseErrorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El catálogo tardó demasiado en responder.'**
  String get exerciseErrorTimeout;

  /// No description provided for @exerciseErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con el catálogo.'**
  String get exerciseErrorNetwork;

  /// No description provided for @exerciseErrorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado al consultar ejercicios.'**
  String get exerciseErrorUnexpected;

  /// No description provided for @exerciseFilterBeginner.
  ///
  /// In es, this message translates to:
  /// **'Principiante'**
  String get exerciseFilterBeginner;

  /// No description provided for @exerciseFilterIntermediate.
  ///
  /// In es, this message translates to:
  /// **'Intermedio'**
  String get exerciseFilterIntermediate;

  /// No description provided for @exerciseFilterExpert.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get exerciseFilterExpert;

  /// No description provided for @exerciseFilterStrength.
  ///
  /// In es, this message translates to:
  /// **'Fuerza'**
  String get exerciseFilterStrength;

  /// No description provided for @exerciseFilterStretching.
  ///
  /// In es, this message translates to:
  /// **'Estiramiento'**
  String get exerciseFilterStretching;

  /// No description provided for @exerciseFilterCardio.
  ///
  /// In es, this message translates to:
  /// **'Cardio'**
  String get exerciseFilterCardio;

  /// No description provided for @exerciseFilterPowerlifting.
  ///
  /// In es, this message translates to:
  /// **'Powerlifting'**
  String get exerciseFilterPowerlifting;

  /// No description provided for @exerciseFilterPlyometrics.
  ///
  /// In es, this message translates to:
  /// **'Pliometría'**
  String get exerciseFilterPlyometrics;

  /// No description provided for @exerciseFilterOlympicWeightlifting.
  ///
  /// In es, this message translates to:
  /// **'Halterofilia olímpica'**
  String get exerciseFilterOlympicWeightlifting;

  /// No description provided for @exerciseFilterStrongman.
  ///
  /// In es, this message translates to:
  /// **'Strongman'**
  String get exerciseFilterStrongman;

  /// No description provided for @exerciseFilterBands.
  ///
  /// In es, this message translates to:
  /// **'Bandas'**
  String get exerciseFilterBands;

  /// No description provided for @exerciseFilterBarbell.
  ///
  /// In es, this message translates to:
  /// **'Barra'**
  String get exerciseFilterBarbell;

  /// No description provided for @exerciseFilterBodyOnly.
  ///
  /// In es, this message translates to:
  /// **'Peso corporal'**
  String get exerciseFilterBodyOnly;

  /// No description provided for @exerciseFilterCable.
  ///
  /// In es, this message translates to:
  /// **'Cable'**
  String get exerciseFilterCable;

  /// No description provided for @exerciseFilterDumbbell.
  ///
  /// In es, this message translates to:
  /// **'Mancuernas'**
  String get exerciseFilterDumbbell;

  /// No description provided for @exerciseFilterEzCurlBar.
  ///
  /// In es, this message translates to:
  /// **'Barra Z'**
  String get exerciseFilterEzCurlBar;

  /// No description provided for @exerciseFilterExerciseBall.
  ///
  /// In es, this message translates to:
  /// **'Pelota de ejercicio'**
  String get exerciseFilterExerciseBall;

  /// No description provided for @exerciseFilterFoamRoll.
  ///
  /// In es, this message translates to:
  /// **'Rodillo de espuma'**
  String get exerciseFilterFoamRoll;

  /// No description provided for @exerciseFilterKettlebells.
  ///
  /// In es, this message translates to:
  /// **'Kettlebells'**
  String get exerciseFilterKettlebells;

  /// No description provided for @exerciseFilterMachine.
  ///
  /// In es, this message translates to:
  /// **'Máquina'**
  String get exerciseFilterMachine;

  /// No description provided for @exerciseFilterMedicineBall.
  ///
  /// In es, this message translates to:
  /// **'Balón medicinal'**
  String get exerciseFilterMedicineBall;

  /// No description provided for @exerciseFilterOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get exerciseFilterOther;

  /// No description provided for @exerciseFilterAbdominals.
  ///
  /// In es, this message translates to:
  /// **'Abdominales'**
  String get exerciseFilterAbdominals;

  /// No description provided for @exerciseFilterAbductors.
  ///
  /// In es, this message translates to:
  /// **'Abductores'**
  String get exerciseFilterAbductors;

  /// No description provided for @exerciseFilterAdductors.
  ///
  /// In es, this message translates to:
  /// **'Aductores'**
  String get exerciseFilterAdductors;

  /// No description provided for @exerciseFilterBiceps.
  ///
  /// In es, this message translates to:
  /// **'Bíceps'**
  String get exerciseFilterBiceps;

  /// No description provided for @exerciseFilterCalves.
  ///
  /// In es, this message translates to:
  /// **'Pantorrillas'**
  String get exerciseFilterCalves;

  /// No description provided for @exerciseFilterChest.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get exerciseFilterChest;

  /// No description provided for @exerciseFilterForearms.
  ///
  /// In es, this message translates to:
  /// **'Antebrazos'**
  String get exerciseFilterForearms;

  /// No description provided for @exerciseFilterGlutes.
  ///
  /// In es, this message translates to:
  /// **'Glúteos'**
  String get exerciseFilterGlutes;

  /// No description provided for @exerciseFilterHamstrings.
  ///
  /// In es, this message translates to:
  /// **'Isquiotibiales'**
  String get exerciseFilterHamstrings;

  /// No description provided for @exerciseFilterLats.
  ///
  /// In es, this message translates to:
  /// **'Dorsales'**
  String get exerciseFilterLats;

  /// No description provided for @exerciseFilterLowerBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda baja'**
  String get exerciseFilterLowerBack;

  /// No description provided for @exerciseFilterMiddleBack.
  ///
  /// In es, this message translates to:
  /// **'Espalda media'**
  String get exerciseFilterMiddleBack;

  /// No description provided for @exerciseFilterNeck.
  ///
  /// In es, this message translates to:
  /// **'Cuello'**
  String get exerciseFilterNeck;

  /// No description provided for @exerciseFilterQuadriceps.
  ///
  /// In es, this message translates to:
  /// **'Cuádriceps'**
  String get exerciseFilterQuadriceps;

  /// No description provided for @exerciseFilterShoulders.
  ///
  /// In es, this message translates to:
  /// **'Hombros'**
  String get exerciseFilterShoulders;

  /// No description provided for @exerciseFilterTraps.
  ///
  /// In es, this message translates to:
  /// **'Trapecios'**
  String get exerciseFilterTraps;

  /// No description provided for @exerciseFilterTriceps.
  ///
  /// In es, this message translates to:
  /// **'Tríceps'**
  String get exerciseFilterTriceps;

  /// No description provided for @clientsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay asesorados asignados'**
  String get clientsEmptyTitle;

  /// No description provided for @clientsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán los asesorados que tengas asignados.'**
  String get clientsEmptyDescription;

  /// No description provided for @assignedWorkoutCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0 {Sin rutinas asignadas} =1 {1 rutina asignada} other {{count} rutinas asignadas}}'**
  String assignedWorkoutCount(int count);

  /// No description provided for @clientDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del asesorado'**
  String get clientDetailsTitle;

  /// No description provided for @assignedRoutinesTitle.
  ///
  /// In es, this message translates to:
  /// **'Rutinas asignadas'**
  String get assignedRoutinesTitle;

  /// No description provided for @assignedRoutinesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entrenamientos asignados por este entrenador'**
  String get assignedRoutinesSubtitle;

  /// No description provided for @assignedRoutinesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Este asesorado todavía no tiene rutinas asignadas.'**
  String get assignedRoutinesEmpty;

  /// No description provided for @myAssignedRoutinesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes rutinas asignadas.'**
  String get myAssignedRoutinesEmpty;

  /// No description provided for @birthdateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthdateLabel;

  /// No description provided for @clientCreatedAtLabel.
  ///
  /// In es, this message translates to:
  /// **'Registrado'**
  String get clientCreatedAtLabel;

  /// No description provided for @goalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Objetivos'**
  String get goalsTitle;

  /// No description provided for @goalsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No se han registrado objetivos.'**
  String get goalsEmpty;

  /// No description provided for @valueNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get valueNotAvailable;

  /// No description provided for @weightKilograms.
  ///
  /// In es, this message translates to:
  /// **'{weight} kg'**
  String weightKilograms(double weight);

  /// No description provided for @workoutMetadata.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {{day} · 1 ejercicio} other {{day} · {count} ejercicios}}'**
  String workoutMetadata(int count, String day);

  /// No description provided for @workoutPlannedMetadata.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {{day} · 1 ejercicio} other {{day} · {count} ejercicios}} · {weeks, plural, =1 {1 semana} other {{weeks} semanas}} · Inicia {date}'**
  String workoutPlannedMetadata(int count, String date, String day, int weeks);

  /// No description provided for @workoutWeeklyMetadata.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1 {1 día} other {{days} días}} · {exercises, plural, =1 {1 ejercicio} other {{exercises} ejercicios}} · {weeks, plural, =1 {1 semana} other {{weeks} semanas}} · Inicia {date}'**
  String workoutWeeklyMetadata(int days, String date, int exercises, int weeks);

  /// No description provided for @workoutDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {1 día} other {{count} días}}'**
  String workoutDaysCount(int count);

  /// No description provided for @workoutExerciseDay.
  ///
  /// In es, this message translates to:
  /// **'{day}: {exerciseId}'**
  String workoutExerciseDay(String day, String exerciseId);

  /// No description provided for @workoutExerciseDaySetsReps.
  ///
  /// In es, this message translates to:
  /// **'{day}: {exerciseId} · {sets} × {reps}'**
  String workoutExerciseDaySetsReps(
    String day,
    String exerciseId,
    int sets,
    int reps,
  );

  /// No description provided for @workoutExerciseSetsReps.
  ///
  /// In es, this message translates to:
  /// **'{exerciseId}: {sets} × {reps}'**
  String workoutExerciseSetsReps(String exerciseId, int sets, int reps);

  /// No description provided for @viewRoutineDetails.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get viewRoutineDetails;

  /// No description provided for @pauseLabel.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pauseLabel;

  /// No description provided for @routineDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de rutina'**
  String get routineDetailTitle;

  /// No description provided for @routineNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la rutina.'**
  String get routineNotFound;

  /// No description provided for @routineAssignedTo.
  ///
  /// In es, this message translates to:
  /// **'Asignada a {name}'**
  String routineAssignedTo(String name);

  /// No description provided for @weeklyPlanTitle.
  ///
  /// In es, this message translates to:
  /// **'Plan semanal'**
  String get weeklyPlanTitle;

  /// No description provided for @weeklyPlanSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Abre cada día para consultar ejercicios, series, repeticiones y descanso.'**
  String get weeklyPlanSubtitle;

  /// No description provided for @routineDayExerciseCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1 {1 ejercicio programado} other {{count} ejercicios programados}}'**
  String routineDayExerciseCount(int count);

  /// No description provided for @restSecondsValue.
  ///
  /// In es, this message translates to:
  /// **'{count} s'**
  String restSecondsValue(int count);

  /// No description provided for @inactiveStatus.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get inactiveStatus;

  /// No description provided for @assignedStatus.
  ///
  /// In es, this message translates to:
  /// **'Asignada'**
  String get assignedStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pendingStatus;

  /// No description provided for @weekdayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get weekdaySunday;

  /// No description provided for @dayNotAssigned.
  ///
  /// In es, this message translates to:
  /// **'Día sin asignar'**
  String get dayNotAssigned;

  /// No description provided for @clientErrorUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión ya no permite consultar asesorados.'**
  String get clientErrorUnauthorized;

  /// No description provided for @clientErrorUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El servicio de asesorados no está disponible por el momento.'**
  String get clientErrorUnavailable;

  /// No description provided for @clientErrorServer.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron consultar los asesorados.'**
  String get clientErrorServer;

  /// No description provided for @clientErrorInvalidResponse.
  ///
  /// In es, this message translates to:
  /// **'El servicio de asesorados devolvió una respuesta inválida.'**
  String get clientErrorInvalidResponse;

  /// No description provided for @clientErrorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servicio de asesorados tardó demasiado en responder.'**
  String get clientErrorTimeout;

  /// No description provided for @clientErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con el servicio de asesorados.'**
  String get clientErrorNetwork;

  /// No description provided for @clientErrorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado al consultar asesorados.'**
  String get clientErrorUnexpected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
