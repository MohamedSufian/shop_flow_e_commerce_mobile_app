import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/category_style.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/shop_actions.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/product_details/product_details_cubit.dart';
import 'widgets/expandable_text.dart';
import 'widgets/image_gallery.dart';
import 'widgets/info_tiles.dart';
import 'widgets/reviews_section.dart';
import '../../core/l10n/l10n.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product, required this.heroTag});

  final Product product;
  final String heroTag;

  /// [heroPrefix] must match the ProductCard it was opened from.
  static Route<void> route(Product product, {String heroPrefix = 'grid'}) => MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product, heroTag: '$heroPrefix-${product.id}'),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailsCubit(context.read<ProductRepository>(), product)..load(),
      child: _DetailsView(heroTag: heroTag),
    );
  }
}

class _DetailsView extends StatefulWidget {
  const _DetailsView({required this.heroTag});
  final String heroTag;

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  int _qty = 1;

  void _addToCart(Product p, {int quantity = 1}) => addToCart(context, p, quantity: quantity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);

    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final p = state.product;
        final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

        return Scaffold(
          backgroundColor: scheme.surfaceContainerHighest,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ---------- Gallery ----------
              SliverAppBar(
                pinned: true,
                expandedHeight: size.height * 0.46,
                backgroundColor: scheme.surfaceContainerHighest,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 16,
                title: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    _RoundButton(
                      icon: Icons.share_outlined,
                      onTap: () => showAppSnack(context, 'Link copied', icon: Icons.link_rounded),
                    ),
                    const SizedBox(width: 10),
                    BlocSelector<FavoritesCubit, List<Product>, bool>(
                      selector: (favs) => favs.any((f) => f.id == p.id),
                      builder: (context, fav) => _RoundButton(
                        icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: fav ? AppColors.error : null,
                        onTap: () => toggleFavorite(context, p),
                      ),
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: kToolbarHeight + 4, bottom: 36),
                      child: ImageGallery(images: images, heroTag: widget.heroTag),
                    ),
                  ),
                ),
              ),

              // ---------- Content sheet ----------
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(product: p),
                      const SizedBox(height: 20),
                      _PriceRow(
                        product: p,
                        qty: _qty,
                        onQty: (v) => setState(() => _qty = v),
                      ),
                      const SizedBox(height: 24),
                      InfoTiles(product: p),
                      const SizedBox(height: 26),
                      Tr('Description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ExpandableText(p.description),
                      if (p.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: p.tags
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '#$t',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      if (p.reviews.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Tr('Ratings & Reviews', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ReviewsSection(reviews: p.reviews, rating: p.rating),
                      ],
                    ],
                  ),
                ),
              ),

              // ---------- Related ----------
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: theme.scaffoldBackgroundColor,
                  child: _Related(
                    products: state.related,
                    loading: state.relatedLoading,
                    onAddToCart: (p) => _addToCart(p),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: ColoredBox(color: theme.scaffoldBackgroundColor),
              ),
            ],
          ),
          bottomNavigationBar: _BottomBar(
            total: p.price * _qty,
            enabled: p.inStock,
            onAdd: () {
              _addToCart(p, quantity: _qty);
              setState(() => _qty = 1);
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = CategoryStyle.of(product.category);
    final lowStock = product.stock > 0 && product.stock <= 10;
    final stockColor = !product.inStock
        ? AppColors.error
        : lowStock
            ? AppColors.warning
            : AppColors.success;
    final stockText = !product.inStock
        ? 'Out of stock'
        : lowStock
            ? context.tr('Only {n} left', {'n': product.stock})
            : 'In stock';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(style.icon, size: 14, color: style.color),
                  const SizedBox(width: 5),
                  Text(
                    product.category.replaceAll('-', ' ').capitalized,
                    style: TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: stockColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(context.tr(stockText), style: TextStyle(color: stockColor, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (product.brand != null)
          Text(
            product.brand!.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1.2),
          ),
        const SizedBox(height: 4),
        Text(product.title, style: theme.textTheme.headlineSmall?.copyWith(height: 1.25)),
        const SizedBox(height: 10),
        Row(
          children: [
            StarRow(rating: product.rating, size: 18),
            const SizedBox(width: 8),
            Text(product.rating.toStringAsFixed(1), style: theme.textTheme.titleSmall),
            const SizedBox(width: 6),
            Text(context.tr('({n} reviews)', {'n': product.reviews.length}), style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.qty, required this.onQty});

  final Product product;
  final int qty;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    product.price.asPrice,
                    style: theme.textTheme.headlineMedium?.copyWith(color: scheme.primary, fontSize: 28),
                  ),
                  if (product.hasDiscount) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discountPercentage.round()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
              if (product.hasDiscount)
                Text(
                  product.originalPrice.asPrice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ),
        QuantityStepper(
          value: qty,
          max: product.stock < 1 ? 1 : product.stock,
          onChanged: onQty,
        ),
      ],
    );
  }
}

class _Related extends StatelessWidget {
  const _Related({required this.products, required this.loading, required this.onAddToCart});

  final List<Product> products;
  final bool loading;
  final ValueChanged<Product> onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (!loading && products.isEmpty) return const SizedBox(height: 24);
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 24),
      child: Column(
        children: [
          const SectionHeader(title: 'You may also like'),
          const SizedBox(height: 14),
          SizedBox(
            height: 262,
            child: loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return ProductCard(
                        product: p,
                        width: 170,
                        heroPrefix: 'related',
                        onTap: () => Navigator.push(
                          context,
                          ProductDetailsScreen.route(p, heroPrefix: 'related'),
                        ),
                        onAddToCart: () => onAddToCart(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.total, required this.enabled, required this.onAdd});

  final double total;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -6)),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tr('Total price', style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  total.asPrice,
                  key: ValueKey(total),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GradientButton(
              label: enabled ? 'Add to Cart' : 'Out of stock',
              icon: Icons.shopping_bag_outlined,
              onPressed: enabled ? onAdd : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(icon, key: ValueKey(icon), size: 20, color: color ?? scheme.onSurface),
          ),
        ),
      ),
    );
  }
}
