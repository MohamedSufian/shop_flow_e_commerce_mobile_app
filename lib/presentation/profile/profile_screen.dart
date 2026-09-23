import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snack.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/address/address_cubit.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/locale/locale_cubit.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/orders/orders_cubit.dart';
import '../../logic/theme/theme_cubit.dart';
import '../address/addresses_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_screen.dart';
import '../../core/l10n/l10n.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onOpenFavorites, this.onOpenCart});

  final VoidCallback? onOpenFavorites;
  final VoidCallback? onOpenCart;

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Tr('Sign out?'),
        content: const Tr('You can sign back in anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Tr('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Tr('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) await context.read<AuthCubit>().signOut();
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const AppLogo(size: 52),
      children: const [
        Tr('A modern e-commerce demo built with Flutter, BLoC, Firebase Auth and the DummyJSON API.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select<AuthCubit, AppUser?>((c) => c.state.user);
    final isDark = theme.brightness == Brightness.dark;

    final ordersCount = context.select<OrdersCubit, int>((c) => c.state.length);
    final favCount = context.select<FavoritesCubit, int>((c) => c.state.length);
    final cartCount = context.select<CartCubit, int>((c) => c.state.count);
    final addressCount = context.select<AddressCubit, int>((c) => c.state.length);
    final notif = context.watch<NotificationsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Tr('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _AccountCard(user: user, onEdit: user == null ? null : () => _showEditName(context, user)),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                value: '$ordersCount',
                label: 'Orders',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF0EA5E9),
                onTap: () => Navigator.push(context, OrdersScreen.route()),
              ),
              const SizedBox(width: 12),
              _Stat(
                value: '$favCount',
                label: 'Favorites',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFEC4899),
                onTap: onOpenFavorites,
              ),
              const SizedBox(width: 12),
              _Stat(
                value: '$cartCount',
                label: 'In cart',
                icon: Icons.shopping_bag_rounded,
                color: AppColors.accent,
                onTap: onOpenCart,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'My account',
            children: [
              _Tile(
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF0EA5E9),
                title: 'My orders',
                subtitle: ordersCount == 0 ? 'No orders yet' : context.tr('{n} orders', {'n': ordersCount}),
                onTap: () => Navigator.push(context, OrdersScreen.route()),
              ),
              _Tile(
                icon: Icons.location_on_outlined,
                color: AppColors.success,
                title: 'Shipping addresses',
                subtitle: addressCount == 0 ? 'Add an address' : context.tr('{n} saved', {'n': addressCount}),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen())),
              ),
              _Tile(
                icon: Icons.notifications_none_rounded,
                color: const Color(0xFF8B5CF6),
                title: 'Notifications',
                subtitle: notif.unread == 0 ? 'No new notifications' : context.tr('{n} unread', {'n': notif.unread}),
                onTap: () => Navigator.push(context, NotificationsScreen.route()),
              ),
              _Tile(
                icon: Icons.person_outline_rounded,
                color: AppColors.primary,
                title: 'Edit profile',
                subtitle: 'Change your display name',
                onTap: user == null ? null : () => _showEditName(context, user),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Preferences',
            children: [
              _Tile(
                icon: Icons.translate_rounded,
                color: const Color(0xFF14B8A6),
                title: 'Language',
                trailing: _LanguageSwitch(isArabic: context.watch<LocaleCubit>().isArabic),
              ),
              _Tile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: const Color(0xFF6366F1),
                title: 'Dark mode',
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeCubit>().toggle(theme.brightness),
                ),
              ),
              _Tile(
                icon: Icons.notifications_active_outlined,
                color: AppColors.warning,
                title: 'Push notifications',
                subtitle: 'Order updates on your device',
                trailing: Switch(
                  value: notif.pushEnabled,
                  onChanged: context.read<NotificationsCubit>().setPushEnabled,
                ),
              ),
              _Tile(
                icon: Icons.local_offer_outlined,
                color: AppColors.accent,
                title: 'Offers & promotions',
                trailing: Switch(
                  value: notif.promosEnabled,
                  onChanged: context.read<NotificationsCubit>().setPromosEnabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'More',
            children: [
              _Tile(
                icon: Icons.info_outline_rounded,
                color: const Color(0xFF64748B),
                title: 'About ShopFlow',
                onTap: () => _about(context),
              ),
              _Tile(
                icon: Icons.logout_rounded,
                color: AppColors.error,
                title: 'Sign out',
                titleColor: AppColors.error,
                trailing: const SizedBox.shrink(),
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
          if (user?.createdAt != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(context.tr('Member since {date}', {'date': user!.createdAt!.short}), style: theme.textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditName(BuildContext context, AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: _EditNameSheet(initial: user.name),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, this.onEdit});
  final AppUser? user;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.initials ?? '?',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? context.tr('Guest'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.icon, required this.color, this.onTap});

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                Text(context.tr(label), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(context.tr(title), style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 72, color: theme.colorScheme.outline),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(context.tr(title), style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
      subtitle: subtitle == null ? null : Text(context.tr(subtitle!), style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}

/// Compact EN / ع segmented toggle.
class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({required this.isArabic});
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget option(String label, String code, bool selected) => GestureDetector(
          onTap: () => context.read<LocaleCubit>().setLanguage(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          option('EN', 'en', !isArabic),
          option('عربي', 'ar', isArabic),
        ],
      ),
    );
  }
}

class _EditNameSheet extends StatefulWidget {
  const _EditNameSheet({required this.initial});
  final String initial;

  @override
  State<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<_EditNameSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial);
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().updateName(_name.text);
      if (!mounted) return;
      Navigator.pop(context);
      showAppSnack(context, 'Profile updated', icon: Icons.check_circle_rounded);
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
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(color: theme.colorScheme.outline, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Tr('Edit profile', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Display name',
              hint: 'Your name',
              icon: Icons.person_outline_rounded,
              controller: _name,
              validator: Validators.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            GradientButton(label: 'Save', loading: _loading, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
