import 'package:flutter/material.dart';
import 'icons/badge_icon.dart';

/// 뱃지 이미지들을 나열 (원래 spec 크기 65x64 고정 유지)
/// Row 대신 Wrap을 써서, 한 줄에 다 못 들어가면 자동으로 다음 줄로 넘어감
/// (일반적인 폰 화면 폭 기준으로는 자연스럽게 4개씩 줄바꿈됨)
class BadgeRow extends StatelessWidget {
  final List<String> badgeImagePaths;
  final int? maxCount;

  const BadgeRow({super.key, required this.badgeImagePaths, this.maxCount});

  @override
  Widget build(BuildContext context) {
    final displayBadges = maxCount != null
        ? badgeImagePaths.take(maxCount!).toList()
        : badgeImagePaths;

    return Wrap(
      spacing: 14, // 뱃지 사이 가로 간격 (spec 기준, 그대로 유지)
      runSpacing: 14, // 줄바꿈됐을 때 세로 간격
      children: displayBadges.map((imageUrl) {
        return Container(
          width: 65, // spec: 65x64, 그대로 유지
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFA9AA80).withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5), // 65x64 박스 안에 54x54 이미지, 그대로 유지
            child: BadgeIcon(imageUrl: imageUrl, size: 54),
          ),
        );
      }).toList(),
    );
  }
}