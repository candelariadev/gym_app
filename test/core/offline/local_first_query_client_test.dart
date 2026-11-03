import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_offline/gymsas_offline.dart';

void main() {
  test(
    'catalogo consultado sobrevive reapertura y no depende de la red',
    () async {
      final storage = _Storage();
      var online = true;
      final remote = _Client();
      LocalFirstQueryClient create() => LocalFirstQueryClient(
        remote: remote,
        store: SerializedOfflineDocumentStore(storage),
        scope: () => 'tenant/user',
        canRequest: () => online,
        cacheable: (_) => true,
      );
      final first = create();
      expect(await first.execute(document: 'query Exercises { exercises }'), {
        'exercises': 'cached',
      });
      online = false;
      final reopened = create();
      expect(
        await reopened.execute(document: 'query Exercises { exercises }'),
        {'exercises': 'cached'},
      );
      expect(remote.calls, 1);
    },
  );

  test(
    'mutaciones nunca se guardan como consultas aunque el callback las acepte',
    () async {
      final storage = _Storage();
      final remote = _Client();
      final client = LocalFirstQueryClient(
        remote: remote,
        store: SerializedOfflineDocumentStore(storage),
        scope: () => 'user',
        canRequest: () => true,
        cacheable: (_) => true,
      );
      await client.execute(document: 'mutation DoNotCache { update }');
      await client.execute(document: 'mutation DoNotCache { update }');
      expect(remote.calls, 2);
      expect(storage.values, isEmpty);
    },
  );

  test(
    'respuesta de catalogo de cuenta anterior no se persiste en la nueva',
    () async {
      final storage = _Storage();
      final remote = _Client()..gate = Completer<Map<String, dynamic>>();
      var scope = 'account-A';
      final store = SerializedOfflineDocumentStore(storage);
      final client = LocalFirstQueryClient(
        remote: remote,
        store: store,
        scope: () => scope,
        canRequest: () => true,
        cacheable: (_) => true,
      );
      final pending = client.execute(document: 'query Exercises { exercises }');
      final rejected = expectLater(pending, throwsA(isA<ApiClientException>()));
      await Future<void>.delayed(Duration.zero);
      scope = 'account-B';
      remote.gate!.complete({'exercises': 'private-A'});
      await rejected;
      expect((await store.read(scope))['queries'], isNull);
      expect((await store.read('account-A'))['queries'], isNull);
    },
  );
}

class _Storage implements OfflineValueStorage {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _Client implements GraphQlClient {
  int calls = 0;
  Completer<Map<String, dynamic>>? gate;
  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    calls++;
    return gate?.future ?? {'exercises': 'cached'};
  }

  @override
  void close() {}
}
