import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'shimmer_box.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(this.url, {super.key, this.fit = BoxFit.contain, this.padding = EdgeInsets.zero});

  final String url;
  final BoxFit fit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      imageBuilder: (_, provider) => Padding(
        padding: padding,
        child: Image(image: provider, fit: fit),
      ),
      placeholder: (_, _) => const AppShimmer(child: ShimmerBox(radius: 0)),
      errorWidget: (_, _, _) => Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
