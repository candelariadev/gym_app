import 'package:flutter/foundation.dart';
import 'package:gymsas_clients/gymsas_clients.dart';

class TrainerClientsController extends ChangeNotifier {
  TrainerClientsController({
    required GetTrainerClientsUseCase getTrainerClients,
  }) : _getTrainerClients = getTrainerClients;

  final GetTrainerClientsUseCase _getTrainerClients;

  List<TrainerClient> _clients = const [];
  ClientCatalogErrorCode? _errorCode;
  bool _isLoading = false;
  bool _isDisposed = false;
  int _generation = 0;

  List<TrainerClient> get clients => List.unmodifiable(_clients);
  ClientCatalogErrorCode? get errorCode => _errorCode;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    final generation = ++_generation;
    _isLoading = true;
    _errorCode = null;
    _notify();
    try {
      final clients = await _getTrainerClients();
      if (_isDisposed || generation != _generation) return;
      _clients = clients;
    } on ClientCatalogException catch (error) {
      if (_isDisposed || generation != _generation) return;
      _errorCode = error.code;
    } on Object {
      if (_isDisposed || generation != _generation) return;
      _errorCode = ClientCatalogErrorCode.unexpected;
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
