import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/l10n.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/order.dart';

class NotificationsState extends Equatable {
  final List<AppNotification> items;
  final bool pushEnabled;
  final bool promosEnabled;

  const NotificationsState({this.items = const [], this.pushEnabled = true, this.promosEnabled = true});

  int get unread => items.where((n) => !n.read).length;

  NotificationsState copyWith({List<AppNotification>? items, bool? pushEnabled, bool? promosEnabled}) =>
      NotificationsState(
        items: items ?? this.items,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        promosEnabled: promosEnabled ?? this.promosEnabled,
      );

  @override
  List<Object?> get props => [items, pushEnabled, promosEnabled];
}

/// In-app inbox + system notifications, stored per user.
/// Also watches orders and notifies when their (demo) status advances.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._storage, {NotificationService? service})
      : _service = service ?? NotificationService.instance,
        super(const NotificationsState());

  final LocalStorage _storage;
  final NotificationService _service;

  String? _uid;
  Timer? _tracker;
  List<Order> _orders = const [];
  Map<String, int> _seenStatus = {};

  String get _key => 'notifications_${_uid ?? 'guest'}';
  String get _seenKey => 'order_status_seen_${_uid ?? 'guest'}';
  String get _welcomeKey => 'welcomed_${_uid ?? 'guest'}';

  // ---------------------------------------------------------------- session

  void loadFor(String? uid) {
    _uid = uid;
    _tracker?.cancel();
    var items = <AppNotification>[];
    try {
      final raw = _storage.getString(_key);
      if (raw != null) {
        items = (jsonDecode(raw) as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      }
      final seen = _storage.getString(_seenKey);
      _seenStatus = seen == null ? {} : Map<String, int>.from(jsonDecode(seen) as Map);
    } catch (_) {
      _seenStatus = {};
    }
    emit(NotificationsState(
      items: items,
      pushEnabled: _storage.getString('push_enabled') != 'false',
      promosEnabled: _storage.getString('promos_enabled') != 'false',
    ));

    if (uid == null) return;
    _tracker = Timer.periodic(const Duration(seconds: 30), (_) => _checkOrders());

    if (_storage.getString(_welcomeKey) == null) {
      _storage.setString(_welcomeKey, '1');
      _push(
        type: NotificationType.promo,
        title: tr('Welcome to ShopFlow!'),
        body: tr('Enjoy 15% off your first order with code WELCOME at checkout.'),
      );
    }
  }

  // ---------------------------------------------------------------- orders

  /// Called whenever the orders list changes.
  void updateOrders(List<Order> orders) {
    _orders = orders;
    _checkOrders();
  }

  void orderPlaced(Order order) {
    _seenStatus[order.id] = OrderStatus.placed.index;
    _saveSeen();
    _push(
      type: NotificationType.order,
      title: tr('Order confirmed'),
      body: tr('Your order {id} ({total}) has been placed successfully.', {'id': order.id, 'total': order.total.asPrice}),
      orderId: order.id,
    );
  }

  void _checkOrders() {
    if (_uid == null) return;
    var changed = false;
    for (final o in _orders) {
      final current = o.status.index;
      final seen = _seenStatus[o.id];
      if (seen == null) {
        _seenStatus[o.id] = current; // first time we see it — don't spam
        changed = true;
        continue;
      }
      if (current > seen) {
        _seenStatus[o.id] = current;
        changed = true;
        final (title, body) = switch (o.status) {
          OrderStatus.processing => (tr('Order is being prepared'), tr("We're packing your order {id}.", {'id': o.id})),
          OrderStatus.shipped => (
              tr('Order shipped'),
              tr('Good news! {id} is on its way to {city}.', {'id': o.id, 'city': o.address.city}),
            ),
          OrderStatus.delivered => (tr('Order delivered'), tr('{id} has been delivered. Enjoy your purchase!', {'id': o.id})),
          OrderStatus.placed => (tr('Order placed'), o.id),
        };
        _push(type: NotificationType.order, title: title, body: body, orderId: o.id);
      }
    }
    if (changed) _saveSeen();
  }

  // ---------------------------------------------------------------- inbox

  void markRead(String id) =>
      _save(state.items.map((n) => n.id == id ? n.copyWith(read: true) : n).toList());

  void markAllRead() => _save(state.items.map((n) => n.copyWith(read: true)).toList());

  void delete(String id) => _save(state.items.where((n) => n.id != id).toList());

  void clear() => _save(const []);

  // ---------------------------------------------------------------- settings

  Future<void> setPushEnabled(bool v) async {
    if (v) await _service.requestPermission();
    _storage.setString('push_enabled', '$v');
    emit(state.copyWith(pushEnabled: v));
  }

  void setPromosEnabled(bool v) {
    _storage.setString('promos_enabled', '$v');
    emit(state.copyWith(promosEnabled: v));
  }

  // ---------------------------------------------------------------- internals

  void _push({required NotificationType type, required String title, required String body, String? orderId}) {
    if (type == NotificationType.promo && !state.promosEnabled) return;
    final n = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      orderId: orderId,
    );
    _save([n, ...state.items].take(50).toList());
    if (state.pushEnabled) {
      _service.show(
        id: n.createdAt.millisecondsSinceEpoch ~/ 1000 % 100000,
        title: title,
        body: body,
        payload: orderId != null ? 'order:$orderId' : 'inbox',
      );
    }
  }

  void _save(List<AppNotification> items) {
    emit(state.copyWith(items: items));
    _storage.setString(_key, jsonEncode(items.map((n) => n.toJson()).toList()));
  }

  void _saveSeen() => _storage.setString(_seenKey, jsonEncode(_seenStatus));

  @override
  Future<void> close() {
    _tracker?.cancel();
    return super.close();
  }
}
