import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/advised/presentation/pages/my_trainer_detail_page.dart';
import 'package:gym_app/features/advised/presentation/pages/my_trainers_page.dart';
import 'package:gym_app/l10n/app_localizations.dart';
import 'package:gymsas_clients/gymsas_clients.dart';

void main() {
  testWidgets('abre el resumen profesional al tocar el entrenador', (
    tester,
  ) async {
    final useCase = GetMyTrainersUseCase(_TrainerRepository());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          MyTrainerDetailPage.routeName: (_) => const MyTrainerDetailPage(),
        },
        home: MyTrainersPage(getMyTrainers: useCase),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trainer Demo'));
    await tester.pumpAndSettle();

    expect(find.text('Entrenador de fuerza'), findsOneWidget);
    expect(find.text('NSCA'), findsOneWidget);
    expect(find.text('3 años'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('muestra estado vacío cuando no hay entrenadores asignados', (
    tester,
  ) async {
    final useCase = GetMyTrainersUseCase(_EmptyTrainerRepository());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyTrainersPage(getMyTrainers: useCase),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tienes entrenadores asignados.'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });
}

class _TrainerRepository implements AdvisedTrainerRepository {
  @override
  Future<List<AdvisedTrainer>> getTrainers() async => const [
    AdvisedTrainer(
      user: 'trainerdemo_bd365a',
      name: 'Trainer Demo',
      email: '',
      plan: 'FREE',
      status: 'ACTIVE',
      bio: 'Entrenador de fuerza',
      certifications: ['NSCA'],
      experience: 3,
    ),
  ];
}

class _EmptyTrainerRepository implements AdvisedTrainerRepository {
  @override
  Future<List<AdvisedTrainer>> getTrainers() async => const [];
}
