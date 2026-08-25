// lib/widgets/walk_distance_chart_card.dart

import 'package:flutter/material.dart';

/// 막대그래프 항목 하나
class ChartBarEntry {
  final String label; // "아침", "월", "1주" 등
  final double value; // km 값
  final bool hasData; // true면 진한 초록, false면 연한 초록(데이터 없음 표시)

  const ChartBarEntry({
    required this.label,
    required this.value,
    required this.hasData,
  });
}

/// 산책 리포트의 막대그래프 카드
/// 막대 너비는 spec 기준 54px이 최대값 - 막대가 적을 때 억지로 넓어지지 않고,
/// 대신 남는 공간은 막대 사이 간격으로 분산됨. 막대 개수가 많아서 54px로는
/// 안 들어갈 때만 자동으로 좁아짐(예: 1년 탭 12개)
class WalkDistanceChartCard extends StatelessWidget {
  final String title; // "오늘 시간대별 거리" 등
  final String totalLabel; // "1.8km" 등 (이미 포맷된 문자열)
  final List<ChartBarEntry> bars;

  static const double _maxBarWidth = 54;

  const WalkDistanceChartCard({
    super.key,
    required this.title,
    required this.totalLabel,
    required this.bars,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue =
        bars.map((b) => b.value).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 234,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA9AA80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.0,
                  color: const Color(0xFF636037).withOpacity(0.75),
                ),
              ),
              Text(
                totalLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final int n = bars.length;
                // 막대 n개를 spec 최대폭(54)으로 다 못 채우면 자동으로 좁아지게 계산
                // (막대 사이 최소 간격 8 확보 기준)
                final double idealWidth =
                    (constraints.maxWidth - 8 * (n - 1)) / n;
                final double barWidth =
                    idealWidth < _maxBarWidth ? idealWidth : _maxBarWidth;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars.map((bar) {
                    // 값이 0이어도 막대가 아예 안 보이면 이상하니 최소 비율(5%) 확보
                    final double heightFraction = maxValue == 0
                        ? 0.05
                        : (bar.value / maxValue).clamp(0.05, 1.0);

                    return SizedBox(
                      width: barWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFraction,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bar.hasData
                                        ? const Color(0xFF72AA4F)
                                        : const Color(0xFFE2F3C2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            bar.label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              height: 1.0,
                              color: const Color(0xFF636037).withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}