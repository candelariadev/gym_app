import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/app/gym_app.dart';

void main() {
  testWidgets('muestra validaciones cuando el formulario esta vacio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Entrar como Asesorado'));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contrasena'), findsOneWidget);
  });

  testWidgets('navega al dashboard correcto segun el rol seleccionado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Entrenador'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'coach@gym.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar como Entrenador'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard de Entrenador'), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Volver al login'), findsOneWidget);
  });
}
