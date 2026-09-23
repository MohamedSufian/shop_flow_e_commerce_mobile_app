import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/auth/auth_cubit.dart';
import 'widgets/auth_header.dart';
import '../../core/l10n/l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _loading = false;
  int _strength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (!_agree) {
      showAppSnack(context, 'Please accept the terms to continue', icon: Icons.info_outline_rounded);
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().signUp(_name.text, _email.text, _password.text);
      if (!mounted) return;
      // Close this route; AuthGate underneath now shows the app.
      Navigator.of(context).popUntil((r) => r.isFirst);
      showAppSnack(context, context.tr('Welcome to ShopFlow, {name}!', {'name': _name.text.trim().split(' ').first}),
          icon: Icons.celebration_rounded);
    } on AuthException catch (e) {
      if (mounted) showAppSnack(context, e.message, icon: Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const AuthHeader(
              title: 'Create account',
              subtitle: 'Join ShopFlow and start shopping',
              showBack: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Full name',
                        hint: 'Jane Doe',
                        icon: Icons.person_outline_rounded,
                        controller: _name,
                        validator: Validators.name,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.alternate_email_rounded,
                        controller: _email,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Password',
                        hint: 'At least 6 characters',
                        icon: Icons.lock_outline_rounded,
                        controller: _password,
                        validator: Validators.password,
                        isPassword: true,
                        onChanged: (v) => setState(() => _strength = Validators.passwordStrength(v)),
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 10),
                      _StrengthMeter(score: _strength, visible: _password.text.isNotEmpty),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Confirm password',
                        hint: 'Re-enter password',
                        icon: Icons.lock_reset_rounded,
                        controller: _confirm,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: (v) => v != _password.text ? 'Passwords don\'t match' : null,
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _agree = !_agree),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agree,
                              onChanged: (v) => setState(() => _agree = v ?? false),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: context.tr('I agree to the ')),
                                  TextSpan(
                                    text: context.tr('Terms & Privacy Policy'),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ]),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Create Account',
                        icon: Icons.arrow_forward_rounded,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tr('Already have an account?', style: theme.textTheme.bodyMedium),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Tr('Sign In')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.score, required this.visible});
  final int score;
  final bool visible;

  static const _labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];
  static const _colors = [AppColors.error, AppColors.error, AppColors.warning, Color(0xFF84CC16), AppColors.success];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 5,
                decoration: BoxDecoration(
                  color: i < score ? _colors[score] : scheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 6),
          ],
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Text(
              context.tr(_labels[score]),
              textAlign: TextAlign.end,
              style: TextStyle(color: _colors[score], fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
