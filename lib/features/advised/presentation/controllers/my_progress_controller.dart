import 'package:flutter/foundation.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

class MyProgressController extends ChangeNotifier {
  MyProgressController(this._query, {DateTime? now}) {
    final today = now ?? DateTime.now();
    to = DateTime(today.year, today.month, today.day);
    from = to.subtract(const Duration(days: 29));
  }
  final GetWorkoutProgress? _query;
  late DateTime from, to;
  ProgressGranularity granularity = ProgressGranularity.day;
  ProgressMetric metric = ProgressMetric.sets;
  String? exerciseId;
  WorkoutProgress? progress;
  ProgressError? error;
  bool loading = false;
  bool _disposed = false;
  int _requestId = 0;
  String? _loadedKey;

  Future<void> load() async {
    final requestId = ++_requestId;
    final requestKey = '$from:$to:${granularity.name}:${exerciseId ?? ''}';
    loading = true;
    error = null;
    notifyListeners();
    final offset = DateTime.now().timeZoneOffset;
    final minutes = offset.inMinutes.abs();
    final timeZone =
        '${offset.isNegative ? '-' : '+'}${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
    try {
      if (_query == null) {
        throw const ProgressException(ProgressError.unavailable);
      }
      final next = await _query(
        ProgressRequest(
          from: from,
          to: to,
          granularity: granularity,
          timeZone: timeZone,
          exerciseId: exerciseId,
        ),
      );
      if (_disposed || requestId != _requestId) return;
      progress = next;
      _loadedKey = requestKey;
      from = next.from;
      to = next.to;
    } on Object catch (failure) {
      if (_disposed || requestId != _requestId) return;
      error = failure is ProgressException
          ? failure.code
          : ProgressError.unavailable;
      if (error != ProgressError.unavailable || _loadedKey != requestKey) {
        progress = null;
      }
    } finally {
      if (!_disposed && requestId == _requestId) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void selectMetric(ProgressMetric value) {
    metric = value;
    notifyListeners();
  }

  Future<void> selectExercise(String? value) {
    final normalized = value?.trim();
    exerciseId = normalized == null || normalized.isEmpty ? null : normalized;
    return load();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
