import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_user.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/notifications/notifications_cubit.dart';
import '../../../logic/theme/theme_cubit.dart';
import '../../notifications/notifications_screen.dart';
import '../../../core/l10n/l10n.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.select<AuthCubit, AppUser?>((c) => c.state.user);
    final userName = user?.name ?? context.tr('Guest');
    final initials = user?.initials ?? '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(_greeting),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 19),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _CircleAction(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
            onTap: () => context.read<ThemeCubit>().toggle(theme.brightness),
          ),
          const SizedBox(width: 10),
          BlocSelector<NotificationsCubit, NotificationsState, int>(
            selector: (s) => s.unread,
            builder: (context, unread) => _CircleAction(
              icon: unread > 0 ? Icons.notifications_active_outlined : Icons.notifications_none_rounded,
              showDot: unread > 0,
              onTap: () => Navigator.push(context, NotificationsScreen.route()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap, this.showDot = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => RotationTransition(turns: a, child: c),
                child: Icon(icon, key: ValueKey(icon), size: 23, color: scheme.onSurface),
              ),
              if (showDot)
                Positioned(
                  top: 12,
                  right: 13,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
