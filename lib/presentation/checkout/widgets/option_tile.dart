import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';

/// Selectable radio-style card used for delivery & payment options.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? scheme.primary.withValues(alpha: 0.06) : scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? scheme.primary : scheme.outline, width: selected ? 1.8 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (selected ? scheme.primary : scheme.onSurfaceVariant).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? scheme.primary : scheme.onSurfaceVariant, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(title), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(context.tr(subtitle), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) ...[
              Text(context.tr(trailing!), style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
              const SizedBox(width: 10),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? scheme.primary : scheme.outline, width: selected ? 6.5 : 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
