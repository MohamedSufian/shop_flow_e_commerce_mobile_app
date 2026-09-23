import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../data/models/order.dart';
import '../../data/repositories/user_data_repository.dart';

/// Order history (newest first) per user — cached locally, stored in Firestore
/// under users/{uid}/orders.
class OrdersCubit extends Cubit<List<Order>> {
  OrdersCubit(this._storage, this._cloud) : super(const []);

  final LocalStorage _storage;
  final UserDataRepository _cloud;
  String? _uid;

  String get _key => 'orders_${_uid ?? 'guest'}';

  static List<Order> _parse(Iterable<Map<String, dynamic>> raw) {
    final list = <Order>[];
    for (final j in raw) {
      try {
        list.add(Order.fromJson(j));
      } catch (_) {}
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> loadFor(String? uid) async {
    _uid = uid;
    // 1. Local cache — instant.
    final raw = _storage.getString(_key);
    final local = raw == null
        ? <Order>[]
        : _parse((jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)));
    emit(local);
    if (uid == null) return;

    // 2. Cloud — merge (orders are immutable, so union by id is safe).
    try {
      final remote = _parse(await _cloud.readOrders(uid));
      if (_uid != uid) return;
      final remoteIds = remote.map((o) => o.id).toSet();
      final onlyLocal = local.where((o) => !remoteIds.contains(o.id)).toList();
      for (final o in onlyLocal) {
        unawaited(_cloud.writeOrder(uid, o.toJson()).catchError((Object e) => debugPrint('order upload: $e')));
      }
      final merged = _parse([...remote, ...onlyLocal].map((o) => o.toJson()));
      _saveLocal(merged);
      emit(merged);
    } catch (e) {
      debugPrint('orders cloud read failed: $e');
    }
  }

  static String newOrderId() {
    final t = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'SF-${t.substring(t.length - 6)}';
  }

  void add(Order order) {
    final list = [order, ...state];
    emit(list);
    _saveLocal(list);
    final uid = _uid;
    if (uid != null) {
      unawaited(_cloud.writeOrder(uid, order.toJson()).catchError((Object e) => debugPrint('order upload: $e')));
    }
  }

  void _saveLocal(List<Order> list) =>
      _storage.setString(_key, jsonEncode(list.map((o) => o.toJson()).toList()));
}
