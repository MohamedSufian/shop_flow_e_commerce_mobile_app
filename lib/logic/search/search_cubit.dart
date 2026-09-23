import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../data/repositories/product_repository.dart';
import 'search_filter.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repo, this._storage) : super(SearchState(recent: _storage.recentSearches));

  final ProductRepository _repo;
  final LocalStorage _storage;
  Timer? _debounce;

  static const suggestions = ['Phone', 'Laptop', 'Perfume', 'Watch', 'Shoes', 'Sunglasses', 'Bag', 'Chair'];

  /// Called on every keystroke — debounced.
  void onQueryChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) {
      emit(state.copyWith(query: '', status: SearchStatus.idle, results: const [], filter: const SearchFilter()));
      return;
    }
    emit(state.copyWith(query: q));
    _debounce = Timer(const Duration(milliseconds: 450), () => _run(q));
  }

  /// Keyboard "search" pressed or a suggestion tapped — run now and remember it.
  Future<void> submit(String text) async {
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) return;
    final recent = await _storage.addRecentSearch(q);
    emit(state.copyWith(query: q, recent: recent));
    await _run(q);
  }

  Future<void> _run(String q) async {
    emit(state.copyWith(status: SearchStatus.loading, filter: const SearchFilter()));
    try {
      final page = await _repo.searchProducts(q, limit: 100);
      if (q != state.query) return; // stale response
      emit(state.copyWith(status: SearchStatus.success, results: page.products));
    } catch (e) {
      if (q != state.query) return;
      emit(state.copyWith(status: SearchStatus.failure, error: e.toString()));
    }
  }

  void retry() => _run(state.query);

  void applyFilter(SearchFilter filter) => emit(state.copyWith(filter: filter));

  Future<void> removeRecent(String q) async =>
      emit(state.copyWith(recent: await _storage.removeRecentSearch(q)));

  Future<void> clearRecent() async {
    await _storage.clearRecentSearches();
    emit(state.copyWith(recent: const []));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
