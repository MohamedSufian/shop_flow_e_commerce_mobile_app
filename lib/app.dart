import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/l10n/l10n.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/models/order.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/synced_list.dart';
import 'data/repositories/user_data_repository.dart';
import 'logic/address/address_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/cart/cart_cubit.dart';
import 'logic/favorites/favorites_cubit.dart';
import 'logic/locale/locale_cubit.dart';
import 'logic/notifications/notifications_cubit.dart';
import 'logic/orders/orders_cubit.dart';
import 'logic/theme/theme_cubit.dart';
import 'presentation/splash/splash_screen.dart';

class ShopFlowApp extends StatelessWidget {
  const ShopFlowApp({super.key, required this.storage});

  final LocalStorage storage;

  SyncedList _synced(BuildContext context, String name) =>
      SyncedList(name: name, storage: storage, cloud: context.read<UserDataRepository>());

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storage),
        RepositoryProvider(create: (_) => ProductRepository(ApiClient())),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserDataRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(storage)),
          BlocProvider(create: (_) => LocaleCubit(storage), lazy: false),
          BlocProvider(create: (context) => AuthCubit(context.read<AuthRepository>())),
          BlocProvider(create: (c) => FavoritesCubit(_synced(c, 'favorites'))),
          BlocProvider(create: (c) => CartCubit(_synced(c, 'cart'))),
          BlocProvider(create: (c) => AddressCubit(_synced(c, 'addresses'))),
          BlocProvider(create: (c) => OrdersCubit(storage, c.read<UserDataRepository>())),
          BlocProvider(create: (_) => NotificationsCubit(storage)),
        ],
        // Load the signed-in user's data whenever the session changes.
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(
              listenWhen: (a, b) => a.user?.uid != b.user?.uid,
              listener: (context, state) {
                final user = state.user;
                final uid = user?.uid;
                context.read<NotificationsCubit>().loadFor(uid);
                context.read<FavoritesCubit>().loadFor(uid);
                context.read<CartCubit>().loadFor(uid);
                context.read<AddressCubit>().loadFor(uid);
                context.read<OrdersCubit>().loadFor(uid);
                if (user != null) {
                  context.read<UserDataRepository>().saveProfile(user).catchError((_) {});
                }
              },
            ),
            // Let notifications track order status changes.
            BlocListener<OrdersCubit, List<Order>>(
              listener: (context, orders) => context.read<NotificationsCubit>().updateOrders(orders),
            ),
          ],
          child: Builder(
            builder: (context) {
              final mode = context.watch<ThemeCubit>().state;
              final locale = context.watch<LocaleCubit>().state;
              final arabic = locale.languageCode == 'ar';
              return MaterialApp(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(arabic: arabic),
                darkTheme: AppTheme.dark(arabic: arabic),
                themeMode: mode,
                themeAnimationDuration: const Duration(milliseconds: 350),
                // Arabic switches the whole app to right-to-left automatically.
                locale: locale,
                supportedLocales: L10n.supported,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const SplashScreen(),
              );
            },
          ),
        ),
      ),
    );
  }
}
