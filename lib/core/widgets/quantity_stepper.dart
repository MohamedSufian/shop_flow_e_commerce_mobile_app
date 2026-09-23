import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 30.0 : 40.0;

    Widget btn(IconData icon, bool enabled, VoidCallback onTap) => Material(
          color: enabled ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 10 : 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                size: compact ? 16 : 20,
                color: enabled ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(compact ? 13 : 18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, value > min, () => onChanged(value - 1)),
          SizedBox(
            width: compact ? 28 : 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: compact ? 14 : 16),
              ),
            ),
          ),
          btn(Icons.add_rounded, value < max, () => onChanged(value + 1)),
        ],
      ),
    );
  }
}
