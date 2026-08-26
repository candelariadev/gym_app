import 'dart:convert';
import 'dart:developer' as developer;

abstract interface class ApiTrace {
  void record(String event, Map<String, Object?> fields);
}

class DeveloperApiTrace implements ApiTrace {
  const DeveloperApiTrace();

  @override
  void record(String event, Map<String, Object?> fields) {
    developer.log(
      jsonEncode({
        'time': DateTime.now().toUtc().toIso8601String(),
        'event': event,
        ...fields,
      }),
      name: 'gymsas.app',
    );
  }
}

class NoopApiTrace implements ApiTrace {
  const NoopApiTrace();

  @override
  void record(String event, Map<String, Object?> fields) {}
}
