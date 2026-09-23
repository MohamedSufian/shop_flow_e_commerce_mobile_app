import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/repositories/synced_list.dart';
import 'cart_state.dart';

/// Cart per user — stored locally and synced to Firestore.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._store) : super(const CartState());

  final SyncedList _store;

  /// Demo promo codes → percent off.
  static const promoCodes = {'SHOP10': 10.0, 'FLOW20': 20.0, 'WELCOME': 15.0};

  static List<CartItem> _parse(List<Map<String, dynamic>> raw) {
    try {
      return raw.map(CartItem.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> loadFor(String? uid) async {
    emit(CartState(items: _parse(_store.switchUser(uid))));
    final remote = await _store.pull();
    if (remote != null && _store.uid == uid) emit(state.copyWith(items: _parse(remote)));
  }

  int _maxFor(Product p) => p.stock < 1 ? 1 : p.stock;

  void add(Product product, {int quantity = 1}) {
    final items = [...state.items];
    final i = items.indexWhere((e) => e.product.id == product.id);
    if (i >= 0) {
      final q = (items[i].quantity + quantity).clamp(1, _maxFor(product));
      items[i] = items[i].copyWith(quantity: q);
    } else {
      items.insert(0, CartItem(product: product, quantity: quantity.clamp(1, _maxFor(product))));
    }
    _save(items);
  }

  void setQuantity(int productId, int quantity) {
    final items = state.items.map((e) {
      if (e.product.id != productId) return e;
      return e.copyWith(quantity: quantity.clamp(1, _maxFor(e.product)));
    }).toList();
    _save(items);
  }

  /// Removes an item and returns (item, index) so the UI can offer "Undo".
  (CartItem, int)? remove(int productId) {
    final i = state.items.indexWhere((e) => e.product.id == productId);
    if (i < 0) return null;
    final removed = state.items[i];
    _save([...state.items]..removeAt(i));
    return (removed, i);
  }

  void restore(CartItem item, int index) {
    final items = [...state.items];
    items.insert(index.clamp(0, items.length), item);
    _save(items);
  }

  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    final percent = promoCodes[c];
    if (percent == null) return false;
    emit(state.copyWith(promoCode: () => c, promoPercent: percent));
    return true;
  }

  void removePromo() => emit(state.copyWith(promoCode: () => null, promoPercent: 0));

  void clear() {
    emit(const CartState());
    _store.save(const []);
  }

  void _save(List<CartItem> items) {
    emit(state.copyWith(items: items));
    _store.save(items.map((e) => e.toJson()).toList());
  }
}
