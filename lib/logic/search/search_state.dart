import 'package:equatable/equatable.dart';

import '../../data/models/product.dart';
import 'search_filter.dart';

enum SearchStatus { idle, loading, success, failure }

class SearchState extends Equatable {
  final String query;
  final SearchStatus status;
  final List<Product> results;
  final List<String> recent;
  final SearchFilter filter;
  final String? error;

  const SearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = const [],
    this.recent = const [],
    this.filter = const SearchFilter(),
    this.error,
  });

  /// Results after sort & filter.
  List<Product> get visible => filter.apply(results);

  double get priceFloor => results.isEmpty ? 0 : results.map((p) => p.price).reduce((a, b) => a < b ? a : b).floorToDouble();
  double get priceCeil => results.isEmpty ? 0 : results.map((p) => p.price).reduce((a, b) => a > b ? a : b).ceilToDouble();

  SearchState copyWith({
    String? query,
    SearchStatus? status,
    List<Product>? results,
    List<String>? recent,
    SearchFilter? filter,
    String? error,
  }) =>
      SearchState(
        query: query ?? this.query,
        status: status ?? this.status,
        results: results ?? this.results,
        recent: recent ?? this.recent,
        filter: filter ?? this.filter,
        error: error,
      );

  @override
  List<Object?> get props => [query, status, results, recent, filter, error];
}
