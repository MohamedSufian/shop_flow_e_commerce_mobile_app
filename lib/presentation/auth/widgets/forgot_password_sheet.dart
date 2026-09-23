import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snack.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../core/l10n/l10n.dart';

Future<void> showForgotPasswordSheet(BuildContext context, {String? email}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: _ForgotSheet(initialEmail: email),
    ),
  );
}

class _ForgotSheet extends StatefulWidget {
  const _ForgotSheet({this.initialEmail});
  final String? initialEmail;

  @override
  State<_ForgotSheet> createState() => _ForgotSheetState();
}

class _ForgotSheetState extends State<_ForgotSheet> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().resetPassword(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      if (mounted) showAppSnack(context, e.message, icon: Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (_sent ? AppColors.success : theme.colorScheme.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _sent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                color: _sent ? AppColors.success : theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(context.tr(_sent ? 'Check your inbox' : 'Forgot password?'), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _sent
                  ? context.tr('We sent a reset link to {email}. Follow it to set a new password.',
                      {'email': _email.text.trim()})
                  : context.tr('Enter the email linked to your account and we\'ll send you a reset link.'),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (!_sent) ...[
              Form(
                key: _form,
                child: AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  icon: Icons.alternate_email_rounded,
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(label: 'Send reset link', loading: _loading, onPressed: _send),
            ] else
              GradientButton(label: 'Back to login', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
