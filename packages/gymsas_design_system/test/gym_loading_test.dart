import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets(
    'overlay anuncia la espera y bloquea interacciones hasta terminar',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        var taps = 0;
        Widget app(bool loading) => MaterialApp(
          theme: AppTheme.light(),
          home: GymLoadingOverlay(
            isLoading: loading,
            label: 'Working',
            message: 'Please wait',
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Send'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpWidget(app(true));
        expect(find.bySemanticsLabel('Working. Please wait'), findsOneWidget);
        expect(find.bySemanticsLabel('Send'), findsNothing);
        expect(
          tester
              .widget<ModalBarrier>(
                find.descendant(
                  of: find.byType(GymLoadingOverlay),
                  matching: find.byType(ModalBarrier),
                ),
              )
              .dismissible,
          isFalse,
        );
        await tester.tapAt(tester.getCenter(find.text('Send')));
        expect(taps, 0);

        await tester.pumpWidget(app(false));
        await tester.pumpAndSettle();
        expect(find.byType(GymLoadingStatus), findsNothing);
        await tester.tap(find.text('Send'));
        expect(taps, 1);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('overlay funciona en pantalla pequena con texto grande', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: GymLoadingOverlay(
            isLoading: true,
            label: 'Conectando con Google…',
            message:
                'Estamos verificando tu acceso. Esto puede tardar unos momentos.',
            child: const Scaffold(),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
