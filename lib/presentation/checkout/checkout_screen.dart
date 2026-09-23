import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/input_formatters.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/address.dart';
import '../../data/models/order.dart';
import '../../logic/address/address_cubit.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/cart/cart_state.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/orders/orders_cubit.dart';
import '../address/address_card.dart';
import '../address/address_form_screen.dart';
import '../address/addresses_screen.dart';
import 'order_success_screen.dart';
import 'widgets/option_tile.dart';
import 'widgets/payment_card_preview.dart';
import '../../core/l10n/l10n.dart';

/// Demo checkout — no real payment is processed.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const CheckoutScreen());

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cardForm = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _cardHolder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  Address? _address;
  DeliveryOption _delivery = DeliveryOption.standard;
  PaymentMethod _payment = PaymentMethod.card;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _address = context.read<AddressCubit>().defaultAddress;
    for (final c in [_cardNumber, _cardHolder, _expiry]) {
      c.addListener(() => setState(() {})); // live card preview
    }
  }

  @override
  void dispose() {
    for (final c in [_cardNumber, _cardHolder, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _chooseAddress() async {
    final hasAny = context.read<AddressCubit>().state.isNotEmpty;
    final picked = hasAny
        ? await AddressesScreen.pick(context, selectedId: _address?.id)
        : await AddressFormScreen.open(context);
    if (picked != null) setState(() => _address = picked);
  }

  Future<void> _placeOrder(CartState cart) async {
    if (_address == null) {
      showAppSnack(context, 'Please add a delivery address', icon: Icons.location_off_outlined);
      return;
    }
    if (_payment == PaymentMethod.card && !(_cardForm.currentState?.validate() ?? false)) {
      showAppSnack(context, 'Please check your card details', icon: Icons.credit_card_off_outlined);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _placing = true);

    await Future.delayed(const Duration(milliseconds: 1800)); // simulate payment processing
    if (!mounted) return;

    final shipping = cart.shipping + _delivery.extraFee;
    final digits = _cardNumber.text.replaceAll(' ', '');
    final order = Order(
      id: OrdersCubit.newOrderId(),
      items: cart.items,
      address: _address!,
      payment: _payment,
      delivery: _delivery,
      cardLast4: _payment == PaymentMethod.card && digits.length >= 4 ? digits.substring(digits.length - 4) : null,
      subtotal: cart.subtotal,
      discount: cart.promoDiscount,
      shipping: shipping,
      total: cart.subtotal - cart.promoDiscount + shipping,
      createdAt: DateTime.now(),
    );

    context.read<OrdersCubit>().add(order);
    context.read<NotificationsCubit>().orderPlaced(order);
    context.read<CartCubit>().clear();
    Navigator.of(context).pushReplacement(OrderSuccessScreen.route(order));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final shipping = cart.shipping + _delivery.extraFee;
    final total = cart.subtotal - cart.promoDiscount + shipping;

    // Keep the selected address in sync if it was edited or deleted.
    final addresses = context.watch<AddressCubit>().state;
    if (_address != null) {
      final match = addresses.where((a) => a.id == _address!.id);
      _address = match.isNotEmpty ? match.first : context.read<AddressCubit>().defaultAddress;
    } else if (addresses.isNotEmpty) {
      _address = context.read<AddressCubit>().defaultAddress;
    }

    return Scaffold(
      appBar: AppBar(title: const Tr('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const _StepHeader(),
          const SizedBox(height: 24),

          // ---------- Address ----------
          _SectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Delivery address',
            action: _address == null ? null : 'Change',
            onAction: _chooseAddress,
          ),
          if (_address == null)
            _AddAddressButton(onTap: _chooseAddress)
          else
            AddressCard(address: _address!, onTap: _chooseAddress, trailing: const Icon(Icons.chevron_right_rounded)),
          const SizedBox(height: 26),

          // ---------- Delivery ----------
          const _SectionTitle(icon: Icons.local_shipping_outlined, title: 'Delivery method'),
          for (final d in DeliveryOption.values) ...[
            OptionTile(
              icon: d == DeliveryOption.standard ? Icons.inventory_2_outlined : Icons.bolt_rounded,
              title: d.label,
              subtitle: d.eta,
              trailing: d.extraFee == 0 ? (cart.shipping == 0 ? 'Free' : cart.shipping.asPrice) : '+${d.extraFee.asPrice}',
              selected: _delivery == d,
              onTap: () => setState(() => _delivery = d),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 16),

          // ---------- Payment ----------
          const _SectionTitle(icon: Icons.account_balance_wallet_outlined, title: 'Payment method'),
          OptionTile(
            icon: Icons.credit_card_rounded,
            title: PaymentMethod.card.label,
            subtitle: 'Visa, Mastercard',
            selected: _payment == PaymentMethod.card,
            onTap: () => setState(() => _payment = PaymentMethod.card),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _payment == PaymentMethod.card ? _buildCardForm() : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 10),
          OptionTile(
            icon: Icons.phone_iphone_rounded,
            title: PaymentMethod.wallet.label,
            subtitle: 'Pay with one tap',
            selected: _payment == PaymentMethod.wallet,
            onTap: () => setState(() => _payment = PaymentMethod.wallet),
          ),
          const SizedBox(height: 10),
          OptionTile(
            icon: Icons.payments_outlined,
            title: PaymentMethod.cash.label,
            subtitle: 'Pay when your order arrives',
            selected: _payment == PaymentMethod.cash,
            onTap: () => setState(() => _payment = PaymentMethod.cash),
          ),
          const SizedBox(height: 26),

          // ---------- Summary ----------
          _SectionTitle(icon: Icons.receipt_long_outlined, title: context.tr('Order summary ({n} items)', {'n': cart.count})),
          _ItemsPreview(cart: cart),
          const SizedBox(height: 14),
          _Totals(
            subtotal: cart.subtotal,
            discount: cart.promoDiscount,
            promo: cart.promoCode,
            shipping: shipping,
            total: total,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Tr('Demo checkout — no real payment is made', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: GradientButton(
            label: context.tr('Place order  •  {total}', {'total': total.asPrice}),
            loading: _placing,
            onPressed: cart.isEmpty ? null : () => _placeOrder(cart),
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Form(
        key: _cardForm,
        child: Column(
          children: [
            PaymentCardPreview(number: _cardNumber.text, holder: _cardHolder.text, expiry: _expiry.text),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Card number',
              hint: '4242 4242 4242 4242',
              icon: Icons.credit_card_rounded,
              controller: _cardNumber,
              keyboardType: TextInputType.number,
              inputFormatters: [CardNumberFormatter()],
              validator: (v) => (v ?? '').replaceAll(' ', '').length != 16 ? 'Enter 16 digits' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Card holder',
              hint: 'Name on card',
              icon: Icons.person_outline_rounded,
              controller: _cardHolder,
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v ?? '').trim().length < 3 ? 'Enter the card holder name' : null,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Expiry',
                    hint: 'MM/YY',
                    icon: Icons.event_outlined,
                    controller: _expiry,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ExpiryFormatter()],
                    validator: _validateExpiry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'CVV',
                    hint: '123',
                    icon: Icons.password_rounded,
                    controller: _cvv,
                    isPassword: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (v) => (v ?? '').length < 3 ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _validateExpiry(String? v) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v ?? '');
    if (m == null) return 'MM/YY';
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return 'Invalid month';
    final now = DateTime.now();
    if (DateTime(year, month + 1).isBefore(DateTime(now.year, now.month + 1))) return 'Card expired';
    return null;
  }
}

// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget step(IconData icon, String label, bool active) => Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: active ? AppColors.primaryGradient : null,
                color: active ? null : scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: active ? Colors.white : scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(context.tr(label), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          ],
        );
    Widget line(bool active) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
            color: active ? scheme.primary : scheme.outline,
          ),
        );

    return Row(
      children: [
        step(Icons.shopping_bag_outlined, 'Cart', true),
        line(true),
        step(Icons.payment_rounded, 'Checkout', true),
        line(false),
        step(Icons.check_rounded, 'Done', false),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.action, this.onAction});

  final IconData icon;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(context.tr(title), style: theme.textTheme.titleMedium)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(context.tr(action!), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            ),
        ],
      ),
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_alt_outlined, color: scheme.primary),
            const SizedBox(width: 10),
            Tr('Add delivery address', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ItemsPreview extends StatelessWidget {
  const _ItemsPreview({required this.cart});
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppNetworkImage(item.product.thumbnail, padding: const EdgeInsets.all(4)),
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
                        Text(
                          context.tr('Qty {n}  ×  {price}', {'n': item.quantity, 'price': item.product.price.asPrice}),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(item.total.asPrice, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({
    required this.subtotal,
    required this.discount,
    required this.promo,
    required this.shipping,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final String? promo;
  final double shipping;
  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget row(String l, String v, {Color? color, bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.tr(l),
                  style: bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              Text(
                v,
                style: (bold ? theme.textTheme.titleLarge : theme.textTheme.bodyMedium)?.copyWith(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: color ?? (bold ? scheme.primary : null),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          row('Subtotal', subtotal.asPrice),
          if (discount > 0) row(context.tr('Promo ({code})', {'code': promo}), '-${discount.asPrice}', color: AppColors.success),
          row('Shipping', shipping == 0 ? 'FREE' : shipping.asPrice, color: shipping == 0 ? AppColors.success : null),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          row('Total', total.asPrice, bold: true),
        ],
      ),
    );
  }
}
