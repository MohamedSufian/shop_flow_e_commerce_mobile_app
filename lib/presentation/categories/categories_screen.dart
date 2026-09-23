import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/category_style.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../data/models/category.dart';
import '../../logic/categories/categories_cubit.dart';
import '../search/search_screen.dart';
import 'category_products_screen.dart';
import '../../core/l10n/l10n.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Tr('Categories'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, SearchScreen.route()),
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          switch (state.status) {
            case CategoriesStatus.loading:
              return _grid(
                itemCount: 10,
                builder: (_) => const AppShimmer(child: ShimmerBox(radius: 24)),
              );
            case CategoriesStatus.failure:
              return ErrorView(
                message: state.error ?? 'Could not load categories',
                onRetry: context.read<CategoriesCubit>().load,
              );
            case CategoriesStatus.success:
              return RefreshIndicator(
                onRefresh: context.read<CategoriesCubit>().load,
                child: _grid(
                  itemCount: state.categories.length,
                  builder: (i) => _CategoryTile(
                    category: state.categories[i],
                    index: i,
                    onTap: () => Navigator.push(
                      context,
                      CategoryProductsScreen.route(state.categories[i]),
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _grid({required int itemCount, required Widget Function(int) builder}) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) => builder(i),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({required this.category, required this.index, required this.onTap});

  final Category category;
  final int index;
  final VoidCallback onTap;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> with SingleTickerProviderStateMixin {
  // Staggered entrance animation.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 40 * (widget.index % 12)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(widget.category.slug);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    style.color.withValues(alpha: isDark ? 0.22 : 0.14),
                    style.color.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    bottom: -18,
                    child: Icon(style.icon, size: 96, color: style.color.withValues(alpha: 0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: style.color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: style.color.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(style.icon, color: Colors.white, size: 24),
                        ),
                        const Spacer(),
                        Text(
                          widget.category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Tr(
                              'Shop now',
                              style: theme.textTheme.labelMedium?.copyWith(color: style.color, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: style.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
