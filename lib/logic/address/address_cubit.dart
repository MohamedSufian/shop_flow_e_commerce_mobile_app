import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/address.dart';
import '../../data/repositories/synced_list.dart';

/// Saved addresses per user — stored locally and synced to Firestore.
class AddressCubit extends Cubit<List<Address>> {
  AddressCubit(this._store) : super(const []);

  final SyncedList _store;

  static List<Address> _parse(List<Map<String, dynamic>> raw) {
    try {
      return raw.map(Address.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> loadFor(String? uid) async {
    emit(_parse(_store.switchUser(uid)));
    final remote = await _store.pull();
    if (remote != null && _store.uid == uid) emit(_parse(remote));
  }

  Address? get defaultAddress {
    if (state.isEmpty) return null;
    return state.firstWhere((a) => a.isDefault, orElse: () => state.first);
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  /// Adds or updates. The first address is always default.
  void save(Address address) {
    final makeDefault = address.isDefault || state.isEmpty || (state.length == 1 && state.first.id == address.id);
    var list = [...state];
    final i = list.indexWhere((a) => a.id == address.id);
    final a = address.copyWith(isDefault: makeDefault);
    if (i >= 0) {
      list[i] = a;
    } else {
      list.add(a);
    }
    if (makeDefault) {
      list = list.map((e) => e.id == a.id ? e : e.copyWith(isDefault: false)).toList();
    }
    _save(list);
  }

  void setDefault(String id) =>
      _save(state.map((a) => a.copyWith(isDefault: a.id == id)).toList());

  void delete(String id) {
    final wasDefault = state.any((a) => a.id == id && a.isDefault);
    var list = state.where((a) => a.id != id).toList();
    if (wasDefault && list.isNotEmpty) {
      list = [list.first.copyWith(isDefault: true), ...list.skip(1)];
    }
    _save(list);
  }

  void _save(List<Address> list) {
    emit(list);
    _store.save(list.map((a) => a.toJson()).toList());
  }
}
