import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/shop_actions.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/product.dart';
import '../../logic/home/home_cubit.dart';
import '../../logic/home/home_state.dart';
import '../product_details/product_details_screen.dart';
import '../search/search_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/deals_list.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/promo_carousel.dart';
import '../../core/l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSeeAllCategories, this.onOpenProfile});

  final VoidCallback? onSeeAllCategories;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
      context.read<HomeCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Wired to real screens in the next steps.
  void _openProduct(Product p, {String hero = 'grid'}) =>
      Navigator.push(context, ProductDetailsScreen.route(p, heroPrefix: hero));
  void _addToCart(Product p) => addToCart(context, p);
  void _openSearch() => Navigator.push(context, SearchScreen.route());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            switch (state.status) {
              case HomeStatus.initial:
              case HomeStatus.loading:
                return const HomeSkeleton();
              case HomeStatus.failure:
                return ErrorView(
                  message: state.error ?? 'Something went wrong',
                  onRetry: () => context.read<HomeCubit>().load(),
                );
              case HomeStatus.success:
                return _buildContent(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    final cubit = context.read<HomeCubit>();
    final theme = Theme.of(context);

    final selectedName = state.selectedCategory == null
        ? 'Popular Products'
        : state.categories
            .firstWhere((c) => c.slug == state.selectedCategory, orElse: () => state.categories.first)
            .name;

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: HomeHeader(onAvatarTap: widget.onOpenProfile)),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(child: HomeSearchBar(onTap: _openSearch, onFilterTap: _openSearch)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (state.featured.isNotEmpty)
            SliverToBoxAdapter(child: PromoCarousel(products: state.featured, onTap: (p) => _openProduct(p, hero: 'banner'))),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          if (state.deals.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: DealsList(products: state.deals, onTap: (p) => _openProduct(p, hero: 'deal'), onAddToCart: _addToCart),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Categories', action: 'See all', onAction: widget.onSeeAllCategories),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: state.categories,
              selected: state.selectedCategory,
              onSelected: cubit.selectCategory,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: selectedName,
              action: state.isGridLoading ? null : context.tr('{n} items', {'n': state.products.length}),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          if (state.isGridLoading)
            const GridSkeleton()
          else if (state.products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Tr('No products found', style: theme.textTheme.bodyMedium),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                itemCount: state.products.length,
                itemBuilder: (_, i) {
                  final p = state.products[i];
                  return ProductCard(
                    product: p,
                    onTap: () => _openProduct(p),
                    onAddToCart: () => _addToCart(p),
                  );
                },
              ),
            ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
              ),
            ),
          // Room for the floating bottom nav.
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
