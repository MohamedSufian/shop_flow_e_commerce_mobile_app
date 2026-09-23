import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_network_image.dart';
import '../../data/models/order.dart';
import '../../logic/cart/cart_cubit.dart';
import '../address/address_card.dart';
import '../product_details/product_details_screen.dart';
import 'order_status_chip.dart';
import '../../core/l10n/l10n.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  static Route<void> route(Order order) => MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order));

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Demo status advances with time — refresh the timeline periodically.
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _buyAgain() {
    final cart = context.read<CartCubit>();
    for (final item in widget.order.items) {
      cart.add(item.product, quantity: item.quantity);
    }
    showAppSnack(context, 'Items added to your cart', icon: Icons.shopping_bag_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final o = widget.order;
    final status = o.status;

    Widget card({required Widget child}) => Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outline),
          ),
          child: child,
        );

    Widget title(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 24),
          child: Text(context.tr(t), style: theme.textTheme.titleMedium),
        );

    return Scaffold(
      appBar: AppBar(title: Text(o.id)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Status hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [orderStatusColor(status), Color.lerp(orderStatusColor(status), Colors.black, 0.3)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(orderStatusIcon(status), color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(status.label), style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        status == OrderStatus.delivered
                            ? context.tr('Your order has been delivered')
                            : context.tr('Estimated delivery: {eta}', {'eta': context.tr(o.delivery.eta)}),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          title('Tracking'),
          card(child: _Timeline(order: o, current: status)),

          title(context.tr('Items ({n})', {'n': o.itemCount})),
          card(
            child: Column(
              children: [
                for (final item in o.items)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      ProductDetailsScreen.route(item.product, heroPrefix: 'order-${o.id}'),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Hero(
                              tag: 'order-${o.id}-${item.product.id}',
                              child: AppNetworkImage(item.product.thumbnail, padding: const EdgeInsets.all(5)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(context.tr('Qty {n}', {'n': item.quantity}), style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Text(item.total.asPrice, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          title('Delivery address'),
          AddressCard(address: o.address),

          title('Payment'),
          card(
            child: Column(
              children: [
                _kv(
                  context,
                  'Method',
                  o.cardLast4 != null
                      ? '${context.tr(o.payment.label)} •••• ${o.cardLast4}'
                      : context.tr(o.payment.label),
                ),
                _kv(context, 'Delivery', '${context.tr(o.delivery.label)} (${context.tr(o.delivery.eta)})'),
                _kv(context, 'Placed on', o.createdAt.withTime),
                const Divider(height: 24),
                _kv(context, 'Subtotal', o.subtotal.asPrice),
                if (o.discount > 0) _kv(context, 'Discount', '-${o.discount.asPrice}', color: AppColors.success),
                _kv(context, 'Shipping', o.shipping == 0 ? 'FREE' : o.shipping.asPrice),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Tr('Total', style: theme.textTheme.titleMedium)),
                    Text(
                      o.total.asPrice,
                      style: theme.textTheme.titleLarge?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _buyAgain,
            icon: const Icon(Icons.replay_rounded),
            label: const Tr('Buy again'),
          ),
          const SizedBox(height: 8),
          Center(
            child: Tr(
              'Demo tracking: status updates automatically over ~10 minutes',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(context.tr(k), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order, required this.current});
  final Order order;
  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const steps = OrderStatus.values;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= current.index ? orderStatusColor(steps[i]) : scheme.surfaceContainerHighest,
                        ),
                        child: Icon(
                          i < current.index ? Icons.check_rounded : orderStatusIcon(steps[i]),
                          size: 17,
                          color: i <= current.index ? Colors.white : scheme.onSurfaceVariant,
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2.5,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: i < current.index ? orderStatusColor(steps[i]) : scheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: i < steps.length - 1 ? 22 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(steps[i].label),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: i <= current.index ? scheme.onSurface : scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          i <= current.index ? order.reachedAt(steps[i]).withTime : context.tr('Pending'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
