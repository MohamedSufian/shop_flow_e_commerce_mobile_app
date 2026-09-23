import 'package:flutter/material.dart';

/// Icon + tint for each DummyJSON category slug.
class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);

  static const _fallback = CategoryStyle(Icons.category_rounded, Color(0xFF5B4BF5));

  static const Map<String, CategoryStyle> _map = {
    'beauty': CategoryStyle(Icons.brush_rounded, Color(0xFFEC4899)),
    'fragrances': CategoryStyle(Icons.spa_rounded, Color(0xFFA855F7)),
    'furniture': CategoryStyle(Icons.chair_rounded, Color(0xFFB45309)),
    'groceries': CategoryStyle(Icons.local_grocery_store_rounded, Color(0xFF16A34A)),
    'home-decoration': CategoryStyle(Icons.home_rounded, Color(0xFFF97316)),
    'kitchen-accessories': CategoryStyle(Icons.kitchen_rounded, Color(0xFF0EA5E9)),
    'laptops': CategoryStyle(Icons.laptop_mac_rounded, Color(0xFF6366F1)),
    'mens-shirts': CategoryStyle(Icons.checkroom_rounded, Color(0xFF2563EB)),
    'mens-shoes': CategoryStyle(Icons.hiking_rounded, Color(0xFF475569)),
    'mens-watches': CategoryStyle(Icons.watch_rounded, Color(0xFF0F766E)),
    'mobile-accessories': CategoryStyle(Icons.headphones_rounded, Color(0xFF7C3AED)),
    'motorcycle': CategoryStyle(Icons.two_wheeler_rounded, Color(0xFFDC2626)),
    'skin-care': CategoryStyle(Icons.face_retouching_natural_rounded, Color(0xFFF43F5E)),
    'smartphones': CategoryStyle(Icons.smartphone_rounded, Color(0xFF4F46E5)),
    'sports-accessories': CategoryStyle(Icons.sports_basketball_rounded, Color(0xFFEA580C)),
    'sunglasses': CategoryStyle(Icons.wb_sunny_rounded, Color(0xFFEAB308)),
    'tablets': CategoryStyle(Icons.tablet_mac_rounded, Color(0xFF0891B2)),
    'tops': CategoryStyle(Icons.dry_cleaning_rounded, Color(0xFFDB2777)),
    'vehicle': CategoryStyle(Icons.directions_car_rounded, Color(0xFF1D4ED8)),
    'womens-bags': CategoryStyle(Icons.shopping_bag_rounded, Color(0xFFBE185D)),
    'womens-dresses': CategoryStyle(Icons.woman_rounded, Color(0xFFC026D3)),
    'womens-jewellery': CategoryStyle(Icons.diamond_rounded, Color(0xFF9333EA)),
    'womens-shoes': CategoryStyle(Icons.ice_skating_rounded, Color(0xFFE11D48)),
    'womens-watches': CategoryStyle(Icons.watch_later_rounded, Color(0xFF0D9488)),
  };

  static CategoryStyle of(String slug) => _map[slug] ?? _fallback;
}
