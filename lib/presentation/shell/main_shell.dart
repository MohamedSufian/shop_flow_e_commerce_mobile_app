import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/notification_service.dart';
import '../../data/repositories/product_repository.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/categories/categories_cubit.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/home/home_cubit.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  StreamSubscription<String>? _tapSub;

  @override
  void initState() {
    super.initState();
    final service = NotificationService.instance;
    // Ask for notification permission once the user is inside the app.
    if (context.read<NotificationsCubit>().state.pushEnabled) service.requestPermission();
    // Open the related screen when a system notification is tapped.
    _tapSub = service.taps.listen((p) {
      if (mounted) openNotificationPayload(context, p);
    });
    final launch = service.launchPayload;
    if (launch != null) {
      service.launchPayload = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openNotificationPayload(context, launch);
      });
    }
  }

  @override
  void dispose() {
    _tapSub?.cancel();
    super.dispose();
  }

  void _goTo(int i) => setState(() => _index = i);

  // Screens are replaced step by step as we build each feature.
  late final List<Widget> _pages = [
    BlocProvider(
      create: (context) => HomeCubit(context.read<ProductRepository>())..load(),
      child: HomeScreen(onSeeAllCategories: () => _goTo(1), onOpenProfile: () => _goTo(4)),
    ),
    BlocProvider(
      create: (context) => CategoriesCubit(context.read<ProductRepository>())..load(),
      child: const CategoriesScreen(),
    ),
    FavoritesScreen(onStartShopping: () => _goTo(0)),
    CartScreen(onStartShopping: () => _goTo(0)),
    ProfileScreen(onOpenFavorites: () => _goTo(2), onOpenCart: () => _goTo(3)),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartCubit, int>((c) => c.state.count);
    final favCount = context.select<FavoritesCubit, int>((c) => c.state.length);

    final items = [
      const NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
      const NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
      NavItem(Icons.favorite_border_rounded, Icons.favorite_rounded, 'Favorites', badge: favCount),
      NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart', badge: cartCount),
      const NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(0); // back button returns to Home first
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: AppBottomNav(
          items: items,
          currentIndex: _index,
          onTap: _goTo,
        ),
      ),
    );
  }
}
