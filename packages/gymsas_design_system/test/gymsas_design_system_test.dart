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
}
