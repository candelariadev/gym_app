import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

void main() {
  testWidgets('estado de sincronizacion bloquea reintentos simultaneos', (
    tester,
  ) async {
    var retries = 0;
    Widget app(bool busy) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: GymSyncStatus(
          message: 'Saved locally',
          actionLabel: 'Retry',
          busy: busy,
          onAction: () => retries++,
        ),
      ),
    );
    await tester.pumpWidget(app(true));
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(app(false));
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
  testWidgets(
    'mensaje largo y texto accesible no desbordan una pantalla pequena',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: GymSyncStatus(
                message:
                    'Los cambios se conservaron localmente. Revisa antes de reintentar.',
                actionLabel: 'Reintentar',
                onAction: () {},
                warning: true,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
