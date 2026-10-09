import 'report_model.dart';
import '../widgets/walk_distance_chart_card.dart';

/// Typed adapter for GET /api/pets/{pet_id}/reports/. Never fills missing points.
ReportComparisonData parsePetWalkReport(Map<String, dynamic> json) {
  final period = json['period'] as String;
  final date = DateTime.parse(json['date'] as String);
  final start = DateTime.parse(json['start_date'] as String);
  final end = DateTime.parse(json['end_date'] as String);
  final comparison = Map<String, dynamic>.from(json['comparison'] as Map);
  final trend = Map<String, dynamic>.from(json['trend'] as Map);
  final highlight = Map<String, dynamic>.from(json['highlight'] as Map);
  List<Map<String, dynamic>> points(String name) =>
      (trend[name] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList()
        ..sort((a, b) => (a['key'] as num).compareTo(b['key'] as num));
  final current = points('current'), previous = points('comparison');
  final keys = [
    ...current,
    ...previous,
  ].map((e) => (e['key'] as num).toDouble()).toList()..sort();
  final first = keys.isEmpty ? 0.0 : keys.first;
  final last = keys.isEmpty ? 0.0 : keys.last;
  List<double> positions(List<Map<String, dynamic>> items) => items
      .map(
        (e) => first == last
            ? 0.5
            : ((e['key'] as num).toDouble() - first) / (last - first),
      )
      .toList();
  final difference = (comparison['difference_km'] as num).toDouble();
  final baseline = comparison['baseline_type'] as String;
  final prefix = switch (baseline) {
    'RECENT_AVERAGE' => '평소보다',
    'PREVIOUS_MONTH' => '지난달보다',
    'PREVIOUS_YEAR' => '작년보다',
    _ => throw const FormatException('지원하지 않는 비교 기준'),
  };
  final label = switch (period) {
    'DAY' => '${date.month}월 ${date.day}일',
    'MONTH' => '${date.year}년 ${date.month}월',
    'YEAR' => '${date.year}년',
    _ => throw const FormatException('지원하지 않는 리포트 기간'),
  };
  final items = highlight['items'] as List;
  final peak = highlight['top_label'] as String?;
  final empty = keys.isEmpty;
  final sorted = [...current, ...previous]
    ..sort((a, b) => (a['key'] as num).compareTo(b['key'] as num));
  return ReportComparisonData(
    periodLabel: label,
    comparisonPrefix: prefix,
    differenceLabel: '${difference.abs().toStringAsFixed(1)}km',
    comparisonSuffix: difference > 0
        ? '더 걸었어요'
        : difference < 0
        ? '덜 걸었어요'
        : '같이 걸었어요',
    currentLegend: period == 'DAY'
        ? '선택일'
        : period == 'MONTH'
        ? '${date.month}월'
        : '${date.year}년',
    previousLegend: baseline == 'RECENT_AVERAGE'
        ? '평균'
        : baseline == 'PREVIOUS_MONTH'
        ? '${DateTime(date.year, date.month - 1).month}월'
        : '${date.year - 1}년',
    current: current.map((e) => (e['distance_km'] as num).toDouble()).toList(),
    previous: previous
        .map((e) => (e['distance_km'] as num).toDouble())
        .toList(),
    currentPositions: positions(current),
    previousPositions: positions(previous),
    currentPointIndex: current.length - 1,
    axisLabels: empty
        ? ['${start.month}.${start.day}', '${end.month}.${end.day}']
        : [sorted.first['label'] as String, sorted.last['label'] as String],
    isDaily: period == 'DAY',
    chartContext: period == 'DAY'
        ? '선택일 시간대'
        : period == 'MONTH'
        ? '선택 월 구간별'
        : '선택 연도 구간별',
    peakLabel: peak,
    serverPeakDistance:
        '${(highlight['top_distance_km'] as num).toStringAsFixed(1)}km',
    totalDistanceKm: (comparison['current_distance_km'] as num).toDouble(),
    bars: items
        .map(
          (e) => ChartBarEntry(
            label: e['label'] as String,
            value: (e['distance_km'] as num).toDouble(),
            hasData: (e['distance_km'] as num) > 0,
          ),
        )
        .toList(),
  );
}
