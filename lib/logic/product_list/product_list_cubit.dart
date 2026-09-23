import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';

enum ProductListStatus { loading, success, failure }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> products;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;

  const ProductListState({
    this.status = ProductListStatus.loading,
    this.products = const [],
    this.total = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    String? error,
  }) =>
      ProductListState(
        status: status ?? this.status,
        products: products ?? this.products,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: error,
      );

  @override
  List<Object?> get props => [status, products, total, hasMore, isLoadingMore, error];
}

typedef PageFetcher = Future<ProductPage> Function(int skip);

/// Generic paginated product list (used by category pages, later by others).
class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit(this._fetch) : super(const ProductListState());

  final PageFetcher _fetch;

  Future<void> load() async {
    emit(const ProductListState());
    try {
      final page = await _fetch(0);
      emit(ProductListState(
        status: ProductListStatus.success,
        products: page.products,
        total: page.total,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProductListStatus.failure, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.status != ProductListStatus.success) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _fetch(state.products.length);
      emit(state.copyWith(
        products: [...state.products, ...page.products],
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
