import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product.dart';
import '../l10n/l10n.dart';
import '../../logic/cart/cart_cubit.dart';
import '../../logic/favorites/favorites_cubit.dart';
import 'app_snack.dart';

/// Shared cart / favorite actions with consistent feedback.
void addToCart(BuildContext context, Product product, {int quantity = 1}) {
  if (!product.inStock) {
    showAppSnack(context, 'Sorry, this product is out of stock', icon: Icons.block_rounded);
    return;
  }
  context.read<CartCubit>().add(product, quantity: quantity);
  showAppSnack(
    context,
    quantity > 1
        ? context.tr('{n} × {title} added to cart', {'n': quantity, 'title': product.title})
        : context.tr('{title} added to cart', {'title': product.title}),
    icon: Icons.check_circle_rounded,
  );
}

void toggleFavorite(BuildContext context, Product product) {
  final added = context.read<FavoritesCubit>().toggle(product);
  showAppSnack(
    context,
    added ? 'Added to favorites' : 'Removed from favorites',
    icon: added ? Icons.favorite_rounded : Icons.heart_broken_rounded,
  );
}
