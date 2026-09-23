import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;
  double get savings => (product.originalPrice - product.price) * quantity;

  CartItem copyWith({int? quantity}) => CartItem(product: product, quantity: quantity ?? this.quantity);

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'quantity': quantity};

  @override
  List<Object?> get props => [product.id, quantity];
}
