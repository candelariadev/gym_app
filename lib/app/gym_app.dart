import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/coach/presentation/pages/coach_assign_routine_page.dart';
import '../features/coach/presentation/pages/coach_create_routine_page.dart';
import '../features/coach/presentation/pages/coach_client_profile_page.dart';
import '../features/coach/presentation/pages/coach_exercise_library_page.dart';
import '../features/coach/presentation/pages/coach_routine_history_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/workout/presentation/pages/workout_session_page.dart';
import '../features/workout/presentation/pages/workout_today_page.dart';

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        DashboardPage.routeName: (_) => const DashboardPage(),
        CoachClientProfilePage.routeName: (_) => const CoachClientProfilePage(),
        CoachCreateRoutinePage.routeName: (_) => const CoachCreateRoutinePage(),
        CoachAssignRoutinePage.routeName: (_) => const CoachAssignRoutinePage(),
        CoachExerciseLibraryPage.routeName: (_) => const CoachExerciseLibraryPage(),
        CoachRoutineHistoryPage.routeName: (_) => const CoachRoutineHistoryPage(),
        WorkoutTodayPage.routeName: (_) => const WorkoutTodayPage(),
        WorkoutSessionPage.routeName: (_) => const WorkoutSessionPage(),
      },
    );
  }
}
