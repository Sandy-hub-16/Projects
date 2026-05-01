import 'package:flutter/material.dart';

// Stub for non-web platforms — never actually called because CrossOriginImage
// checks kIsWeb before dispatching here, but required for conditional imports
// to compile on all platforms.
Widget buildWebImage({
  required String imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  throw UnsupportedError('buildWebImage is only available on web');
}
