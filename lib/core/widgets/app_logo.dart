import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Brand mark: rounded gradient tile with a bag glyph.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88, this.onGradient = false});

  final double size;

  /// When shown on top of the brand gradient, render as a white glass tile.
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onGradient ? null : AppColors.primaryGradient,
        color: onGradient ? Colors.white.withValues(alpha: 0.16) : null,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: onGradient ? Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5) : null,
        boxShadow: onGradient
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: size * 0.5),
          Positioned(
            right: size * 0.2,
            top: size * 0.2,
            child: Container(
              width: size * 0.14,
              height: size * 0.14,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
