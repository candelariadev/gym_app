import 'dart:async';
import 'dart:convert';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'offline_document_store.dart';

/// An explicitly opted-in, bounded query cache. Never caches auth or mutations.
class LocalFirstQueryClient implements GraphQlClient {
  LocalFirstQueryClient({
    required this.remote,
    required this.store,
    required this.scope,
    required this.canRequest,
    required this.cacheable,
  });
  final GraphQlClient remote;
  final OfflineDocumentStore store;
  final String? Function() scope;
  final bool Function() canRequest;
  final bool Function(String document) cacheable;
  final _refreshing = <String>{};
  bool _closed = false;

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    final account = scope();
    if (account == null) {
      throw const ApiClientException(ApiClientErrorCode.network);
    }
    if (!cacheable(document) || !RegExp(r'^\s*query\b').hasMatch(document)) {
      return remote.execute(
        document: document,
        variables: variables,
        accessToken: accessToken,
      );
    }
    final key = jsonEncode([document, variables]);
    final snapshot = await store.read(account);
    if (_closed || scope() != account) {
      throw const ApiClientException(ApiClientErrorCode.network);
    }
    final cached = (snapshot['queries'] as Map?)?[key];
    Future<Map<String, dynamic>> refresh() async {
      if (!canRequest() || scope() != account || _closed) {
        throw const ApiClientException(ApiClientErrorCode.network);
      }
      final result = await remote.execute(
        document: document,
        variables: variables,
        accessToken: accessToken,
      );
      if (_closed || scope() != account) {
        throw const ApiClientException(ApiClientErrorCode.network);
      }
      await store.update(account, (d) {
        final queries = Map<String, dynamic>.from(d['queries'] as Map? ?? {});
        queries.remove(key);
        queries[key] = result;
        while (queries.length > 128) {
          queries.remove(queries.keys.first);
        }
        d['queries'] = queries;
      });
      return result;
    }

    if (cached == null) return refresh();
    final refreshKey = '$account:$key';
    if (canRequest() && _refreshing.add(refreshKey)) {
      unawaited(
        refresh()
            .then<void>((_) {})
            .catchError((Object _) {})
            .whenComplete(() => _refreshing.remove(refreshKey)),
      );
    }
    return Map<String, dynamic>.from(cached as Map);
  }

  @override
  void close() {
    _closed = true;
    remote.close();
  }
}
