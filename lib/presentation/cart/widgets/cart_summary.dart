import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snack.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/cart/cart_cubit.dart';
import '../../../logic/cart/cart_state.dart';
import '../../../core/l10n/l10n.dart';

/// Progress bar toward free shipping.
class FreeShippingBanner extends StatelessWidget {
  const FreeShippingBanner({super.key, required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = state.amountToFreeShipping == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (unlocked ? AppColors.success : theme.colorScheme.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked ? Icons.celebration_rounded : Icons.local_shipping_outlined,
                color: unlocked ? AppColors.success : theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: unlocked
                        ? context.tr('You unlocked FREE shipping!')
                        : context.tr('Add {amount} more for free shipping',
                            {'amount': state.amountToFreeShipping.asPrice}),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: state.freeShippingProgress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: theme.colorScheme.outline,
                valueColor: AlwaysStoppedAnimation(unlocked ? AppColors.success : theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PromoCodeField extends StatefulWidget {
  const PromoCodeField({super.key, required this.state});
  final CartState state;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    FocusScope.of(context).unfocus();
    final ok = context.read<CartCubit>().applyPromo(_controller.text);
    if (ok) {
      _controller.clear();
      showAppSnack(context, 'Promo code applied!', icon: Icons.local_offer_rounded);
    } else {
      showAppSnack(context, 'Invalid code. Try SHOP10', icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final code = widget.state.promoCode;

    if (code != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('{code}  •  {percent}% off', {'code': code, 'percent': widget.state.promoPercent.round()}),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ),
            GestureDetector(
              onTap: context.read<CartCubit>().removePromo,
              child: Icon(Icons.close_rounded, size: 20, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.characters,
      onSubmitted: (_) => _apply(),
      decoration: InputDecoration(
        hintText: context.tr('Promo code'),
        prefixIcon: const Icon(Icons.confirmation_number_outlined),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: TextButton(
            onPressed: _apply,
            style: TextButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Tr('Apply'),
          ),
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget row(String label, String value, {Color? color, bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(label),
                  style: bold
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              Text(
                value,
                style: (bold ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium)?.copyWith(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          row(context.tr('Subtotal ({n} items)', {'n': state.count}), state.subtotal.asPrice),
          if (state.savings > 0.01) row('You save', '-${state.savings.asPrice}', color: AppColors.success),
          if (state.promoDiscount > 0)
            row(context.tr('Promo ({code})', {'code': state.promoCode}), '-${state.promoDiscount.asPrice}', color: AppColors.success),
          row('Shipping', state.shipping == 0 ? 'FREE' : state.shipping.asPrice,
              color: state.shipping == 0 ? AppColors.success : null),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: scheme.outline),
          ),
          row('Total', state.total.asPrice, bold: true),
        ],
      ),
    );
  }
}
