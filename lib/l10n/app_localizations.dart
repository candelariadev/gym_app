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
