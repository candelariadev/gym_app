import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'la aplicación no contiene bridges ni imports internos del proveedor',
    () {
      final presentationFiles = Directory('lib/features/payments')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in presentationFiles) {
        final source = file.readAsStringSync();
        expect(source, isNot(contains('package:flutter/services.dart')));
        expect(source, isNot(contains('gymsas_payments/src/')));
        expect(source, isNot(contains('MethodChannel(')));
      }

      final androidHost = File(
        'android/app/src/main/kotlin/com/gymsas/app/MainActivity.kt',
      ).readAsStringSync();
      final iosHost = File('ios/Runner/AppDelegate.swift').readAsStringSync();
      final appConfig = File(
        'lib/core/config/app_config.dart',
      ).readAsStringSync();
      expect(androidHost, isNot(contains('MercadoPago')));
      expect(androidHost, isNot(contains('MethodChannel')));
      expect(iosHost, isNot(contains('MercadoPago')));
      expect(iosHost, isNot(contains('FlutterMethodChannel')));
      expect(appConfig, isNot(contains('PAYMENT_API_URL')));
      expect(appConfig, isNot(contains('PLANS_API_URL')));
      expect(appConfig, isNot(contains('BFF_API_URL')));
      expect(appConfig, isNot(contains(':8088')));
      expect(appConfig, isNot(contains(':8089')));
    },
  );
}
