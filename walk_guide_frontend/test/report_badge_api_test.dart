import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walk_guide_frontend/models/pet_walk_report.dart';
import 'package:walk_guide_frontend/models/badge_asset_catalog.dart';
import 'package:walk_guide_frontend/services/badge_book_service.dart';
import 'package:walk_guide_frontend/widgets/report_comparison_chart.dart';
import 'package:walk_guide_frontend/widgets/report_streak_banner.dart';

Map<String, dynamic> report({double difference = -2, bool empty = false}) => {
  'period': 'MONTH',
  'date': '2026-01-01',
  'start_date': '2026-01-01',
  'end_date': '2026-01-31',
  'comparison': {
    'current_distance_km': 3.0,
    'baseline_distance_km': 5.0,
    'difference_km': difference,
    'baseline_type': 'PREVIOUS_MONTH',
  },
  'trend': {
    'current': empty
        ? []
        : [
            {'key': 3, 'label': '3일', 'distance_km': 2.0},
            {'key': 1, 'label': '1일', 'distance_km': 1.0},
          ],
    'comparison': empty
        ? []
        : [
            {'key': 2, 'label': '2일', 'distance_km': 5.0},
          ],
  },
  'highlight': {
    'top_label': empty ? null : '1주',
    'top_distance_km': empty ? 0 : 3.0,
    'items': empty
        ? []
        : [
            {'key': '1', 'label': '1주', 'distance_km': 3.0},
          ],
  },
};
void main() {
  test('badge ownership is merged by ID, not list order or filename', () {
    final badges = mergeBadges(
      [
        {'id': 13, 'name': '첫 발자국', 'description': '첫 산책'},
        {'id': 1, 'name': '첫 친구', 'description': '친구 추가'},
      ],
      [
        {
          'badge': {'id': 13, 'name': '첫 발자국', 'description': '첫 산책'},
          'acquired_at': '2026-10-09T01:00:00Z',
        },
      ],
    );
    expect(badges.map((b) => b.id), [1, 13]);
    expect(badges.first.isOwned, false);
    expect(badges.last.isOwned, true);
    expect(badges.last.description, '첫 산책');
    expect(badges.last.acquiredAt, DateTime.utc(2026, 10, 9, 1));
    expect(mergeBadges([], []), isEmpty);
  });
  test('all 19 mapped PNGs exist; unused friendship medals excluded', () {
    expect(badgeAssetCatalog.keys, List.generate(19, (i) => i + 1));
    for (final asset in badgeAssetCatalog.values) {
      expect(File(asset!).existsSync(), true, reason: asset);
      expect(asset.contains('단짝'), false);
    }
  });
  test(
    'report uses server comparison, highlight and keyed point positions',
    () {
      final data = parsePetWalkReport(report());
      expect(data.comparisonSuffix, '덜 걸었어요');
      expect(data.previousLegend, '12월');
      expect(data.current, [1.0, 2.0]);
      expect(data.currentPositions, [0.0, 1.0]);
      expect(data.previousPositions, [0.5]);
      expect(data.totalDistanceKm, 3.0);
      expect(data.peakDistance, '3.0km');
      expect(
        parsePetWalkReport(report(difference: 0)).comparisonSuffix,
        '같이 걸었어요',
      );
      expect(
        parsePetWalkReport(report(difference: 2)).comparisonSuffix,
        '더 걸었어요',
      );
    },
  );
  testWidgets(
    'empty and unequal graph series render without invalid coordinates',
    (tester) async {
      for (final empty in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReportComparisonChart(
                data: parsePetWalkReport(report(empty: empty)),
                onPrevious: () {},
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('zero streak does not claim an ongoing walk', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportStreakBanner(dogName: '두부', days: 0, recordDays: 0),
        ),
      ),
    );
    expect(find.text('두부의 연속 산책을 시작해보세요!'), findsOneWidget);
  });
}
