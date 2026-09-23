import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';
import '../shell/main_shell.dart';
import 'login_screen.dart';

/// Shows the store when signed in, the login screen otherwise.
/// Reacts live to sign-in / sign-out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        final Widget child = switch (state.status) {
          AuthStatus.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
          AuthStatus.authenticated => const MainShell(key: ValueKey('shell')),
          AuthStatus.unauthenticated => const LoginScreen(key: ValueKey('login')),
        };
        return AnimatedSwitcher(duration: const Duration(milliseconds: 400), child: child);
      },
    );
  }
}
