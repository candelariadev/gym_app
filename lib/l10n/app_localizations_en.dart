// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get routineAssignmentInvalid =>
      'Check the routine days, exercises and values.';

  @override
  String get routineAssignmentAuth => 'Your session expired. Sign in again.';

  @override
  String get routineAssignmentForbidden =>
      'You do not have permission to assign this routine.';

  @override
  String get routineAssignmentConflict =>
      'The routine changed or already exists. Refresh and try again.';

  @override
  String get routineAssignmentQuota =>
      'You reached your plan\'s routine limit.';

  @override
  String get routineAssignmentNetwork =>
      'Could not connect to the service. Try again.';

  @override
  String get routineAssignmentError => 'Could not assign the routine.';

  @override
  String get routineAssignmentMissing =>
      'Create a routine before assigning it.';

  @override
  String get routineAssignmentNoClients =>
      'There are no active clients to assign.';

  @override
  String routineTrainingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count training days',
      one: '1 training day',
    );
    return '$_temp0';
  }

  @override
  String get pushRemovalPending =>
      'Server deactivation pending. It will retry when this account is connected.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsDescription =>
      'Device permissions and request status';

  @override
  String get notificationQuotaTitle => 'Notification quota';

  @override
  String get notificationQuotaLoading => 'Checking quota…';

  @override
  String get notificationQuotaUnavailable =>
      'Quota could not be checked. Refresh before confirming.';

  @override
  String get notificationQuotaDisabled =>
      'Notifications are not enabled for this plan.';

  @override
  String get notificationQuotaUnlimited =>
      'Unlimited notifications. The server will revalidate access.';

  @override
  String notificationQuotaRemaining(int remaining, int reserved) {
    return 'Available: $remaining. Reserved: $reserved.';
  }

  @override
  String get notificationQuotaStale =>
      'Saved quota, not checked now. It will be revalidated when connected.';

  @override
  String notificationQuotaReset(String date) {
    return 'Quota resets: $date UTC';
  }

  @override
  String get notificationQuotaExhausted =>
      'No notifications remain for this period.';

  @override
  String get notificationRefresh => 'Refresh status and quota';

  @override
  String get notificationNotifyClient => 'Notify the client';

  @override
  String get notificationConfirmTitle => 'Notify the client?';

  @override
  String get notificationConfirmBody =>
      'The routine is already confirmed on the server. If offline, we will save your decision and submit it when connected, revalidating access and quota.';

  @override
  String get notificationConfirm => 'Confirm notification';

  @override
  String get notificationCancel => 'Not now';

  @override
  String get notificationReady =>
      'Routine confirmed on the server. No notification has been requested.';

  @override
  String get notificationQueued =>
      'Decision saved on this device; waiting for server confirmation.';

  @override
  String get notificationPending => 'Request accepted by GymSAS; push pending.';

  @override
  String get notificationProcessing => 'The server is processing the push.';

  @override
  String get notificationAccepted =>
      'Accepted by the push provider. This does not confirm delivery or reading.';

  @override
  String get notificationFailed =>
      'The push definitively failed. The routine remains available.';

  @override
  String get notificationUncertain =>
      'Uncertain result. Quota stays reserved; it will not be resent automatically.';

  @override
  String get notificationNoDevices =>
      'The client has no devices registered to receive notifications.';

  @override
  String get notificationRetry => 'Retry the same request';

  @override
  String get notificationRiskTitle => 'The client could receive a duplicate';

  @override
  String get notificationRiskBody =>
      'The provider may have accepted the previous push. This retry requires your confirmation and keeps the same request and quota reservation.';

  @override
  String get notificationHistoryEmpty =>
      'Confirmed routines and their notifications will appear here.';

  @override
  String get notificationErrorNetwork =>
      'Cannot connect to the service. Your decision remains saved.';

  @override
  String get notificationErrorAuth =>
      'Sign in again to send or check notifications.';

  @override
  String get notificationErrorForbidden =>
      'You cannot access this request or the subscription is inactive.';

  @override
  String get notificationErrorConflict =>
      'The server does not allow this retry. Refresh and review the request.';

  @override
  String get notificationErrorStorage =>
      'Could not save on the device. No new push has been confirmed.';

  @override
  String get notificationErrorGeneric =>
      'The notification operation could not be completed. The routine is unchanged.';

  @override
  String get pushDeviceTitle => 'Receive notifications on this device';

  @override
  String get pushEnable => 'Enable notifications';

  @override
  String get pushDisable => 'Disable on this device';

  @override
  String get pushDisabled =>
      'Disabled. You can still use your routines offline.';

  @override
  String get pushRegistered => 'Device registered for this account.';

  @override
  String get pushRegistering => 'Registering device…';

  @override
  String get pushWaiting =>
      'Permission granted. Registration pending; it will retry when connected.';

  @override
  String get pushDenied =>
      'Permission denied. Enable it in device settings and check again.';

  @override
  String get pushUnsupported =>
      'Push notifications are available on Android and iOS.';

  @override
  String get pushReceived =>
      'A routine has been updated. Open it to verify your access.';

  @override
  String get pushOpenRoutine => 'Open routine';

  @override
  String get pushVerifying => 'Checking access to the routine on the server…';

  @override
  String get pushAccessUnavailable =>
      'Access could not be verified. Connect and try again. Your downloaded routines remain available from Home.';

  @override
  String routineAssignmentPartial(int count) {
    return 'Confirmed routines: $count. You can retry pending assignments without repeating completed ones.';
  }

  @override
  String offlinePending(int count) {
    return '$count changes saved on this device, waiting to sync.';
  }

  @override
  String get offlineDisconnected =>
      'Cannot reach the server. Local changes will sync when it reconnects.';

  @override
  String get offlineSyncing => 'Syncing your routines and workouts…';

  @override
  String get offlineAuthRequired =>
      'You can use local data. Sign in again to sync.';

  @override
  String get offlineConflict =>
      'The server rejected a change. It is saved locally; review before retrying.';

  @override
  String get offlineStorageError =>
      'Could not save on this device. Keep the app open and retry.';

  @override
  String get offlineRetry => 'Retry';

  @override
  String get offlineSignIn => 'Sign in';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginLoading => 'Signing in…';

  @override
  String get loginGoogleLoading => 'Connecting to Google…';

  @override
  String get authLoadingMessage =>
      'We are verifying your access. This may take a few moments.';

  @override
  String get onboardingLoading => 'Creating your account…';

  @override
  String get onboardingCreateButton => 'Create individual account';

  @override
  String get sessionRestoring => 'Restoring your session…';

  @override
  String get loadingData => 'Loading information…';

  @override
  String get progressRangeTooLong =>
      'Select at most one year per query; you can select earlier periods covered by your plan.';

  @override
  String get progressSets => 'Completed sets';

  @override
  String get progressRepetitions => 'Repetitions';

  @override
  String get progressWeight => 'Maximum weight (kg)';

  @override
  String get progressVolume => 'Load volume (kg × reps)';

  @override
  String get progressSessions => 'Sessions';

  @override
  String get progressTrainingDays => 'Training days';

  @override
  String get progressDaily => 'Daily';

  @override
  String get progressWeekly => 'Weekly';

  @override
  String get progressMonthly => 'Monthly';

  @override
  String get progressMetric => 'Metric';

  @override
  String get progressExercise => 'Exercise';

  @override
  String get progressAllExercises => 'All exercises';

  @override
  String get progressNoMeasurement => 'No load measurement';

  @override
  String get progressHistoryDenied =>
      'Your subscription does not allow access to this period.';

  @override
  String get progressLoadError =>
      'We could not load your progress. Please try again.';

  @override
  String get progressRetry => 'Retry';

  @override
  String get progressEmpty =>
      'There are no completed sessions in this period yet.';

  @override
  String get progressLegacyWarning =>
      'Some sessions have no recorded sets. They count toward frequency, but their weight and repetitions cannot be recovered.';

  @override
  String get progressDetails => 'View values by period';

  @override
  String get progressUnlimited =>
      'Your plan has unlimited history. Query up to one year at a time.';

  @override
  String progressHistoryMonths(int months) {
    return 'Your plan includes the last $months months of history.';
  }

  @override
  String get progressMetricHelp =>
      'Includes sets marked complete in completed sessions. Volume sums kg × repetitions with a recorded load. Weeks start on Monday; the device\'s current time zone offset is used.';

  @override
  String get progressInvalidSet =>
      'Enter repetitions greater than zero and a valid weight (kg). Leave weight blank if not applicable.';

  @override
  String get progressSaveError =>
      'Could not save on this device. Retry before leaving.';

  @override
  String get progressSaving => 'Saving on this device…';

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
  String get onboardingBirthdateLabel => 'Birthdate';

  @override
  String get onboardingBirthdateRequired => 'Select your birthdate';

  @override
  String get onboardingGenderLabel => 'Sex';

  @override
  String get onboardingGenderRequired => 'Select your sex';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderOther => 'Other';

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
  String get homeTabLabel => 'Home';

  @override
  String get calendarTabLabel => 'Calendar';

  @override
  String get plansTabLabel => 'Plans';

  @override
  String completedWorkoutsStat(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed workouts',
      one: '1 completed workout',
      zero: '0 completed workouts',
    );
    return '$_temp0';
  }

  @override
  String get myProgressAction => 'My progress';

  @override
  String get myProgressActionDescription => 'Review your progress and records';

  @override
  String get myTrainerAction => 'My trainer';

  @override
  String get myTrainerActionDescription => 'View your trainer\'s information';

  @override
  String get trainerSummaryNotFound => 'The trainer information was not found.';

  @override
  String get myTrainersEmpty => 'You do not have any assigned trainers.';

  @override
  String get trainerSummaryAboutTitle => 'About the trainer';

  @override
  String get trainerSummaryDetailsTitle => 'Professional information';

  @override
  String get trainerSummaryPlanLabel => 'Plan';

  @override
  String get trainerSummaryStatusLabel => 'Status';

  @override
  String get trainerSummaryExperienceLabel => 'Experience';

  @override
  String trainerSummaryExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get trainerSummaryCertificationsTitle => 'Certifications';

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
  String get completeSetAction => 'Mark set as finished';

  @override
  String get setCompletedStatus => 'Set finished';

  @override
  String get completeAndContinue => 'Complete and continue';

  @override
  String get restBetweenSets => 'Rest between sets';

  @override
  String get restBlockedMessage =>
      'Continue whenever you are ready or skip the rest period.';

  @override
  String get skipRestLabel => 'Skip rest';

  @override
  String get sessionDurationLabel => 'Session time';

  @override
  String get workoutCompleted => 'You completed today\'s routine';

  @override
  String get workoutCompletedDescription =>
      'Great work. You can return to the exercise list.';

  @override
  String get workoutSessionEmpty =>
      'This session does not contain exercises yet.';

  @override
  String get workoutDayFallback => 'Workout day';

  @override
  String exerciseForceMetadata(Object value) {
    return 'Type: $value';
  }

  @override
  String exerciseLevelMetadata(Object value) {
    return 'Level: $value';
  }

  @override
  String exerciseMechanicMetadata(Object value) {
    return 'Mechanic: $value';
  }

  @override
  String exerciseEquipmentMetadata(Object value) {
    return 'Equipment: $value';
  }

  @override
  String exerciseCategoryMetadata(Object value) {
    return 'Category: $value';
  }

  @override
  String exercisePrimaryMusclesMetadata(Object value) {
    return 'Muscles: $value';
  }

  @override
  String exerciseSecondaryMusclesMetadata(Object value) {
    return 'Secondary: $value';
  }

  @override
  String get pauseSessionAction => 'Pause session';

  @override
  String get finishWorkoutAction => 'Finish workout';

  @override
  String sessionActionsIncomplete(Object completed, Object total) {
    return '$completed of $total exercises completed. Complete all exercises to finish.';
  }

  @override
  String get sessionActionsReady =>
      'All exercises are complete. You can finish now.';

  @override
  String get finishWorkoutConfirmationTitle => 'Finish this workout?';

  @override
  String get finishWorkoutConfirmationDescription =>
      'The session will be marked as completed and you will not be able to record more sets.';

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
  String get myAssignedRoutinesEmpty =>
      'You do not have any assigned routines yet.';

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
  String get pauseLabel => 'Pause';

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
