import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/empty_view.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/product_grid.dart';
import '../../data/models/product.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../product_details/product_details_screen.dart';
import '../../core/l10n/l10n.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onStartShopping});

  final VoidCallback? onStartShopping;

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Tr('Clear favorites?'),
        content: const Tr('All saved products will be removed from your list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Tr('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Tr('Clear')),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<FavoritesCubit>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<FavoritesCubit, List<Product>>(
      builder: (context, favs) {
        return Scaffold(
          appBar: AppBar(
            title: const Tr('Favorites'),
            actions: [
              if (favs.isNotEmpty)
                IconButton(
                  tooltip: context.tr('Clear all'),
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: favs.isEmpty
                ? EmptyView(
                    key: const ValueKey('empty'),
                    icon: Icons.favorite_border_rounded,
                    title: 'No favorites yet',
                    subtitle: 'Tap the heart on any product\nto save it here for later.',
                    action: onStartShopping == null
                        ? null
                        : SizedBox(
                            width: 200,
                            child: GradientButton(label: 'Start shopping', onPressed: onStartShopping),
                          ),
                  )
                : CustomScrollView(
                    key: const ValueKey('list'),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                          child: Text(
                            context.tr('{n} saved items', {'n': favs.length}),
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      SliverProductGrid(
                        products: favs,
                        heroPrefix: 'fav',
                        onTap: (p) => Navigator.push(context, ProductDetailsScreen.route(p, heroPrefix: 'fav')),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
