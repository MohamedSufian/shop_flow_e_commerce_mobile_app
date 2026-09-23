import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Wraps FirebaseAuth and converts errors into friendly messages.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<AppUser?> get userChanges => _auth.userChanges().map(_map);

  AppUser? get currentUser => _map(_auth.currentUser);

  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  Future<void> signUp({required String name, required String email, required String password}) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await cred.user?.updateDisplayName(name.trim());
        await cred.user?.reload();
      });

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> updateName(String name) => _guard(() async {
        await _auth.currentUser?.updateDisplayName(name.trim());
        await _auth.currentUser?.reload();
      });

  Future<void> signOut() => _auth.signOut();

  AppUser? _map(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          email: u.email ?? '',
          displayName: u.displayName,
          photoUrl: u.photoURL,
          createdAt: u.metadata.creationTime,
        );

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
