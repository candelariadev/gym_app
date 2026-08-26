import 'package:flutter/foundation.dart';
import 'package:gymsas_clients/gymsas_clients.dart';

class MyTrainersController extends ChangeNotifier {
  MyTrainersController({
    required GetMyTrainersUseCase getMyTrainers,
  }) : _getMyTrainers = getMyTrainers;

  final GetMyTrainersUseCase _getMyTrainers;

  List<AdvisedTrainer> _trainers = const [];
  ClientCatalogErrorCode? _errorCode;
  bool _isLoading = false;
  bool _isDisposed = false;
  int _generation = 0;

  List<AdvisedTrainer> get trainers => List.unmodifiable(_trainers);
  ClientCatalogErrorCode? get errorCode => _errorCode;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    final generation = ++_generation;
    _isLoading = true;
    _errorCode = null;
    _notify();
    try {
      final trainers = await _getMyTrainers();
      if (_isDisposed || generation != _generation) return;
      _trainers = trainers;
    } on ClientCatalogException catch (error) {
      if (_isDisposed || generation != _generation) return;
      _errorCode = error.code;
      _trainers = const [];
    } on Object {
      if (_isDisposed || generation != _generation) return;
      _errorCode = ClientCatalogErrorCode.unexpected;
      _trainers = const [];
    } finally {
      if (!_isDisposed && generation == _generation) {
        _isLoading = false;
        _notify();
      }
    }
  }

  Future<void> retry() => load();

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
