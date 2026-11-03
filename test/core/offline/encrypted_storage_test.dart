import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_offline/gymsas_offline_native.dart';

void main() {
  test(
    'archivo cifrado sobrevive reapertura sin texto sensible visible',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'offline-encryption-test-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final key = List.generate(32, (i) => i);
      final first = EncryptedFileOfflineValueStorage(dir, key);
      await first.write('tenant/user', 'private-workout-value');
      final file = dir.listSync().whereType<File>().single;
      expect(
        await file.readAsString(),
        isNot(contains('private-workout-value')),
      );
      final reopened = EncryptedFileOfflineValueStorage(dir, key);
      expect(await reopened.read('tenant/user'), 'private-workout-value');
    },
  );

  test(
    'una escritura temporal incompleta no sustituye el ultimo snapshot',
    () async {
      final dir = await Directory.systemTemp.createTemp('offline-atomic-test-');
      addTearDown(() => dir.delete(recursive: true));
      final storage = EncryptedFileOfflineValueStorage(
        dir,
        List.generate(32, (i) => i),
      );
      await storage.write('account', 'acknowledged');
      final file = dir.listSync().whereType<File>().single;
      await File('${file.path}.tmp').writeAsString('interrupted');
      expect(await storage.read('account'), 'acknowledged');
      await storage.write('account', 'new-acknowledged');
      expect(await storage.read('account'), 'new-acknowledged');
    },
  );

  test(
    'cifrado de otra cuenta o clave incorrecta se rechaza sin borrar archivos',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'offline-integrity-test-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final storage = EncryptedFileOfflineValueStorage(
        dir,
        List.generate(32, (i) => i),
      );
      await storage.write('account-A', 'value-A');
      final fileA = dir.listSync().whereType<File>().single;
      await storage.write('account-B', 'value-B');
      final fileB = dir.listSync().whereType<File>().singleWhere(
        (f) => f.path != fileA.path,
      );
      await fileB.writeAsBytes(await fileA.readAsBytes(), flush: true);
      await expectLater(storage.read('account-B'), throwsA(anything));
      expect(await fileB.exists(), isTrue);
      final wrongKey = EncryptedFileOfflineValueStorage(
        dir,
        List.filled(32, 99),
      );
      await expectLater(wrongKey.read('account-A'), throwsA(anything));
      expect(await storage.read('account-A'), 'value-A');
    },
  );
}
