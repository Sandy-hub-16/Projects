import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Web-only imports — only compiled on web builds.
import 'cross_origin_image_web.dart'
    if (dart.library.io) 'cross_origin_image_stub.dart' as platform;

/// Displays a network image without CORS restrictions on Flutter web.
///
/// On web, renders a native <img> element via HtmlElementView which browsers
/// allow to load cross-origin images freely (no CORS headers required).
/// On mobile/desktop, falls back to CachedNetworkImage.
class CrossOriginImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CrossOriginImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return platform.buildWebImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(color: Colors.grey[300]),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
