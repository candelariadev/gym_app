import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:gymsas_offline/gymsas_offline.dart';
import 'package:gymsas_workouts/gymsas_workouts.dart';

/// App lifecycle adapter; durable data and synchronization belong to packages.
class OfflineSyncController extends ChangeNotifier with WidgetsBindingObserver {
  OfflineSyncController(this.repository, {required this.onDataChanged});
  final OfflineWorkoutRepository repository;
  final VoidCallback onDataChanged;
  StreamSubscription<OfflineSyncState>? _subscription;
  OfflineSyncState get state => repository.state;
  int _revision = -1;
  bool _disposed = false;

  void start() {
    if (_subscription != null) return;
    WidgetsBinding.instance.addObserver(this);
    _subscription = repository.changes.listen((event) {
      if (_disposed) return;
      if (event.revision != _revision) {
        _revision = event.revision;
        onDataChanged();
      }
      notifyListeners();
    });
    repository.start();
  }

  Future<void> retry() => repository.synchronize(retryBlocked: true);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(repository.synchronize());
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
