import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductDetailsState extends Equatable {
  final Product product;
  final List<Product> related;
  final bool relatedLoading;

  const ProductDetailsState({required this.product, this.related = const [], this.relatedLoading = true});

  ProductDetailsState copyWith({Product? product, List<Product>? related, bool? relatedLoading}) =>
      ProductDetailsState(
        product: product ?? this.product,
        related: related ?? this.related,
        relatedLoading: relatedLoading ?? this.relatedLoading,
      );

  @override
  List<Object?> get props => [product, related, relatedLoading];
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repo, Product product) : super(ProductDetailsState(product: product));

  final ProductRepository _repo;

  Future<void> load() async {
    // List endpoints already return the full product, so we only need related items.
    try {
      final page = await _repo.getProductsByCategory(state.product.category, limit: 11);
      final related = page.products.where((p) => p.id != state.product.id).take(10).toList();
      emit(state.copyWith(related: related, relatedLoading: false));
    } catch (_) {
      emit(state.copyWith(relatedLoading: false));
    }
  }
}
