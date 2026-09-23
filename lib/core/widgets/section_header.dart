import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.leading});

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(child: Text(context.tr(title), style: theme.textTheme.titleLarge?.copyWith(fontSize: 18))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                context.tr(action!),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
