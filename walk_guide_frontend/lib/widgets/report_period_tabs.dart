// lib/widgets/report_period_tabs.dart

import 'package:flutter/material.dart';
import '../models/report_model.dart';

/// 산책 리포트 상단 기간 선택 탭
/// 스펙엔 탭 5개 폭이 텍스트 길이 따라 미세하게 다르게 나와있는데(17/17/28/30/17),
/// 여기서는 5등분 균등폭으로 일반화함 (화면 폭 달라져도 안전하게 동작)
class ReportPeriodTabs extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  const ReportPeriodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ReportPeriod.values;
    final selectedIndex = periods.indexOf(selected);

    return Container(
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF72AA4F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double segmentWidth = constraints.maxWidth / periods.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: segmentWidth * selectedIndex,
                top: 0,
                child: Container(
                  width: segmentWidth,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: periods.map((period) {
                  return SizedBox(
                    width: segmentWidth,
                    height: 24,
                    child: GestureDetector(
                      onTap: () => onChanged(period),
                      child: Center(
                        child: Text(
                          period.tabLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}