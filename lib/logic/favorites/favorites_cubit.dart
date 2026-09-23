import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../../data/repositories/synced_list.dart';

/// Favorites per user (newest first) — stored locally and synced to Firestore.
class FavoritesCubit extends Cubit<List<Product>> {
  FavoritesCubit(this._store) : super(const []);

  final SyncedList _store;

  static List<Product> _parse(List<Map<String, dynamic>> raw) {
    try {
      return raw.map(Product.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> loadFor(String? uid) async {
    emit(_parse(_store.switchUser(uid)));
    final remote = await _store.pull();
    if (remote != null && _store.uid == uid) emit(_parse(remote));
  }

  bool isFavorite(int id) => state.any((p) => p.id == id);

  /// Returns true if the product is now a favorite.
  bool toggle(Product product) {
    final exists = isFavorite(product.id);
    _save(exists ? state.where((p) => p.id != product.id).toList() : [product, ...state]);
    return !exists;
  }

  void clear() => _save(const []);

  void _save(List<Product> list) {
    emit(list);
    _store.save(list.map((p) => p.toJson()).toList());
  }
}
