import 'package:equatable/equatable.dart';

import '../../data/models/category.dart';
import '../../data/models/product.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Category> categories;
  final List<Product> featured; // banner carousel
  final List<Product> deals; // flash deals row
  final List<Product> products; // main grid
  final String? selectedCategory; // null = All
  final bool isGridLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const HomeState({
    this.status = HomeStatus.initial,
    this.categories = const [],
    this.featured = const [],
    this.deals = const [],
    this.products = const [],
    this.selectedCategory,
    this.isGridLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Category>? categories,
    List<Product>? featured,
    List<Product>? deals,
    List<Product>? products,
    String? Function()? selectedCategory,
    bool? isGridLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      featured: featured ?? this.featured,
      deals: deals ?? this.deals,
      products: products ?? this.products,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      isGridLoading: isGridLoading ?? this.isGridLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        featured,
        deals,
        products,
        selectedCategory,
        isGridLoading,
        isLoadingMore,
        hasMore,
        error,
      ];
}
