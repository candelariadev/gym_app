import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gymsas_exercises/gymsas_exercises.dart';

class ExerciseCatalogController extends ChangeNotifier {
  ExerciseCatalogController({
    required GetExercisesUseCase getExercises,
    this.pageSize = 20,
    this.searchDebounce = const Duration(milliseconds: 350),
  }) : _getExercises = getExercises,
       _request = ExerciseCatalogRequest(size: pageSize);

  final GetExercisesUseCase _getExercises;
  final int pageSize;
  final Duration searchDebounce;

  ExerciseCatalogRequest _request;
  List<ExerciseCatalogItem> _items = const [];
  ExerciseCatalogErrorCode? _errorCode;
  Timer? _searchTimer;
  int _generation = 0;
  int _total = 0;
  int _totalPages = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isDisposed = false;

  List<ExerciseCatalogItem> get items => List.unmodifiable(_items);
  ExerciseCatalogRequest get filters => _request;
  ExerciseCatalogErrorCode? get errorCode => _errorCode;
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _request.page + 1 < _totalPages;
  bool get hasActiveFilters =>
      _request.level != null ||
      _request.category != null ||
      _request.equipment != null ||
      _request.muscle != null;

  Future<void> loadInitial() => _load(reset: true);

  void updateSearch(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () {
      final search = value.trim();
      _request = _request.copyWith(
        search: search,
        clearSearch: search.isEmpty,
        page: 0,
      );
      _load(reset: true);
    });
  }

  Future<void> applyFilters({
    String? level,
    String? category,
    String? equipment,
    String? muscle,
  }) {
    _request = ExerciseCatalogRequest(
      search: _request.search,
      level: level,
      category: category,
      equipment: equipment,
      muscle: muscle,
      size: pageSize,
    );
    return _load(reset: true);
  }

  Future<void> clearFilters() => applyFilters();

  Future<void> retry() => _load(reset: true);

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    final generation = reset ? ++_generation : _generation;
    if (reset) {
      _isLoading = true;
      _isLoadingMore = false;
      _errorCode = null;
      _items = const [];
      _total = 0;
      _totalPages = 0;
    } else {
      _isLoadingMore = true;
    }
    _notify();

    final target = _request.copyWith(page: reset ? 0 : _request.page + 1);
    try {
      final page = await _getExercises(target);
      if (_isDisposed || generation != _generation) return;
      if (reset) {
        _items = page.items;
      } else {
        final seen = _items.map((item) => item.id).toSet();
        _items = [..._items, ...page.items.where((item) => seen.add(item.id))];
      }
      _request = target.copyWith(page: page.page);
      _total = page.total;
      _totalPages = page.totalPages;
      _errorCode = null;
    } on ExerciseCatalogException catch (error) {
      if (_isDisposed || generation != _generation) return;
      _errorCode = error.code;
    } on Object {
      if (_isDisposed || generation != _generation) return;
      _errorCode = ExerciseCatalogErrorCode.unexpected;
    } finally {
      if (!_isDisposed && generation == _generation) {
        _isLoading = false;
        _isLoadingMore = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }
}
