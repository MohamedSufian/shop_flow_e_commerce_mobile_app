import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../logic/search/search_filter.dart';
import '../../../core/l10n/l10n.dart';

/// Bottom sheet for sort / price / rating. Returns the new [SearchFilter] or null.
Future<SearchFilter?> showFilterSheet(
  BuildContext context, {
  required SearchFilter current,
  required double floor,
  required double ceil,
}) {
  return showModalBottomSheet<SearchFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FilterSheet(current: current, floor: floor, ceil: ceil),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.floor, required this.ceil});

  final SearchFilter current;
  final double floor;
  final double ceil;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SortOption _sort = widget.current.sort;
  late RangeValues _range = RangeValues(
    (widget.current.minPrice ?? widget.floor).clamp(widget.floor, widget.ceil),
    (widget.current.maxPrice ?? widget.ceil).clamp(widget.floor, widget.ceil),
  );
  late double _rating = widget.current.minRating;

  bool get _hasRange => widget.ceil > widget.floor;

  void _reset() => setState(() {
        _sort = SortOption.relevance;
        _range = RangeValues(widget.floor, widget.ceil);
        _rating = 0;
      });

  void _apply() {
    final priceChanged = _hasRange && (_range.start > widget.floor || _range.end < widget.ceil);
    Navigator.pop(
      context,
      SearchFilter(
        sort: _sort,
        minPrice: priceChanged ? _range.start : null,
        maxPrice: priceChanged ? _range.end : null,
        minRating: _rating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: scheme.outline, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Tr('Filter & Sort', style: theme.textTheme.titleLarge)),
              TextButton(onPressed: _reset, child: const Tr('Reset')),
            ],
          ),
          const SizedBox(height: 16),
          _label(context, 'Sort by'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SortOption.values
                .map((o) => _Pill(label: o.label, selected: _sort == o, onTap: () => setState(() => _sort = o)))
                .toList(),
          ),
          if (_hasRange) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _label(context, 'Price range')),
                Text(
                  '${_range.start.asPrice} – ${_range.end.asPrice}',
                  style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                ),
              ],
            ),
            RangeSlider(
              values: _range,
              min: widget.floor,
              max: widget.ceil,
              activeColor: scheme.primary,
              inactiveColor: scheme.outline,
              onChanged: (v) => setState(() => _range = v),
            ),
          ],
          const SizedBox(height: 16),
          _label(context, 'Rating'),
          Wrap(
            spacing: 8,
            children: [0.0, 3.0, 4.0, 4.5].map((r) {
              return _Pill(
                label: r == 0 ? 'Any' : '${r.toStringAsFixed(r % 1 == 0 ? 0 : 1)}+',
                icon: r == 0 ? null : Icons.star_rounded,
                selected: _rating == r,
                onTap: () => setState(() => _rating = r),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          GradientButton(label: 'Apply filters', onPressed: _apply),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(context.tr(text), style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : AppColors.star),
              const SizedBox(width: 4),
            ],
            Text(
              context.tr(label),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
