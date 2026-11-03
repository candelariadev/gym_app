import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/workout/application/workout_session_store.dart';
import 'package:gym_app/features/workout/domain/workout_session_data.dart';
import 'package:gym_app/features/workout/presentation/pages/workout_session_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets(
    'explica el check y habilita finalizar cuando todos los ejercicios terminan',
    (tester) async {
      final store = WorkoutSessionStore(initialSession: _session());
      addTearDown(store.dispose);
      String? finishedSessionId;

      await tester.pumpWidget(
        _TestApp(
          child: WorkoutSessionPage(
            store: store,
            onPauseSession: (_) async => true,
            onFinishSession: (sessionId) async {
              finishedSessionId = sessionId;
              return true;
            },
          ),
        ),
      );

      expect(find.text('Marcar serie como terminada'), findsOneWidget);
      expect(
        find.text(
          '0 de 1 ejercicios completados. Completa todos para finalizar.',
        ),
        findsOneWidget,
      );

      var finishButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Finalizar rutina'),
      );
      expect(finishButton.onPressed, isNull);

      await tester.ensureVisible(find.text('Marcar serie como terminada'));
      await tester.enterText(find.byType(TextField).last, '10');
      await tester.tap(find.text('Marcar serie como terminada'));
      await tester.pump();

      expect(find.text('Serie terminada'), findsOneWidget);
      await tester.ensureVisible(find.text('Completar y seguir'));
      await tester.tap(find.text('Completar y seguir'));
      await tester.pump();

      expect(
        find.text('Todos los ejercicios están completos. Ya puedes finalizar.'),
        findsOneWidget,
      );
      finishButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Finalizar rutina'),
      );
      expect(finishButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Finalizar rutina'));
      await tester.pumpAndSettle();
      expect(find.text('¿Finalizar esta rutina?'), findsOneWidget);

      await tester.tap(find.text('Finalizar rutina').last);
      await tester.pumpAndSettle();

      expect(finishedSessionId, 'session-1');
      store.skipRest();
    },
  );

  testWidgets('permite pausar desde la sesión sin volver al listado', (
    tester,
  ) async {
    final store = WorkoutSessionStore(initialSession: _session());
    addTearDown(store.dispose);
    String? pausedSessionId;

    await tester.pumpWidget(
      _TestApp(
        child: WorkoutSessionPage(
          store: store,
          onPauseSession: (sessionId) async {
            pausedSessionId = sessionId;
            return true;
          },
          onFinishSession: (_) async => true,
        ),
      ),
    );

    await tester.tap(find.text('Pausar sesión'));
    await tester.pumpAndSettle();

    expect(pausedSessionId, 'session-1');
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: child,
    );
  }
}

WorkoutSessionData _session() {
  return const WorkoutSessionData(
    sessionId: 'session-1',
    routineName: 'Rutina de fuerza',
    dayTitle: 'Lunes',
    estimatedDurationMinutes: 30,
    totalSeries: 1,
    status: 'IN_PROGRESS',
    exercises: [
      WorkoutExercise(
        order: 1,
        exerciseId: 'bench-press',
        name: 'Press de banca',
        seriesCount: 1,
        repetitionRange: '10 reps',
      ),
    ],
  );
}
