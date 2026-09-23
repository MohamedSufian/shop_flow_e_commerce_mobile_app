import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// Cloud Firestore storage for per-user data.
///
/// Layout:
///   users/{uid}                 → profile + `cart`, `favorites`, `addresses` arrays
///   users/{uid}/orders/{orderId} → one document per order
class UserDataRepository {
  UserDataRepository({FirebaseFirestore? db}) : _dbOverride = db;

  final FirebaseFirestore? _dbOverride;
  FirebaseFirestore get _db => _dbOverride ?? FirebaseFirestore.instance;

  static const _timeout = Duration(seconds: 8);

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  Future<void> saveProfile(AppUser user) => _user(user.uid).set({
        'name': user.name,
        'email': user.email,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// Returns null when the field was never written (so local data can be uploaded).
  Future<List<Map<String, dynamic>>?> readList(String uid, String field) async {
    final snap = await _user(uid).get().timeout(_timeout);
    final value = snap.data()?[field];
    if (value is! List) return null;
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> writeList(String uid, String field, List<Map<String, dynamic>> list) => _user(uid).set(
        {field: list, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

  Future<List<Map<String, dynamic>>> readOrders(String uid) async {
    final q = await _user(uid).collection('orders').orderBy('createdAt', descending: true).get().timeout(_timeout);
    return q.docs.map((d) => d.data()).toList();
  }

  Future<void> writeOrder(String uid, Map<String, dynamic> order) =>
      _user(uid).collection('orders').doc(order['id'] as String).set(order);
}
