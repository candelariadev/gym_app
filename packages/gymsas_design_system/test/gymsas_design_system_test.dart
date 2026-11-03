import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets('el boton reutilizable muestra la etiqueta recibida', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: GymPrimaryButton(label: 'Action', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets('GymSurface y GymSectionCard componen contenido reutilizable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: GymSectionCard(
            title: 'Section',
            subtitle: 'Description',
            child: GymSurface(
              elevation: GymSurfaceElevation.none,
              child: Text('Content'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Section'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('GymChoiceFilter notifica la opción elegida', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: GymChoiceFilter(
            label: 'Equipment',
            values: const ['Barbell', 'Dumbbell'],
            selectedValue: 'Barbell',
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dumbbell'));
    expect(selected, 'Dumbbell');
  });

  testWidgets('GymBrandedHeader delega la navegación', (tester) async {
    var didGoBack = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: GymBrandedHeader(
            title: 'FitCoach',
            onBack: () => didGoBack = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(didGoBack, isTrue);
  });

  testWidgets('GymDropdownField expone opciones tipadas', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: GymDropdownField<String>(
            label: 'Level',
            value: 'beginner',
            options: const [
              GymSelectOption(value: 'beginner', label: 'Beginner'),
              GymSelectOption(value: 'expert', label: 'Expert'),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expert').last);
    await tester.pumpAndSettle();
    expect(selected, 'expert');
  });

  testWidgets('los organismos de cliente y rutina reciben contenido externo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ListView(
            children: [
              GymClientListCard(
                name: 'Kevin',
                subtitle: '1 workout',
                initials: 'KR',
                statusLabel: 'Active',
                onTap: () {},
              ),
              GymWorkoutSummaryCard(
                title: 'Upper body',
                statusLabel: 'Active',
                metadata: 'Monday',
                tags: const ['Monday · 3 exercises'],
                actionLabel: 'View details',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Kevin'), findsOneWidget);
    expect(find.text('Upper body'), findsOneWidget);
    expect(find.text('Monday · 3 exercises'), findsOneWidget);
    expect(find.text('View details'), findsOneWidget);
  });

  testWidgets('GymCompletionToggle comunica claramente el estado', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: GymCompletionToggle(
              isCompleted: completed,
              label: 'Mark set as finished',
              completedLabel: 'Set finished',
              onPressed: () => setState(() => completed = !completed),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mark set as finished'), findsOneWidget);
    await tester.tap(find.text('Mark set as finished'));
    await tester.pumpAndSettle();
    expect(find.text('Set finished'), findsOneWidget);
  });

  testWidgets('GymSessionActionBar mantiene disponibles las acciones', (
    tester,
  ) async {
    var paused = false;
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: GymSessionActionBar(
            statusText: 'Ready',
            pauseLabel: 'Pause',
            finishLabel: 'Finish',
            canFinish: true,
            onPause: () => paused = true,
            onFinish: () => finished = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pause'));
    await tester.tap(find.text('Finish'));
    expect(paused, isTrue);
    expect(finished, isTrue);
  });
}
