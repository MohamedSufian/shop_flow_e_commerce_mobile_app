import 'package:flutter/material.dart';

import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer_box.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        children: [
          const Row(
            children: [
              ShimmerBox(width: 48, height: 48),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 90, height: 10, radius: 6),
                    SizedBox(height: 8),
                    ShimmerBox(width: 140, height: 16, radius: 6),
                  ],
                ),
              ),
              ShimmerBox(width: 48, height: 48),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(height: 54, radius: 18),
          const SizedBox(height: 24),
          const ShimmerBox(height: 170, radius: 26),
          const SizedBox(height: 28),
          SizedBox(
            height: 46,
            child: Row(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ShimmerBox(width: 110, height: 46, radius: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
            children: List.generate(4, (_) => const ProductCardSkeleton()),
          ),
        ],
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
        children: List.generate(count, (_) => const AppShimmer(child: ProductCardSkeleton())),
      ),
    );
  }
}
