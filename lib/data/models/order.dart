import 'package:equatable/equatable.dart';

import 'address.dart';
import 'cart_item.dart';

enum PaymentMethod {
  card('Credit / Debit Card'),
  wallet('Google / Apple Pay'),
  cash('Cash on Delivery');

  const PaymentMethod(this.label);
  final String label;
}

enum DeliveryOption {
  standard('Standard', '3–5 business days', 0),
  express('Express', '1–2 business days', 14.99);

  const DeliveryOption(this.label, this.eta, this.extraFee);
  final String label;
  final String eta;
  final double extraFee;
}

enum OrderStatus {
  placed('Order placed'),
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered');

  const OrderStatus(this.label);
  final String label;
}

class Order extends Equatable {
  final String id;
  final List<CartItem> items;
  final Address address;
  final PaymentMethod payment;
  final DeliveryOption delivery;
  final String? cardLast4;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.address,
    required this.payment,
    required this.delivery,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.createdAt,
    this.cardLast4,
  });

  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  /// Demo status: advances automatically with time since the order was placed.
  OrderStatus get status {
    final m = DateTime.now().difference(createdAt).inMinutes;
    if (m < 2) return OrderStatus.placed;
    if (m < 5) return OrderStatus.processing;
    if (m < 10) return OrderStatus.shipped;
    return OrderStatus.delivered;
  }

  /// Time each status is reached (for the timeline).
  DateTime reachedAt(OrderStatus s) => createdAt.add(
        Duration(minutes: const {0: 0, 1: 2, 2: 5, 3: 10}[s.index]!),
      );

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        items: (j['items'] as List).map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
        address: Address.fromJson(j['address'] as Map<String, dynamic>),
        payment: PaymentMethod.values.byName(j['payment'] as String),
        delivery: DeliveryOption.values.byName(j['delivery'] as String? ?? 'standard'),
        cardLast4: j['cardLast4'] as String?,
        subtotal: (j['subtotal'] as num).toDouble(),
        discount: (j['discount'] as num).toDouble(),
        shipping: (j['shipping'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'address': address.toJson(),
        'payment': payment.name,
        'delivery': delivery.name,
        'cardLast4': cardLast4,
        'subtotal': subtotal,
        'discount': discount,
        'shipping': shipping,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id];
}
