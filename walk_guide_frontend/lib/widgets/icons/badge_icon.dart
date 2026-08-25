import 'package:flutter/material.dart';

/// 서버에서 내려주는 뱃지 image URL을 보여주는 위젯
/// - URL이 없거나 로딩 실패하면 placeholder 아이콘으로 대체
/// - 백엔드 연결 전(더미 단계)에는 imageUrl에 null을 넘기면 placeholder만 보임
class BadgeIcon extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const BadgeIcon({
    super.key,
    required this.imageUrl,
    this.size = 48,
  });

  /// 이미지 없을 때/실패했을 때 보여줄 placeholder 아이콘
  Widget _buildPlaceholder() {
    return Icon(
      Icons.emoji_events_outlined, // 뱃지 느낌 아이콘 (원하면 다른 아이콘으로 교체 가능)
      size: size,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: _buildPlaceholder(),
      );
    }

    return Image.network(
      imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // 로딩 중 표시
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      // URL 실패(404, 네트워크 에러 등) 시 placeholder 아이콘으로 대체
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: _buildPlaceholder(),
        );
      },
    );
  }
}