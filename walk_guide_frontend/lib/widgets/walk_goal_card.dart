// lib/widgets/walk_goal_card.dart

import 'package:flutter/material.dart';

/// "OO 권장 XXkm 대비 YY%" 카드
/// 원래 profile_screen.dart 안에 private 메서드(_buildWalkGoalCard)로 있던 걸
/// 산책 리포트 화면에서도 재사용하기 위해 공용 위젯으로 분리함
/// (디자인/스펙은 그대로, 위치만 옮김)
class WalkGoalCard extends StatelessWidget {
  final String breed;
  final double goalDistanceKm;
  final double actualDistanceKm;
  final int achievementRate;

  const WalkGoalCard({
    super.key,
    required this.breed,
    required this.goalDistanceKm,
    required this.actualDistanceKm,
    required this.achievementRate,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        goalDistanceKm == 0 ? 0 : actualDistanceKm / goalDistanceKm;

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFA9AA80).withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$breed 권장 ${_formatKm(goalDistanceKm)}km 대비',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.1,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Text(
                '$achievementRate%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                  height: 1.0,
                  fontFamily: 'Inter',
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF72AA4F)),
            ),
          ),
        ],
      ),
    );
  }

  /// 48.0 -> "48", 1.8 -> "1.8" 처럼 정수는 정수로, 소수는 소수로 표시
  String _formatKm(double km) {
    return km == km.roundToDouble() ? km.toInt().toString() : km.toString();
  }
}