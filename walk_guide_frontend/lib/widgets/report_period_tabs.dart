// lib/widgets/report_period_tabs.dart

import 'package:flutter/material.dart';
import '../models/report_model.dart';

/// Final report tabs; week and six-month data remain in the model.
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
    const periods = [ReportPeriod.day, ReportPeriod.month, ReportPeriod.year];
    final selectedIndex = periods.indexOf(selected);

    return Container(
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFA5D179),
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
                          switch (period) {
                            ReportPeriod.day => '하루',
                            ReportPeriod.month => '월간',
                            _ => '연간',
                          },
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
