import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/l10n/l10n.dart';

/// Gradient header with curved bottom used by auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle, this.showBack = false});

  final String title;
  final String subtitle;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, top + 16, 24, 64),
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(right: -60, top: -50, child: _blob(180, 0.10)),
            Positioned(left: -40, bottom: -70, child: _blob(140, 0.07)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 44,
                  child: showBack
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          alignment: AlignmentDirectional.centerStart,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                const AppLogo(size: 64, onGradient: true),
                const SizedBox(height: 22),
                Text(
                  context.tr(title),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(subtitle),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.55, size.height - 22)
      ..quadraticBezierTo(size.width * 0.82, size.height - 42, size.width, size.height - 14)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
