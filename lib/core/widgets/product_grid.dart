import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import 'product_card.dart';
import 'shimmer_box.dart';

const productGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.62,
);

/// Reusable sliver grid of [ProductCard]s.
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.products,
    this.onTap,
    this.onAddToCart,
    this.heroPrefix = 'grid',
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<Product> products;
  final ValueChanged<Product>? onTap;
  final ValueChanged<Product>? onAddToCart;
  final String heroPrefix;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.builder(
        gridDelegate: productGridDelegate,
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return ProductCard(
            product: p,
            heroPrefix: heroPrefix,
            onTap: () => onTap?.call(p),
            onAddToCart: () => onAddToCart?.call(p),
          );
        },
      ),
    );
  }
}

class SliverProductGridSkeleton extends StatelessWidget {
  const SliverProductGridSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.builder(
        gridDelegate: productGridDelegate,
        itemCount: count,
        itemBuilder: (_, _) => const AppShimmer(child: ProductCardSkeleton()),
      ),
    );
  }
}
