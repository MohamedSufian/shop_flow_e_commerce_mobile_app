import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/empty_view.dart';
import '../../data/models/order.dart';
import '../../logic/orders/orders_cubit.dart';
import 'order_details_screen.dart';
import 'order_status_chip.dart';
import '../../core/l10n/l10n.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const OrdersScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Tr('My orders')),
      body: BlocBuilder<OrdersCubit, List<Order>>(
        builder: (context, orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Your orders will show up here\nafter you check out.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final thumbs = order.items.take(4).toList();

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, OrderDetailsScreen.route(order)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(order.createdAt.withTime, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final item in thumbs)
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppNetworkImage(item.product.thumbnail, padding: const EdgeInsets.all(4)),
                    ),
                  if (order.items.length > thumbs.length)
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${order.items.length - thumbs.length}',
                        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(context.tr('{n} items', {'n': order.itemCount}), style: theme.textTheme.bodySmall),
                      Text(
                        order.total.asPrice,
                        style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
