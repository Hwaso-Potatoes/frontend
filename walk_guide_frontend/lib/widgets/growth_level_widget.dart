// lib/widgets/growth_level_widget.dart

import 'package:flutter/material.dart';

/// "이번 주 성장 흐름" 등 섹션의 레벨 칸 + 요약 텍스트
///
/// TODO(backend/기획): 칸 전체 개수(totalCells)를 정하는 규칙이 아직 불명확함.
/// 1일/1주/1개월은 5칸인데 6개월/1년은 그보다 많아 보임 (스크린샷 기준).
/// 정확한 규칙 확인되면 여기서 totalCells를 자동 계산하도록 바꿔야 함.
/// 지금은 화면(report_screen.dart)에서 기간별로 값을 직접 넘겨주는 방식으로 처리.
class GrowthLevelWidget extends StatelessWidget {
  final String summaryText; // "Lv.1 유지 중", "Lv.1 → Lv.2 진화 완료" 등
  final int filledCells; // 채워진(초록) 칸 개수
  final int totalCells; // 전체 칸 개수

  const GrowthLevelWidget({
    super.key,
    required this.summaryText,
    required this.filledCells,
    required this.totalCells,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFA9AA80).withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summaryText,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.1,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: List.generate(totalCells, (index) {
              final bool filled = index < filledCells;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == totalCells - 1 ? 0 : 6,
                  ),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: filled ? const Color(0xFF72AA4F) : Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}