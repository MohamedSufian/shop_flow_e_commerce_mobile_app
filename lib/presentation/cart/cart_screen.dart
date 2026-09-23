import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_snack.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/gradient_button.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/cart/cart_state.dart';
import '../checkout/checkout_screen.dart';
import '../product_details/product_details_screen.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary.dart';
import '../../core/l10n/l10n.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onStartShopping});

  final VoidCallback? onStartShopping;

  void _remove(BuildContext context, int productId) {
    final cubit = context.read<CartCubit>();
    final removed = cubit.remove(productId);
    if (removed == null) return;
    final (item, index) = removed;
    showAppSnack(
      context,
      context.tr('{title} removed', {'title': item.product.title}),
      icon: Icons.delete_outline_rounded,
      actionLabel: 'UNDO',
      onAction: () => cubit.restore(item, index),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Tr('Empty cart?'),
        content: const Tr('All items will be removed from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Tr('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Tr('Empty')),
        ],
      ),
    );
    if (ok == true && context.mounted) context.read<CartCubit>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Tr('My Cart'),
            actions: [
              if (!state.isEmpty)
                IconButton(
                  tooltip: context.tr('Empty cart'),
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isEmpty
                ? EmptyView(
                    key: const ValueKey('empty'),
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    subtitle: 'Looks like you haven\'t added\nanything yet.',
                    action: onStartShopping == null
                        ? null
                        : SizedBox(
                            width: 200,
                            child: GradientButton(label: 'Start shopping', onPressed: onStartShopping),
                          ),
                  )
                : ListView(
                    key: const ValueKey('list'),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      FreeShippingBanner(state: state),
                      const SizedBox(height: 16),
                      for (final item in state.items) ...[
                        CartItemTile(
                          item: item,
                          onTap: () => Navigator.push(
                            context,
                            ProductDetailsScreen.route(item.product, heroPrefix: 'cart'),
                          ),
                          onQuantity: (q) => context.read<CartCubit>().setQuantity(item.product.id, q),
                          onRemove: () => _remove(context, item.product.id),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      PromoCodeField(state: state),
                      const SizedBox(height: 16),
                      OrderSummary(state: state),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: context.tr('Checkout  •  {total}', {'total': state.total.asPrice}),
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => Navigator.push(context, CheckoutScreen.route()),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
