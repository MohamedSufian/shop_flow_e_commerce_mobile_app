import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/shop_actions.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/product_grid.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../logic/search/search_cubit.dart';
import '../../logic/search/search_filter.dart';
import '../../logic/search/search_state.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/filter_sheet.dart';
import '../../core/l10n/l10n.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  static Route<void> route({String? initialQuery}) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => SearchScreen(initialQuery: initialQuery),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SearchCubit(context.read<ProductRepository>(), context.read<LocalStorage>());
        if (initialQuery != null) cubit.submit(initialQuery!);
        return cubit;
      },
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({this.initialQuery});
  final String? initialQuery;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _useQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    setState(() {});
    _focus.unfocus();
    context.read<SearchCubit>().submit(q);
  }

  void _clear() {
    _controller.clear();
    context.read<SearchCubit>().onQueryChanged('');
    _focus.requestFocus();
  }

  Future<void> _openFilters(SearchState state) async {
    final result = await showFilterSheet(
      context,
      current: state.filter,
      floor: state.priceFloor,
      ceil: state.priceCeil,
    );
    if (result != null && mounted) context.read<SearchCubit>().applyFilter(result);
  }

  void _openProduct(Product p) => Navigator.push(context, ProductDetailsScreen.route(p, heroPrefix: 'search'));
  void _addToCart(Product p) => addToCart(context, p);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildSearchField(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, SearchState state) {
    final scheme = Theme.of(context).colorScheme;
    final hasResults = state.status == SearchStatus.success && state.results.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) {
                    setState(() {}); // refresh clear button
                    context.read<SearchCubit>().onQueryChanged(v);
                  },
                  onSubmitted: context.read<SearchCubit>().submit,
                  decoration: InputDecoration(
                    hintText: context.tr('Search products, brands...'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(onPressed: _clear, icon: const Icon(Icons.close_rounded, size: 20)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: scheme.primary, width: 1.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: hasResults
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _FilterButton(
                      count: state.filter.activeCount,
                      onTap: () => _openFilters(state),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    switch (state.status) {
      case SearchStatus.idle:
        return _IdleView(
          recent: state.recent,
          onTap: _useQuery,
          onRemove: context.read<SearchCubit>().removeRecent,
          onClear: context.read<SearchCubit>().clearRecent,
        );
      case SearchStatus.loading:
        return const CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [SliverToBoxAdapter(child: SizedBox(height: 8)), SliverProductGridSkeleton()],
        );
      case SearchStatus.failure:
        return ErrorView(message: state.error ?? 'Search failed', onRetry: context.read<SearchCubit>().retry);
      case SearchStatus.success:
        final items = state.visible;
        if (state.results.isEmpty) {
          return EmptyView(
            icon: Icons.search_off_rounded,
            title: context.tr('No results for "{q}"', {'q': state.query}),
            subtitle: 'Try a different keyword or check the spelling.',
          );
        }
        final theme = Theme.of(context);
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(text: context.tr('{n} results found', {'n': items.length})),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (state.filter.isActive)
                      TextButton.icon(
                        onPressed: () => context.read<SearchCubit>().applyFilter(const SearchFilter()),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Tr('Clear filters'),
                      ),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  icon: Icons.filter_alt_off_rounded,
                  title: 'No matches',
                  subtitle: 'No products match these filters.',
                ),
              )
            else
              SliverProductGrid(
                products: items,
                heroPrefix: 'search',
                onTap: _openProduct,
                onAddToCart: _addToCart,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
    }
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.accent,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.recent, required this.onTap, required this.onRemove, required this.onClear});

  final List<String> recent;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Tr('Recent searches', style: theme.textTheme.titleMedium)),
              TextButton(onPressed: onClear, child: const Tr('Clear all')),
            ],
          ),
          const SizedBox(height: 4),
          ...recent.map(
            (q) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.history_rounded, color: scheme.onSurfaceVariant),
              title: Text(q, style: theme.textTheme.bodyLarge),
              trailing: IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: scheme.onSurfaceVariant),
                onPressed: () => onRemove(q),
              ),
              onTap: () => onTap(q),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Tr('Popular searches', style: theme.textTheme.titleMedium),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: SearchCubit.suggestions
              .map(
                (s) => ActionChip(
                  avatar: Icon(Icons.trending_up_rounded, size: 18, color: scheme.primary),
                  label: Text(context.tr(s)),
                  onPressed: () => onTap(s),
                  backgroundColor: scheme.surface,
                  side: BorderSide(color: scheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
