import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/order.dart';
import '../../core/l10n/l10n.dart';

Color orderStatusColor(OrderStatus s) => switch (s) {
      OrderStatus.placed => const Color(0xFF0EA5E9),
      OrderStatus.processing => AppColors.warning,
      OrderStatus.shipped => AppColors.primary,
      OrderStatus.delivered => AppColors.success,
    };

IconData orderStatusIcon(OrderStatus s) => switch (s) {
      OrderStatus.placed => Icons.receipt_long_rounded,
      OrderStatus.processing => Icons.inventory_2_rounded,
      OrderStatus.shipped => Icons.local_shipping_rounded,
      OrderStatus.delivered => Icons.home_rounded,
    };

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final c = orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(orderStatusIcon(status), size: 14, color: c),
          const SizedBox(width: 5),
          Text(context.tr(status.label), style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
