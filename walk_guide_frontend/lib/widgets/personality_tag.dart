import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 성격 태그 1개 (에너지형 / 호기심형 등)
/// ToDo : 백엔드 측에 이거 뭐 있는 지 물어보기. 
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
        iconSize = 16; // spec: 번개모양 16x16
        break;
      case '호기심형':
        bgColor = const Color(0xFFEAE4B1);
        icon = Icons.search;
        iconSize = 14; // spec: 돋보기모양 13x15.15 (평균값 근사)
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
              color: Color(0xFF000000), // spec: 색상 000000 명시
            ),
          ),
        ],
      ),
    );
  }
}