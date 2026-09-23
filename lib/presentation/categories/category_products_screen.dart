import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/shop_actions.dart';
import '../../core/utils/category_style.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/product_grid.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../logic/product_list/product_list_cubit.dart';
import '../product_details/product_details_screen.dart';
import '../../core/l10n/l10n.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final Category category;

  static Route<void> route(Category category) =>
      MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category));

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProductRepository>();
    return BlocProvider(
      create: (_) => ProductListCubit((skip) => repo.getProductsByCategory(category.slug, skip: skip))..load(),
      child: _View(category: category),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.category});
  final Category category;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        context.read<ProductListCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openProduct(Product p) => Navigator.push(context, ProductDetailsScreen.route(p, heroPrefix: 'cat'));
  void _addToCart(Product p) => addToCart(context, p);

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(widget.category.slug);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<ProductListCubit, ProductListState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 170,
                backgroundColor: style.color,
                foregroundColor: Colors.white,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
                  title: Text(
                    widget.category.name,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 18),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [style.color, Color.lerp(style.color, Colors.black, 0.35)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -30,
                          child: Icon(style.icon, size: 170, color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        if (state.status == ProductListStatus.success)
                          PositionedDirectional(
                            start: 56,
                            bottom: 46,
                            child: Text(
                              context.tr('{n} products', {'n': state.total}),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ..._content(context, state),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(BuildContext context, ProductListState state) {
    switch (state.status) {
      case ProductListStatus.loading:
        return [const SliverProductGridSkeleton()];
      case ProductListStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              message: state.error ?? 'Failed to load',
              onRetry: context.read<ProductListCubit>().load,
            ),
          ),
        ];
      case ProductListStatus.success:
        if (state.products.isEmpty) {
          return [
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(icon: Icons.inventory_2_outlined, title: 'No products yet'),
            ),
          ];
        }
        return [
          SliverProductGrid(
            products: state.products,
            heroPrefix: 'cat',
            onTap: _openProduct,
            onAddToCart: _addToCart,
          ),
        ];
    }
  }
}
