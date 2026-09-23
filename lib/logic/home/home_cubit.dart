import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo) : super(const HomeState());

  final ProductRepository _repo;

  /// Initial load (also used for pull-to-refresh).
  Future<void> load() async {
    if (state.status != HomeStatus.success) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final (categories, featured, deals, grid) = await (
        _repo.getCategories(),
        _repo.getProducts(limit: 5, sortBy: 'rating', order: 'desc'),
        _repo.getProducts(limit: 10, sortBy: 'discountPercentage', order: 'desc'),
        _fetchGrid(state.selectedCategory, 0),
      ).wait;
      emit(state.copyWith(
        status: HomeStatus.success,
        categories: categories,
        featured: featured.products,
        deals: deals.products,
        products: grid.products,
        hasMore: grid.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, error: _message(e)));
    }
  }

  Future<void> selectCategory(String? slug) async {
    if (slug == state.selectedCategory) return;
    emit(state.copyWith(selectedCategory: () => slug, isGridLoading: true));
    try {
      final page = await _fetchGrid(slug, 0);
      if (state.selectedCategory != slug) return; // user switched again
      emit(state.copyWith(products: page.products, hasMore: page.hasMore, isGridLoading: false));
    } catch (e) {
      emit(state.copyWith(isGridLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isGridLoading) return;
    emit(state.copyWith(isLoadingMore: true));
    final slug = state.selectedCategory;
    try {
      final page = await _fetchGrid(slug, state.products.length);
      if (state.selectedCategory != slug) return;
      emit(state.copyWith(
        products: [...state.products, ...page.products],
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  String _message(Object e) => e is ParallelWaitError
      ? 'Could not load the store. Please check your connection.'
      : e.toString();

  Future<ProductPage> _fetchGrid(String? slug, int skip) => slug == null
      ? _repo.getProducts(skip: skip)
      : _repo.getProductsByCategory(slug, skip: skip);
}
