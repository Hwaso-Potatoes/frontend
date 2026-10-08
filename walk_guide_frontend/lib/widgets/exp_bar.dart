import 'package:flutter/material.dart';

/// 레벨업 경험치 진행 바
class ExpBar extends StatelessWidget {
  final int currentExp;
  final int requiredExp;
  const ExpBar({super.key, required this.currentExp, required this.requiredExp});

  @override
  Widget build(BuildContext context) {
    final double progress = currentExp / requiredExp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // "다음 레벨까지": Inter 500, 10px, 행간100%, 색 636037 75%
            Text(
              '다음 레벨까지',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 10,
                height: 1.0,
                color: const Color(0xFF636037).withOpacity(0.75),
              ),
            ),
            // "540/700 XP": Inter 700, 10px, 행간100%, 색 000000
            Text(
              '$currentExp/$requiredExp XP',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                height: 1.0,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFFFFFFF),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF72AA4F)),
          ),
        ),
      ],
    );
  }
}