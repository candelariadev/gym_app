import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'dominio de notificaciones y presentación no importan SDK ni transporte',
    () {
      for (final directory in [
        'packages/gymsas_notifications/lib/src/domain',
        'lib/features/notifications',
        'lib/features/coach/application/routine_assignment_controller.dart',
      ]) {
        final type = FileSystemEntity.typeSync(directory);
        final files = type == FileSystemEntityType.file
            ? [File(directory)]
            : Directory(directory)
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where((f) => f.path.endsWith('.dart'));
        for (final file in files) {
          final source = file.readAsStringSync();
          expect(source, isNot(contains('package:firebase_')));
          expect(source, isNot(contains('package:http/')));
          expect(source, isNot(contains('MethodChannel(')));
          expect(source, isNot(contains('gymsas_notifications/src/')));
        }
      }
    },
  );
  test('design system no depende de notificaciones, Firebase ni persistencia', () {
    for (final path in [
      'packages/gymsas_design_system/lib/src/molecules/gym_status_message.dart',
      'packages/gymsas_design_system/lib/src/organisms/gym_action_status_card.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('gymsas_notifications')));
      expect(source, isNot(contains('firebase')));
      expect(source, isNot(contains('Color(0x')));
    }
  });
}
