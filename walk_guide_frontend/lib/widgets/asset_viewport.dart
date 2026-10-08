import 'package:flutter/material.dart';

/// Explicit image dimensions prevent parent constraints from shrinking the
/// source canvas before its transparent export padding is translated away.
class AssetViewport extends StatelessWidget {
  final String asset;
  final Size canvas;
  final Rect frame;
  final double width, height;
  const AssetViewport({
    super.key,
    required this.asset,
    required this.canvas,
    required this.frame,
    required this.width,
    required this.height,
  });
  @override
  Widget build(BuildContext context) {
    final sx = width / frame.width;
    final sy = height / frame.height;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -frame.left * sx,
              top: -frame.top * sy,
              width: canvas.width * sx,
              height: canvas.height * sy,
              child: Image.asset(asset, fit: BoxFit.fill),
            ),
          ],
        ),
      ),
    );
  }
}
