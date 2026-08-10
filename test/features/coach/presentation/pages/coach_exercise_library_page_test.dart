import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/coach/presentation/pages/coach_exercise_library_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

void main() {
  testWidgets('muestra nombre y taxonomia en español', (tester) async {
    final repository = _CatalogRepository();
    await tester.pumpWidget(_host(const Locale('es'), repository));
    await tester.pumpAndSettle();

    expect(find.text('Catálogo de ejercicios'), findsOneWidget);
    expect(find.text('Press de banca'), findsOneWidget);
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Pecho'), findsOneWidget);
  });

  testWidgets('busca en servidor y presenta el catálogo en inglés', (
    tester,
  ) async {
    final repository = _CatalogRepository();
    await tester.pumpWidget(_host(const Locale('en'), repository));
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'press');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repository.lastRequest?.search, 'press');
    expect(repository.lastRequest?.page, 0);
  });
}

Widget _host(Locale locale, ExerciseCatalogRepository repository) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: CoachExerciseLibraryPage(
      getExercisesUseCase: GetExercisesUseCase(repository),
      selectionMode: true,
    ),
  );
}

class _CatalogRepository implements ExerciseCatalogRepository {
  ExerciseCatalogRequest? lastRequest;

  @override
  Future<ExerciseCatalogPage> getPage(ExerciseCatalogRequest request) async {
    lastRequest = request;
    return ExerciseCatalogPage(
      items: const [
        ExerciseCatalogItem(
          id: '1',
          exerciseId: 'bench-press',
          name: LocalizedValue(en: 'Bench Press', es: 'Press de banca'),
          level: 'intermediate',
          equipment: 'barbell',
          category: 'strength',
          primaryMuscles: ['chest'],
          secondaryMuscles: ['triceps'],
          instructions: LocalizedStringList(
            en: ['Press the bar.'],
            es: ['Empuja la barra.'],
          ),
          images: [],
        ),
      ],
      page: request.page,
      size: request.size,
      total: 1,
      totalPages: 1,
    );
  }
}
