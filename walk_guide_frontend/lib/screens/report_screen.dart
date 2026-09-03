// lib/screens/report_screen.dart

import 'package:flutter/material.dart';
import '../models/dog_model.dart';
import '../models/report_model.dart';
import '../widgets/report_period_tabs.dart';
import '../widgets/walk_distance_chart_card.dart';
import '../widgets/walk_goal_card.dart';
import '../widgets/growth_level_widget.dart';
import '../widgets/badge_row.dart';

const Color backgroundColor = Color(0xFFF8F9E5);

/// 산책 리포트 화면
/// 상단 기간 탭(1일~1년)에 따라 아래 데이터가 통째로 바뀜
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.day;

  @override
  Widget build(BuildContext context) {
    final ReportData data = dummyReportData[_selectedPeriod]!;
    final DogModel dog = dummyDog; // 견종 이름 등에 사용

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── "산책 리포트" 타이틀 (내 친구 화면과 굵기 통일: w800 → w600) ──
                const Text(
                  '산책 리포트',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // ── 기간 선택 탭 ──
                ReportPeriodTabs(
                  selected: _selectedPeriod,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),

                const SizedBox(height: 20),

                // ── 막대그래프 카드 ──
                WalkDistanceChartCard(
                  title: data.chartTitle,
                  totalLabel: data.totalLabel,
                  bars: data.bars,
                ),

                const SizedBox(height: 27),

                // ── 견종 권장량 달성률 ──
                const Text(
                  '견종 권장량 달성률',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 13),
                WalkGoalCard(
                  breed: dog.breed,
                  goalDistanceKm: data.recommendedDistanceKm,
                  actualDistanceKm: data.achievedDistanceKm,
                  achievementRate: data.achievementRate,
                ),

                const SizedBox(height: 27),

                // ── 성장 흐름 ──
                Text(
                  data.growthTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 13),
                GrowthLevelWidget(
                  summaryText: data.growthSummaryText,
                  filledCells: data.growthFilledCells,
                  totalCells: data.growthTotalCells,
                ),

                const SizedBox(height: 27),

                // ── 획득 뱃지 ──
                Text(
                  data.badgeTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 13),
                BadgeRow(badgeImagePaths: data.badgeImagePaths),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}