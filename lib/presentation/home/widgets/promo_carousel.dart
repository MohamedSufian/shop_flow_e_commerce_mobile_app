import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/product.dart';
import '../../../core/l10n/l10n.dart';

const _bannerGradients = [
  [Color(0xFF7B5CFF), Color(0xFF4335D9)],
  [Color(0xFFFF9A6C), Color(0xFFFF5E7E)],
  [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
  [Color(0xFF1E1B4B), Color(0xFF4338CA)],
  [Color(0xFFF59E0B), Color(0xFFEF4444)],
];

const _bannerTaglines = [
  'Top rated pick',
  'Limited offer',
  'Trending now',
  'Editor\'s choice',
  'Best seller',
];

/// Auto-scrolling promo banners built from the top rated products.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key, required this.products, this.onTap});

  final List<Product> products;
  final ValueChanged<Product>? onTap;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.products.isEmpty) return;
      final next = (_page + 1) % widget.products.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.products.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _Banner(
                product: widget.products[i],
                colors: _bannerGradients[i % _bannerGradients.length],
                tagline: _bannerTaglines[i % _bannerTaglines.length],
                onTap: () => widget.onTap?.call(widget.products[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.products.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? scheme.primary : scheme.outline,
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.product, required this.colors, required this.tagline, this.onTap});

  final Product product;
  final List<Color> colors;
  final String tagline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: colors.last.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: _circle(150, 0.12),
            ),
            Positioned(
              right: 40,
              bottom: -50,
              child: _circle(110, 0.08),
            ),
            Positioned(
              right: 4,
              top: 10,
              bottom: 10,
              width: 140,
              child: AppNetworkImage(product.thumbnail),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 136, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.tr(tagline).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, height: 1.2, fontSize: 19),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.price.asPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Tr(
                          context.tr('Shop now'),
                          style: TextStyle(color: colors.last, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}
