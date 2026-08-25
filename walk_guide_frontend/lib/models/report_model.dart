// lib/models/report_model.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. 기간별 "권장 산책 거리" 값 출처 (1.8/12/48/288/576km 등) - 지금은 전부 더미값
// 2. earned_badges 응답에 badge_id, name, acquired_at만 있고 image가 없음
//    -> 뱃지 이미지를 보여주려면 보유 뱃지 목록 API랑 별도로 조합해야 하는지,
//       아니면 이 응답에 image 필드 추가해줄 수 있는지 확인 필요
// 3. "성장 흐름" 칸 전체 개수(totalCells) 규칙 불명확
//    -> 1일/1주/1개월은 5칸, 6개월/1년은 그보다 많아 보임. 정확한 규칙 확인 필요.
//       지금은 GrowthLevelWidget에 기간별로 직접 값을 넣어두는 방식으로 임시 처리함

import 'package:flutter/material.dart';
import '../widgets/walk_distance_chart_card.dart';

enum ReportPeriod { day, week, month, sixMonths, year }

extension ReportPeriodLabel on ReportPeriod {
  String get tabLabel {
    switch (this) {
      case ReportPeriod.day:
        return '1일';
      case ReportPeriod.week:
        return '1주';
      case ReportPeriod.month:
        return '1개월';
      case ReportPeriod.sixMonths:
        return '6개월';
      case ReportPeriod.year:
        return '1년';
    }
  }
}

/// 기간(1일~1년) 하나에 해당하는 리포트 화면 데이터
class ReportData {
  final String chartTitle; // "오늘 시간대별 거리" 등
  final String totalLabel; // "1.8km" 등 (이미 포맷된 문자열)
  final List<ChartBarEntry> bars;

  final double recommendedDistanceKm; // TODO(backend): 출처 미확정, 더미값
  final double achievedDistanceKm;
  final int achievementRate;

  final String growthTitle; // "이번 주 성장 흐름" 등
  final String growthSummaryText; // "Lv.1 유지 중" 등
  final int growthFilledCells;
  final int growthTotalCells; // TODO(backend/기획): 규칙 확인 전까지 더미값

  final String badgeTitle; // "오늘 획득 뱃지" 등
  final List<String> badgeImagePaths;

  const ReportData({
    required this.chartTitle,
    required this.totalLabel,
    required this.bars,
    required this.recommendedDistanceKm,
    required this.achievedDistanceKm,
    required this.achievementRate,
    required this.growthTitle,
    required this.growthSummaryText,
    required this.growthFilledCells,
    required this.growthTotalCells,
    required this.badgeTitle,
    required this.badgeImagePaths,
  });
}

/// 뱃지 예시 이미지 (실제 보유 뱃지 조회 API에서 확인된 URL 하나 재사용,
/// 나머지는 더미로 같은 이미지 반복 - 실제 이미지 URL 필요)
const String _sampleBadgeImage =
    'http://127.0.0.1:8000/media/badges/%E1%84%8E%E1%85%A5%E1%86%BA_%E1%84%89%E1%85%A1%E1%86%AB%E1%84%8E%E1%85%A2%E1%86%A8_a32QEk7.png';

/// 기간별 더미 데이터 (스크린샷 수치 기준으로 구성)
final Map<ReportPeriod, ReportData> dummyReportData = {
  ReportPeriod.day: ReportData(
    chartTitle: '오늘 시간대별 거리',
    totalLabel: '1.8km',
    bars: const [
      ChartBarEntry(label: '아침', value: 0.6, hasData: true),
      ChartBarEntry(label: '점심', value: 0.0, hasData: false),
      ChartBarEntry(label: '오후', value: 0.0, hasData: false),
      ChartBarEntry(label: '저녁', value: 1.2, hasData: true),
    ],
    recommendedDistanceKm: 1.8,
    achievedDistanceKm: 1.8,
    achievementRate: 100,
    growthTitle: '이번 주 성장 흐름',
    growthSummaryText: 'Lv.1 유지 중',
    growthFilledCells: 1,
    growthTotalCells: 5,
    badgeTitle: '오늘 획득 뱃지',
    badgeImagePaths: const [_sampleBadgeImage],
  ),

  ReportPeriod.week: ReportData(
    chartTitle: '이번 주 총 거리',
    totalLabel: '11.4km',
    bars: const [
      ChartBarEntry(label: '월', value: 2.0, hasData: true),
      ChartBarEntry(label: '화', value: 1.8, hasData: true),
      ChartBarEntry(label: '수', value: 0.3, hasData: false),
      ChartBarEntry(label: '목', value: 2.6, hasData: true),
      ChartBarEntry(label: '금', value: 1.6, hasData: true),
      ChartBarEntry(label: '토', value: 2.1, hasData: true),
      ChartBarEntry(label: '일', value: 0.3, hasData: false),
    ],
    recommendedDistanceKm: 12,
    achievedDistanceKm: 11.4,
    achievementRate: 95,
    growthTitle: '이번 주 성장 흐름',
    growthSummaryText: 'Lv.1 → Lv.2 진화 완료',
    growthFilledCells: 2,
    growthTotalCells: 5,
    badgeTitle: '이번 주 획득 뱃지',
    badgeImagePaths: const [_sampleBadgeImage, _sampleBadgeImage, _sampleBadgeImage],
  ),

  ReportPeriod.month: ReportData(
    chartTitle: '이번 달 주차별 거리',
    totalLabel: '46.8km',
    bars: const [
      ChartBarEntry(label: '1주', value: 10, hasData: true),
      ChartBarEntry(label: '2주', value: 8, hasData: true),
      ChartBarEntry(label: '3주', value: 16, hasData: true),
      ChartBarEntry(label: '4주', value: 12.8, hasData: true),
      // TODO(backend): 실제 API 샘플엔 5주차까지 있었음, 5주가 있는 달이면 항목 추가됨
    ],
    recommendedDistanceKm: 48,
    achievedDistanceKm: 46.8,
    achievementRate: 98,
    growthTitle: '이번 달 성장 흐름',
    growthSummaryText: 'Lv.1 → Lv.3 진화 완료',
    growthFilledCells: 3,
    growthTotalCells: 5,
    badgeTitle: '이번 달 획득 뱃지',
    badgeImagePaths: const [
      _sampleBadgeImage,
      _sampleBadgeImage,
      _sampleBadgeImage,
      _sampleBadgeImage,
    ],
  ),

  ReportPeriod.sixMonths: ReportData(
    chartTitle: '월별 총 거리',
    totalLabel: '275km',
    bars: const [
      ChartBarEntry(label: '2월', value: 40, hasData: true),
      ChartBarEntry(label: '3월', value: 48, hasData: true),
      ChartBarEntry(label: '4월', value: 35, hasData: true),
      ChartBarEntry(label: '5월', value: 52, hasData: true),
      ChartBarEntry(label: '6월', value: 45, hasData: true),
      ChartBarEntry(label: '7월', value: 55, hasData: true),
    ],
    recommendedDistanceKm: 288,
    achievedDistanceKm: 275,
    achievementRate: 96,
    growthTitle: '6개월 성장 흐름',
    growthSummaryText: 'Lv.1 → Lv.5 진화 완료',
    growthFilledCells: 5,
    growthTotalCells: 7,
    badgeTitle: '6개월 획득 뱃지',
    badgeImagePaths: List.generate(5, (_) => _sampleBadgeImage),
  ),

  ReportPeriod.year: ReportData(
    chartTitle: '월별 총 거리',
    totalLabel: '519km',
    bars: const [
      ChartBarEntry(label: '1', value: 38, hasData: true),
      ChartBarEntry(label: '2', value: 42, hasData: true),
      ChartBarEntry(label: '3', value: 55, hasData: true),
      ChartBarEntry(label: '4', value: 58, hasData: true),
      ChartBarEntry(label: '5', value: 44, hasData: true),
      ChartBarEntry(label: '6', value: 40, hasData: true),
      ChartBarEntry(label: '7', value: 50, hasData: true),
      ChartBarEntry(label: '8', value: 60, hasData: true),
      ChartBarEntry(label: '9', value: 30, hasData: true),
      ChartBarEntry(label: '10', value: 34, hasData: true),
      ChartBarEntry(label: '11', value: 40, hasData: true),
      ChartBarEntry(label: '12', value: 28, hasData: true),
    ],
    recommendedDistanceKm: 576,
    achievedDistanceKm: 519,
    achievementRate: 90,
    growthTitle: '올해 성장 흐름',
    growthSummaryText: 'Lv.1 → Lv.9 최고 등급 달성',
    growthFilledCells: 9,
    growthTotalCells: 9,
    badgeTitle: '올해 획득 뱃지',
    badgeImagePaths: List.generate(8, (_) => _sampleBadgeImage),
  ),
};