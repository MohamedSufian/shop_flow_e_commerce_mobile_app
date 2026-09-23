import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../core/l10n/l10n.dart';

/// Shipping / warranty / returns quick facts.
class InfoTiles extends StatelessWidget {
  const InfoTiles({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.local_shipping_rounded, 'Shipping', product.shippingInformation, const Color(0xFF0EA5E9)),
      (Icons.verified_user_rounded, 'Warranty', product.warrantyInformation, const Color(0xFF22C55E)),
      (Icons.assignment_return_rounded, 'Returns', product.returnPolicy, const Color(0xFFFF7A59)),
    ].where((e) => e.$3.isNotEmpty).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _Tile(icon: items[i].$1, title: items[i].$2, value: items[i].$3, color: items[i].$4)),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.value, required this.color});

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(context.tr(title), style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
