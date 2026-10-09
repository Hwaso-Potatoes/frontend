import 'package:flutter/material.dart';
import '../models/report_model.dart';

class ReportComparisonChart extends StatelessWidget {
  final ReportComparisonData data;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  const ReportComparisonChart({
    super.key,
    required this.data,
    required this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(32, 4, 32, 30),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _arrow('이전 기간', Icons.arrow_left, onPrevious),
            Text(
              data.periodLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            _arrow('다음 기간', Icons.arrow_right, onNext),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${data.comparisonPrefix} '),
                    TextSpan(
                      text: data.differenceLabel,
                      style: const TextStyle(color: Color(0xFF72AA4F)),
                    ),
                    TextSpan(text: '\n${data.comparisonSuffix} '),
                    const WidgetSpan(
                      child: Icon(Icons.pets, size: 18, color: Colors.black54),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  _legend(data.currentLegend, const Color(0xFF72AA4F)),
                  const SizedBox(width: 6),
                  _legend(data.previousLegend, Colors.grey),
                ],
              ),
            ),
          ],
        ),
        if (data.totalDistanceKm != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '총 ${data.totalDistanceKm!.toStringAsFixed(1)}km',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (data.current.isEmpty && data.previous.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('산책 기록이 없습니다.'),
          ),
        const SizedBox(height: 28),
        SizedBox(
          height: 145,
          width: double.infinity,
          child: CustomPaint(
            painter: _ComparisonPainter(
              data.current,
              data.previous,
              data.currentPointIndex,
              data.isDaily,
              data.currentPositions,
              data.previousPositions,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data.axisLabels
              .map(
                (label) => Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF85845F),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _arrow(String tooltip, IconData icon, VoidCallback? onTap) => SizedBox(
    width: 20,
    height: 30,
    child: IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      onPressed: onTap,
      icon: Icon(icon, size: 18),
    ),
  );
  Widget _legend(String label, Color color) => Row(
    children: [
      Container(
        width: 11,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 3),
      Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

class _ComparisonPainter extends CustomPainter {
  final List<double> current;
  final List<double> previous;
  final int pointIndex;
  final bool isDaily;
  final List<double>? currentPositions, previousPositions;
  _ComparisonPainter(
    this.current,
    this.previous,
    this.pointIndex,
    this.isDaily,
    this.currentPositions,
    this.previousPositions,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = [
      ...current,
      ...previous,
    ].fold<double>(0, (a, b) => a > b ? a : b);
    Offset position(List<double> series, int i) => Offset(
      5 +
          (size.width - 10) *
              ((identical(series, current)
                      ? currentPositions
                      : previousPositions)?[i] ??
                  (series.length <= 1 ? 0.5 : i / (series.length - 1))),
      size.height -
          5 -
          series[i] /
              (maxValue == 0 ? 1 : maxValue) *
              (size.height - 15) *
              (isDaily ? .62 : 1),
    );
    Path line(List<double> series) {
      final path = Path();
      for (
        int i = 0;
        i <
            (identical(series, current)
                ? (pointIndex + 1).clamp(0, series.length)
                : series.length);
        i++
      ) {
        final p = position(series, i);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path;
    }

    final greyLine = line(previous);
    final area = Path.from(greyLine)
      ..lineTo(size.width - 5, size.height)
      ..lineTo(5, size.height)
      ..close();
    if (previous.isNotEmpty) {
      canvas.drawPath(
        area,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0E0E0), Color(0x00FFFFFF)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      greyLine,
      Paint()
        ..color = const Color(0xFF999999)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawPath(
      line(current),
      Paint()
        ..color = const Color(0xFF72AA4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    if (current.isNotEmpty && pointIndex >= 0 && pointIndex < current.length) {
      canvas.drawCircle(
        position(current, pointIndex),
        6,
        Paint()..color = const Color(0xFF72AA4F),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ComparisonPainter oldDelegate) =>
      oldDelegate.current != current ||
      oldDelegate.previous != previous ||
      oldDelegate.pointIndex != pointIndex ||
      oldDelegate.currentPositions != currentPositions ||
      oldDelegate.previousPositions != previousPositions;
}
