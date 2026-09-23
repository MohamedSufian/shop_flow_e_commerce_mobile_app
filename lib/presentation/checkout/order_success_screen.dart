import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/order.dart';
import '../orders/order_details_screen.dart';
import '../../core/l10n/l10n.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  static Route<void> route(Order order) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => OrderSuccessScreen(order: order),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      );

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with TickerProviderStateMixin {
  late final _check = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final _confetti = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();

  @override
  void dispose() {
    _check.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _backToShop() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final o = widget.order;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToShop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confetti,
                  builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_confetti.value)),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    ScaleTransition(
                      scale: CurvedAnimation(parent: _check, curve: Curves.elasticOut),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.12),
                        ),
                        child: Center(
                          child: Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF4ADE80), AppColors.success]),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 54),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Tr('Order placed!', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    Tr(
                      'Thank you for shopping with ShopFlow.\nWe\'ll let you know when it\'s on its way.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: scheme.outline),
                      ),
                      child: Column(
                        children: [
                          _row(context, 'Order ID', o.id),
                          _row(context, 'Items', '${o.itemCount}'),
                          _row(context, 'Payment', context.tr(o.payment.label)),
                          _row(context, 'Delivery', '${context.tr(o.delivery.label)} (${context.tr(o.delivery.eta)})'),
                          const Divider(height: 24),
                          _row(context, 'Total paid', o.total.asPrice, bold: true),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GradientButton(
                      label: 'Track order',
                      icon: Icons.local_shipping_outlined,
                      onPressed: () => Navigator.of(context).pushReplacement(OrderDetailsScreen.route(o)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _backToShop, child: const Tr('Continue shopping')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String l, String v, {bool bold = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(context.tr(l), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (bold ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium)?.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight falling confetti.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static final _rand = Random(7);
  static final _pieces = List.generate(70, (_) => [_rand.nextDouble(), _rand.nextDouble(), _rand.nextDouble(), _rand.nextDouble()]);
  static const _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.star,
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final fade = t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25);
    for (var i = 0; i < _pieces.length; i++) {
      final p = _pieces[i];
      final x = p[0] * size.width + sin((t * 6) + i) * 18;
      final y = -20 + (p[1] * 0.4 + t * (0.9 + p[2] * 0.6)) * size.height;
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: fade.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 10 * (p[3] - 0.5));
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -7, 8, 14), const Radius.circular(2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
