import 'package:equatable/equatable.dart';

import '../../data/models/product.dart';

enum SortOption {
  relevance('Relevance'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  rating('Top Rated'),
  discount('Biggest Discount');

  const SortOption(this.label);
  final String label;
}

/// Client-side sort & filter applied on top of API search results.
class SearchFilter extends Equatable {
  final SortOption sort;
  final double? minPrice;
  final double? maxPrice;
  final double minRating;

  const SearchFilter({
    this.sort = SortOption.relevance,
    this.minPrice,
    this.maxPrice,
    this.minRating = 0,
  });

  bool get isActive => sort != SortOption.relevance || minPrice != null || maxPrice != null || minRating > 0;

  int get activeCount =>
      (sort != SortOption.relevance ? 1 : 0) + (minPrice != null || maxPrice != null ? 1 : 0) + (minRating > 0 ? 1 : 0);

  List<Product> apply(List<Product> input) {
    final list = input.where((p) {
      if (minPrice != null && p.price < minPrice!) return false;
      if (maxPrice != null && p.price > maxPrice!) return false;
      if (p.rating < minRating) return false;
      return true;
    }).toList();

    switch (sort) {
      case SortOption.relevance:
        break;
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.discount:
        list.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    }
    return list;
  }

  @override
  List<Object?> get props => [sort, minPrice, maxPrice, minRating];
}
