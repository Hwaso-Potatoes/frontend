import 'package:flutter/material.dart';
import '../models/dog_model.dart';
import '../models/report_model.dart';
import '../widgets/report_period_tabs.dart';
import '../widgets/report_comparison_chart.dart';
import '../widgets/report_streak_banner.dart';
import '../widgets/walk_distance_chart_card.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.day;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  DateTime _move(int direction) => switch (_selectedPeriod) {
    ReportPeriod.day => DateTime(
      _date.year,
      _date.month,
      _date.day + direction,
    ),
    ReportPeriod.month => DateTime(_date.year, _date.month + direction),
    _ => DateTime(_date.year + direction),
  };
  bool get _canGoNext {
    final now = DateTime.now();
    return switch (_selectedPeriod) {
      ReportPeriod.day => _date.isBefore(DateUtils.dateOnly(now)),
      ReportPeriod.month => DateTime(
        _date.year,
        _date.month,
      ).isBefore(DateTime(now.year, now.month)),
      _ => _date.year < now.year,
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = mockComparisonReport(_selectedPeriod, _date);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 64, 28, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '산책 리포트',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ReportPeriodTabs(
                      selected: _selectedPeriod,
                      onChanged: (period) => setState(() {
                        _selectedPeriod = period;
                        _date = DateUtils.dateOnly(DateTime.now());
                      }),
                    ),
                  ],
                ),
              ),
              ReportComparisonChart(
                data: data,
                onPrevious: () => setState(() => _date = _move(-1)),
                onNext: _canGoNext
                    ? () => setState(() => _date = _move(1))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                child: Column(
                  children: [
                    ReportStreakBanner(
                      dogName: dummyDog.name,
                      days: data.streakDays,
                      recordDays: data.recordDays,
                    ),
                    const SizedBox(height: 22),
                    WalkDistanceChartCard(
                      title: data.chartContext,
                      totalLabel: data.peakDistance,
                      bars: data.bars,
                      peakLabel: data.peakLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
