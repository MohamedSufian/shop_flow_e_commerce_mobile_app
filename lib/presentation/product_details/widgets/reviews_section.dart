import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/review.dart';
import '../../../core/l10n/l10n.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.reviews, required this.rating});

  final List<Review> reviews;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final counts = List.generate(5, (i) => reviews.where((r) => r.rating == 5 - i).length);
    final total = reviews.isEmpty ? 1 : reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(rating.toStringAsFixed(1), style: theme.textTheme.headlineLarge?.copyWith(fontSize: 40)),
                  StarRow(rating: rating, size: 16),
                  const SizedBox(height: 6),
                  Text(context.tr('{n} reviews', {'n': reviews.length}), style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text('${5 - i}', style: theme.textTheme.labelMedium),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: counts[i] / total,
                                minHeight: 7,
                                backgroundColor: scheme.surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation(AppColors.star),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...reviews.map((r) => _ReviewCard(review: r)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  static const _avatarColors = [
    Color(0xFF5B4BF5),
    Color(0xFFFF7A59),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _avatarColors[review.reviewerName.hashCode.abs() % _avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  review.reviewerName.isEmpty ? '?' : review.reviewerName[0].toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (review.date != null) Text(review.date!.short, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              StarRow(rating: review.rating.toDouble(), size: 15),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 18});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = rating >= i + 1
            ? Icons.star_rounded
            : rating > i + 0.25
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: AppColors.star);
      }),
    );
  }
}
