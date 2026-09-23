import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_view.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/order.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/orders/orders_cubit.dart';
import '../orders/order_details_screen.dart';
import '../../core/l10n/l10n.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const NotificationsScreen());

  void _open(BuildContext context, AppNotification n) {
    context.read<NotificationsCubit>().markRead(n.id);
    if (n.orderId == null) return;
    final matches = context.read<OrdersCubit>().state.where((o) => o.id == n.orderId);
    if (matches.isNotEmpty) Navigator.push(context, OrderDetailsScreen.route(matches.first));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final items = state.items;

        final now = DateTime.now();
        bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;
        final today = items.where((n) => isToday(n.createdAt)).toList();
        final earlier = items.where((n) => !isToday(n.createdAt)).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Tr('Notifications'),
            actions: [
              if (state.unread > 0)
                IconButton(
                  tooltip: context.tr('Mark all as read'),
                  onPressed: cubit.markAllRead,
                  icon: const Icon(Icons.done_all_rounded),
                ),
              if (items.isNotEmpty)
                IconButton(
                  tooltip: context.tr('Clear all'),
                  onPressed: cubit.clear,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: items.isEmpty
              ? const EmptyView(
                  icon: Icons.notifications_none_rounded,
                  title: 'All caught up',
                  subtitle: 'Order updates and offers\nwill appear here.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    if (today.isNotEmpty) ...[
                      const _GroupTitle('Today'),
                      for (final n in today) _NotificationTile(n: n, onTap: () => _open(context, n)),
                    ],
                    if (earlier.isNotEmpty) ...[
                      const _GroupTitle('Earlier'),
                      for (final n in earlier) _NotificationTile(n: n, onTap: () => _open(context, n)),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10, left: 4),
      child: Text(context.tr(text), style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  (IconData, Color) get _style => switch (n.type) {
        NotificationType.order => (Icons.local_shipping_rounded, AppColors.primary),
        NotificationType.promo => (Icons.local_offer_rounded, AppColors.accent),
        NotificationType.system => (Icons.info_rounded, const Color(0xFF0EA5E9)),
      };

  String _ago(BuildContext context, DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return context.tr('Just now');
    if (diff.inMinutes < 60) return context.tr('{n}m ago', {'n': diff.inMinutes});
    if (diff.inHours < 24) return context.tr('{n}h ago', {'n': diff.inHours});
    return d.short;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, color) = _style;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(n.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => context.read<NotificationsCubit>().delete(n.id),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        child: Material(
          color: n.read ? scheme.surface : scheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: n.read ? scheme.outline : scheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(_ago(context, n.createdAt), style: theme.textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n.body, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
                      ],
                    ),
                  ),
                  if (!n.read)
                    Container(
                      margin: const EdgeInsets.only(left: 8, top: 4),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper used by the shell when a system notification is tapped.
void openNotificationPayload(BuildContext context, String payload) {
  if (payload.startsWith('order:')) {
    final id = payload.substring(6);
    final List<Order> orders = context.read<OrdersCubit>().state;
    final match = orders.where((o) => o.id == id);
    if (match.isNotEmpty) {
      Navigator.push(context, OrderDetailsScreen.route(match.first));
      return;
    }
  }
  Navigator.push(context, NotificationsScreen.route());
}
