import 'package:equatable/equatable.dart';

import '../../data/models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final String? promoCode;
  final double promoPercent;

  const CartState({this.items = const [], this.promoCode, this.promoPercent = 0});

  static const double freeShippingThreshold = 100;
  static const double shippingFee = 9.99;

  int get count => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get savings => items.fold(0, (sum, i) => sum + i.savings);
  double get promoDiscount => subtotal * promoPercent / 100;
  double get shipping => isEmpty || subtotal >= freeShippingThreshold ? 0 : shippingFee;
  double get total => subtotal - promoDiscount + shipping;

  /// 0..1 progress toward free shipping.
  double get freeShippingProgress => (subtotal / freeShippingThreshold).clamp(0, 1).toDouble();
  double get amountToFreeShipping => (freeShippingThreshold - subtotal).clamp(0, freeShippingThreshold).toDouble();

  int quantityOf(int productId) =>
      items.where((i) => i.product.id == productId).fold(0, (s, i) => s + i.quantity);

  CartState copyWith({List<CartItem>? items, String? Function()? promoCode, double? promoPercent}) => CartState(
        items: items ?? this.items,
        promoCode: promoCode != null ? promoCode() : this.promoCode,
        promoPercent: promoPercent ?? this.promoPercent,
      );

  @override
  List<Object?> get props => [items, promoCode, promoPercent];
}
