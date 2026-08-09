// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FitCoach';

  @override
  String get loginSubtitle => 'Sign in with the username provided by your gym';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'your_username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get roleAutoDetected => 'Your access type is detected automatically.';

  @override
  String get validationUserRequired => 'Enter your username';

  @override
  String validationUserMinLength(int min) {
    return 'The username must contain at least $min characters';
  }

  @override
  String get validationPasswordRequired => 'Enter your password';

  @override
  String validationPasswordMinLength(int min) {
    return 'The password must contain at least $min characters';
  }

  @override
  String get errorConfigMissing => 'The gym configuration is incomplete';

  @override
  String get errorInvalidCredentials => 'Incorrect username or password';

  @override
  String get errorAuthUnavailable => 'The sign-in service is unavailable';

  @override
  String get errorServer => 'The server could not complete the request';

  @override
  String get errorInvalidResponse => 'The server response is invalid';

  @override
  String get errorTimeout => 'The server took too long to respond';

  @override
  String get errorNetwork =>
      'Could not connect to the server. Check your connection.';

  @override
  String get errorInvalidSession => 'The server returned an invalid session';

  @override
  String get errorIncompleteSession =>
      'The server returned an incomplete session';

  @override
  String get errorUnexpected => 'An unexpected error occurred';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get trainerRole => 'Trainer';

  @override
  String get advisedRole => 'Client';

  @override
  String greeting(String user) {
    return 'Hello, $user';
  }

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get metricUnavailable => '--';

  @override
  String get trainerHeadline =>
      'Manage your clients and prepare their upcoming workouts.';

  @override
  String get trainerActiveClients => 'Active clients';

  @override
  String get trainerAssignedWorkouts => 'Assigned workouts';

  @override
  String get trainerPending => 'Pending';

  @override
  String get trainerClientsAction => 'My clients';

  @override
  String get trainerClientsActionDescription => 'View profiles and progress';

  @override
  String get trainerCreateWorkoutAction => 'Create workout';

  @override
  String get trainerCreateWorkoutActionDescription =>
      'Build and assign a new workout';

  @override
  String get exerciseCatalogAction => 'Exercise catalog';

  @override
  String get exerciseCatalogActionDescription =>
      'Browse exercises by muscle and level';

  @override
  String get advisedHeadline => 'Your workouts and progress in one place.';

  @override
  String get advisedWorkouts => 'Workouts';

  @override
  String get advisedWeeklyStreak => 'Weekly streak';

  @override
  String get advisedProgress => 'Progress';

  @override
  String get todayWorkoutAction => 'Today\'s workout';

  @override
  String get todayWorkoutActionDescription =>
      'View exercises, sets, and repetitions';

  @override
  String get myProgressAction => 'My progress';

  @override
  String get myProgressActionDescription => 'Review your progress and records';

  @override
  String get myTrainerAction => 'My trainer';

  @override
  String get myTrainerActionDescription => 'View your trainer\'s information';
}
