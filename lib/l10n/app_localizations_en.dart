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

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonUse => 'Use';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get searchExercisesHint => 'Search exercises...';

  @override
  String get muscleGroupLabel => 'Muscle group';

  @override
  String get equipmentLabel => 'Equipment';

  @override
  String get noExercisesFound => 'No exercises match those filters.';

  @override
  String get clientNotFound => 'The client was not found.';

  @override
  String get assignRoutineAction => 'Assign routine';

  @override
  String clientSince(Object date) {
    return 'Client since: $date';
  }

  @override
  String get ageLabel => 'Age';

  @override
  String get currentWeightLabel => 'Current weight';

  @override
  String get goalLabel => 'Goal';

  @override
  String get currentRoutineTitle => 'Current routine';

  @override
  String get routineHistoryTitle => 'Routine history';

  @override
  String get routineHistorySubtitle => 'Previously completed routines';

  @override
  String get activeStatus => 'Active';

  @override
  String get startLabel => 'Start';

  @override
  String get daysPerWeekLabel => 'Days/week';

  @override
  String get progressLabel => 'Progress';

  @override
  String get endLabel => 'Ends';

  @override
  String exerciseCount(Object count) {
    return '$count exercises';
  }

  @override
  String levelValue(Object level) {
    return 'Level: $level';
  }

  @override
  String routineHistoryEntry(Object date, Object duration) {
    return '$duration - Completed: $date';
  }

  @override
  String get assignRoutineTitle => 'Assign routine';

  @override
  String get selectSavedRoutine => 'Select a previously created routine';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get durationWeeksLabel => 'Duration (weeks)';

  @override
  String get availableRoutinesTitle => 'Available routines';

  @override
  String get selectClientsTitle => 'Select client(s)';

  @override
  String selectedClientsCount(Object count) {
    return '$count client(s) selected';
  }

  @override
  String get sendNotificationTitle => 'Send notification';

  @override
  String get sendNotificationDescription =>
      'Clients will receive a notification about the new routine';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get routineLabel => 'Routine';

  @override
  String get noSelection => 'Not selected';

  @override
  String get durationLabel => 'Duration';

  @override
  String get exercisesLabel => 'Exercises';

  @override
  String get clientsLabel => 'Clients';

  @override
  String weeksValue(Object count) {
    return '$count weeks';
  }

  @override
  String routinePublished(Object count) {
    return 'Routine published for $count client(s).';
  }

  @override
  String get publishRoutineAction => 'Publish routine';

  @override
  String get selectedAction => 'Selected';

  @override
  String routineMetadata(Object exercises, Object weeks) {
    return '$weeks weeks - $exercises exercises';
  }

  @override
  String get createRoutineNameRequired =>
      'Add a name before saving the routine.';

  @override
  String createRoutineMinimumDuration(Object count) {
    return 'The weekly routine must be assigned for at least $count weeks.';
  }

  @override
  String createRoutineIncompleteDays(Object count, Object days) {
    return 'The routine cannot be saved. Each day needs at least $count exercises. Review: $days.';
  }

  @override
  String get saveRoutineAction => 'Save routine';

  @override
  String get routineNameLabel => 'Routine name';

  @override
  String get newRoutineHint => 'New routine';

  @override
  String weeklyRoutineRules(Object exercises, Object weeks) {
    return 'This is saved as a weekly routine. It must last at least $weeks weeks and each day needs at least $exercises exercises.';
  }

  @override
  String minimumExercisesHint(Object count) {
    return 'At least $count exercises are required to save the week.';
  }

  @override
  String get addExerciseAction => 'Add exercise';

  @override
  String get searchExerciseAction => 'Search exercise';

  @override
  String get emptyRoutineDay =>
      'There are no exercises on this day yet. Use “Search exercise” to add one.';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get nameLabel => 'Name';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightLabel => 'Weight';

  @override
  String get restLabel => 'Rest';

  @override
  String get todayRoutineTitle => 'Today\'s routine';

  @override
  String exerciseProgress(Object completed, Object total) {
    return '$completed of $total exercises';
  }

  @override
  String get completedStatus => 'Completed';

  @override
  String get estimatedDurationLabel => 'Estimated duration';

  @override
  String minutesValue(Object count) {
    return '$count minutes';
  }

  @override
  String get totalSetsLabel => 'Total sets';

  @override
  String setsValue(Object count) {
    return '$count sets';
  }

  @override
  String exercisePosition(Object current, Object total) {
    return 'Exercise $current of $total';
  }

  @override
  String setLabel(Object number) {
    return 'Set $number';
  }

  @override
  String get completeAndContinue => 'Complete and continue';

  @override
  String get restBetweenSets => 'Rest between sets';

  @override
  String get restBlockedMessage =>
      'You cannot mark another set until the rest period ends.';

  @override
  String get workoutCompleted => 'You completed today\'s routine';

  @override
  String get workoutCompletedDescription =>
      'Great work. You can return to the exercise list.';

  @override
  String get nextLabel => 'Next:';

  @override
  String nextExerciseSummary(Object reps, Object sets) {
    return '$sets sets x $reps reps';
  }

  @override
  String selectedClientLabel(Object name) {
    return 'Selected client: $name';
  }

  @override
  String get exerciseCatalogTitle => 'Exercise catalog';

  @override
  String get exerciseSearchHint => 'Search by name or identifier...';

  @override
  String exerciseResultsCount(Object count) {
    return '$count exercises';
  }

  @override
  String get exerciseFiltersAction => 'Filter';

  @override
  String get exerciseApplyFilters => 'Apply filters';

  @override
  String get exerciseClearFilters => 'Clear filters';

  @override
  String get exerciseLoadMore => 'Load more';

  @override
  String get exerciseEmptyTitle => 'No exercises found';

  @override
  String get exerciseEmptyDescription =>
      'Try another search or remove some filters.';

  @override
  String get exerciseRetry => 'Retry';

  @override
  String get exerciseDetailsTitle => 'Exercise details';

  @override
  String get exerciseInstructionsTitle => 'Instructions';

  @override
  String get exerciseNoInstructions =>
      'No instructions are available in this language.';

  @override
  String get exerciseLevelLabel => 'Level';

  @override
  String get exerciseCategoryLabel => 'Category';

  @override
  String get exerciseMuscleLabel => 'Primary muscle';

  @override
  String get exerciseAllFilter => 'All';

  @override
  String get exerciseErrorUnauthorized =>
      'Your session can no longer access the catalog.';

  @override
  String get exerciseErrorUnavailable =>
      'The catalog is currently unavailable.';

  @override
  String get exerciseErrorServer => 'The catalog could not be loaded.';

  @override
  String get exerciseErrorInvalidResponse =>
      'The catalog returned an invalid response.';

  @override
  String get exerciseErrorTimeout => 'The catalog took too long to respond.';

  @override
  String get exerciseErrorNetwork => 'Could not connect to the catalog.';

  @override
  String get exerciseErrorUnexpected =>
      'An unexpected error occurred while loading exercises.';

  @override
  String get exerciseFilterBeginner => 'Beginner';

  @override
  String get exerciseFilterIntermediate => 'Intermediate';

  @override
  String get exerciseFilterExpert => 'Expert';

  @override
  String get exerciseFilterStrength => 'Strength';

  @override
  String get exerciseFilterStretching => 'Stretching';

  @override
  String get exerciseFilterCardio => 'Cardio';

  @override
  String get exerciseFilterPowerlifting => 'Powerlifting';

  @override
  String get exerciseFilterPlyometrics => 'Plyometrics';

  @override
  String get exerciseFilterOlympicWeightlifting => 'Olympic weightlifting';

  @override
  String get exerciseFilterStrongman => 'Strongman';

  @override
  String get exerciseFilterBands => 'Bands';

  @override
  String get exerciseFilterBarbell => 'Barbell';

  @override
  String get exerciseFilterBodyOnly => 'Body only';

  @override
  String get exerciseFilterCable => 'Cable';

  @override
  String get exerciseFilterDumbbell => 'Dumbbell';

  @override
  String get exerciseFilterEzCurlBar => 'E-Z curl bar';

  @override
  String get exerciseFilterExerciseBall => 'Exercise ball';

  @override
  String get exerciseFilterFoamRoll => 'Foam roll';

  @override
  String get exerciseFilterKettlebells => 'Kettlebells';

  @override
  String get exerciseFilterMachine => 'Machine';

  @override
  String get exerciseFilterMedicineBall => 'Medicine ball';

  @override
  String get exerciseFilterOther => 'Other';

  @override
  String get exerciseFilterAbdominals => 'Abdominals';

  @override
  String get exerciseFilterAbductors => 'Abductors';

  @override
  String get exerciseFilterAdductors => 'Adductors';

  @override
  String get exerciseFilterBiceps => 'Biceps';

  @override
  String get exerciseFilterCalves => 'Calves';

  @override
  String get exerciseFilterChest => 'Chest';

  @override
  String get exerciseFilterForearms => 'Forearms';

  @override
  String get exerciseFilterGlutes => 'Glutes';

  @override
  String get exerciseFilterHamstrings => 'Hamstrings';

  @override
  String get exerciseFilterLats => 'Lats';

  @override
  String get exerciseFilterLowerBack => 'Lower back';

  @override
  String get exerciseFilterMiddleBack => 'Middle back';

  @override
  String get exerciseFilterNeck => 'Neck';

  @override
  String get exerciseFilterQuadriceps => 'Quadriceps';

  @override
  String get exerciseFilterShoulders => 'Shoulders';

  @override
  String get exerciseFilterTraps => 'Traps';

  @override
  String get exerciseFilterTriceps => 'Triceps';

  @override
  String get clientsEmptyTitle => 'No clients assigned';

  @override
  String get clientsEmptyDescription =>
      'Your assigned clients will appear here.';

  @override
  String assignedWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assigned workouts',
      one: '1 assigned workout',
      zero: 'No assigned workouts',
    );
    return '$_temp0';
  }

  @override
  String get clientDetailsTitle => 'Client details';

  @override
  String get assignedRoutinesTitle => 'Assigned routines';

  @override
  String get assignedRoutinesSubtitle => 'Workouts assigned by this trainer';

  @override
  String get assignedRoutinesEmpty =>
      'This client has no assigned routines yet.';

  @override
  String get birthdateLabel => 'Birthdate';

  @override
  String get clientCreatedAtLabel => 'Registered';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsEmpty => 'No goals have been registered.';

  @override
  String get valueNotAvailable => 'Not available';

  @override
  String weightKilograms(double weight) {
    return '$weight kg';
  }

  @override
  String workoutMetadata(int count, String day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$day · $count exercises',
      one: '$day · 1 exercise',
    );
    return '$_temp0';
  }

  @override
  String workoutPlannedMetadata(int count, String date, String day, int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$day · $count exercises',
      one: '$day · 1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$_temp0 · $_temp1 · Starts $date';
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
      other: '$days days',
      one: '1 day',
    );
    String _temp1 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp2 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$_temp0 · $_temp1 · $_temp2 · Starts $date';
  }

  @override
  String workoutDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
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
  String get viewRoutineDetails => 'View details';

  @override
  String get routineDetailTitle => 'Routine details';

  @override
  String get routineNotFound => 'The routine could not be found.';

  @override
  String routineAssignedTo(String name) {
    return 'Assigned to $name';
  }

  @override
  String get weeklyPlanTitle => 'Weekly plan';

  @override
  String get weeklyPlanSubtitle =>
      'Open each day to view exercises, sets, repetitions, and rest.';

  @override
  String routineDayExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scheduled exercises',
      one: '1 scheduled exercise',
    );
    return '$_temp0';
  }

  @override
  String restSecondsValue(int count) {
    return '$count s';
  }

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get assignedStatus => 'Assigned';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get dayNotAssigned => 'Day not assigned';

  @override
  String get clientErrorUnauthorized =>
      'Your session can no longer access clients.';

  @override
  String get clientErrorUnavailable =>
      'The client service is currently unavailable.';

  @override
  String get clientErrorServer => 'Clients could not be loaded.';

  @override
  String get clientErrorInvalidResponse =>
      'The client service returned an invalid response.';

  @override
  String get clientErrorTimeout =>
      'The client service took too long to respond.';

  @override
  String get clientErrorNetwork => 'Could not connect to the client service.';

  @override
  String get clientErrorUnexpected =>
      'An unexpected error occurred while loading clients.';
}
