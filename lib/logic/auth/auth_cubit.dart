import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  const AuthState._(this.status, this.user);
  const AuthState.unknown() : this._(AuthStatus.unknown, null);
  const AuthState.authenticated(AppUser user) : this._(AuthStatus.authenticated, user);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  @override
  List<Object?> get props => [status, user];
}

/// App-wide session. Listens to Firebase and exposes auth actions.
/// Actions throw [AuthException] with a user-friendly message on failure.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState.unknown()) {
    _sub = _repo.userChanges.listen((user) {
      emit(user == null ? const AuthState.unauthenticated() : AuthState.authenticated(user));
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<AppUser?> _sub;

  Future<void> signIn(String email, String password) => _repo.signIn(email: email, password: password);

  Future<void> signUp(String name, String email, String password) =>
      _repo.signUp(name: name, email: email, password: password);

  Future<void> resetPassword(String email) => _repo.sendPasswordReset(email);

  Future<void> updateName(String name) => _repo.updateName(name);

  Future<void> signOut() => _repo.signOut();

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
