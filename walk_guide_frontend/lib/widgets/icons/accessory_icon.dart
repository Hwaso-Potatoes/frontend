import 'package:flutter/material.dart';
import '../../models/accessory_render_catalog.dart';
import '../asset_viewport.dart';

/// 서버에서 내려주는 액세서리 image URL을 보여주는 위젯
/// - category(HAIR, HAT 등)는 지금 당장은 안 써도, 나중에
///   카테고리별 다른 배치/스타일 줄 일 있을까봐 미리 받아둠
/// - URL이 없거나 로딩 실패하면 placeholder 아이콘으로 대체
class AccessoryIcon extends StatelessWidget {
  final String? imageUrl;
  final String? category;
  final double size;

  const AccessoryIcon({
    super.key,
    required this.imageUrl,
    this.category,
    this.size = 48,
  });

  /// 이미지 없을 때/실패했을 때 보여줄 placeholder 아이콘
  Widget _buildPlaceholder() {
    return Icon(
      Icons.checkroom, // 액세서리 느낌 아이콘 (원하면 다른 아이콘으로 교체 가능)
      size: size,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(width: size, height: size, child: _buildPlaceholder());
    }

    if (imageUrl!.startsWith('assets/')) {
      for (final spec in accessoryRenderCatalog.values) {
        if (spec.asset == imageUrl) {
          final aspect =
              spec.thumbnailBounds.width / spec.thumbnailBounds.height;
          // Hair previews retain more breathing room; wearing size is separate.
          final preferredSize = spec.hairType == HairRenderType.pin
              ? size * 0.42
              : spec.hairType == HairRenderType.hat
              ? size * 0.65
              : size;
          return LayoutBuilder(
            builder: (context, constraints) {
              final thumbnailSize = preferredSize
                  .clamp(0.0, constraints.maxWidth)
                  .clamp(0.0, constraints.maxHeight);
              return Center(
                child: AssetViewport(
                  asset: spec.asset,
                  canvas: spec.canvasSize,
                  frame: spec.thumbnailBounds,
                  width: aspect >= 1 ? thumbnailSize : thumbnailSize * aspect,
                  height: aspect >= 1 ? thumbnailSize / aspect : thumbnailSize,
                ),
              );
            },
          );
        }
      }
      return Image.asset(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => _buildPlaceholder(),
      );
    }
    return Image.network(
      imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(width: size, height: size, child: _buildPlaceholder());
      },
    );
  }
}
