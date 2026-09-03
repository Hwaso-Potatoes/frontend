import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 성격 태그 1개 (에너지형 / 호기심형 등)
/// TODO(backend): personalities의 정확한 API 키 값(예: "energy" 외 나머지 5개)
/// 아직 확인 안 됨 - 확인되면 이 위젯을 쓰는 쪽(edit_profile_screen 등)에서
/// 한글 라벨 <-> API 키 매핑을 재확인할 것.
///
/// NOTE: 아이콘은 피그마 스펙의 아이콘 크기(16/15/13/14/12/14, 에너지형~얌전형
/// 순서)는 정확히 반영했지만, 정확한 아이콘 "모양" 자체는 원본 디자인을 완전히
/// 판독하기 어려워 의미가 비슷한 Material 아이콘으로 대체함. 확정 디자인
/// 받으면 이 switch문의 icon 값만 교체하면 됨.
class PersonalityTag extends StatelessWidget {
  final String label;
  const PersonalityTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    late final Color bgColor;
    late final IconData icon;
    late final double iconSize;

    switch (label) {
      case '에너지형':
        bgColor = const Color(0xFFFFF9C4);
        icon = Icons.bolt;
        iconSize = 16;
        break;
      case '사회성형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.groups;
        iconSize = 15;
        break;
      case '겁쟁이형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.shield_outlined;
        iconSize = 13;
        break;
      case '호기심형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.search;
        iconSize = 14;
        break;
      case '느긋형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.dark_mode_outlined;
        iconSize = 12;
        break;
      case '얌전형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.local_florist; // TODO(design): 정확한 "화분" 모양은 아니라 근사치. 확정 아이콘 받으면 교체.
        iconSize = 14;
        break;
      default:
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.pets;
        iconSize = 16;
    }

    return Container(
      width: 82,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFA9AA80), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: const Color(0xFF000000)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.0,
              color: const Color(0xFF000000), // spec: 색상 000000 명시
            ),
          ),
        ],
      ),
    );
  }
}