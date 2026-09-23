import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/product.dart';
import '../../../core/l10n/l10n.dart';

/// "Flash deals" row with a live countdown to midnight.
class DealsList extends StatelessWidget {
  const DealsList({super.key, required this.products, this.onTap, this.onAddToCart});

  final List<Product> products;
  final ValueChanged<Product>? onTap;
  final ValueChanged<Product>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Flash Deals',
          leading: Icon(Icons.bolt_rounded, color: AppColors.accent),
          action: null,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Align(alignment: AlignmentDirectional.centerStart, child: _Countdown()),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 262,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final p = products[i];
              return ProductCard(
                product: p,
                width: 170,
                heroPrefix: 'deal',
                onTap: () => onTap?.call(p),
                onAddToCart: () => onAddToCart?.call(p),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown();

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Timer _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    setState(() => _left = midnight.difference(now));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String two(int n) => n.toString().padLeft(2, '0');
    final parts = [
      two(_left.inHours),
      two(_left.inMinutes % 60),
      two(_left.inSeconds % 60),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tr('Ends in', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(width: 8),
        for (var i = 0; i < parts.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              parts[i],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (i < parts.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Tr(':', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent)),
            ),
        ],
      ],
    );
  }
}
