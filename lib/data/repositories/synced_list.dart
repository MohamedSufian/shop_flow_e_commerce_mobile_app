import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/local_storage.dart';
import 'user_data_repository.dart';

/// Local-first persistence for a per-user JSON list, mirrored to Firestore.
///
/// * Reads come from the device first (instant, works offline), then the
///   cloud copy replaces them when it arrives.
/// * Writes go to the device immediately and to the cloud in the background.
/// * If the cloud has never stored this list, local data is uploaded.
class SyncedList {
  SyncedList({required this.name, required this.storage, required this.cloud});

  final String name;
  final LocalStorage storage;
  final UserDataRepository cloud;

  String? _uid;
  String? get uid => _uid;

  String get _localKey => '${name}_${_uid ?? 'guest'}';

  List<Map<String, dynamic>> switchUser(String? uid) {
    _uid = uid;
    return readLocal();
  }

  List<Map<String, dynamic>> readLocal() {
    final raw = storage.getString(_localKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetches the cloud copy. Returns null if unavailable or never stored
  /// (in which case the current local list is uploaded).
  Future<List<Map<String, dynamic>>?> pull() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final remote = await cloud.readList(uid, name);
      if (uid != _uid) return null; // user switched meanwhile
      if (remote == null) {
        final local = readLocal();
        if (local.isNotEmpty) _upload(uid, local);
        return null;
      }
      storage.setString(_localKey, jsonEncode(remote));
      return remote;
    } catch (e) {
      debugPrint('[$name] cloud read failed: $e');
      return null;
    }
  }

  void save(List<Map<String, dynamic>> list) {
    storage.setString(_localKey, jsonEncode(list));
    final uid = _uid;
    if (uid != null) _upload(uid, list);
  }

  void _upload(String uid, List<Map<String, dynamic>> list) {
    unawaited(
      cloud.writeList(uid, name, list).catchError((Object e) => debugPrint('[$name] cloud write failed: $e')),
    );
  }
}
