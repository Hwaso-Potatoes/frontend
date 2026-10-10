import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
import 'main_shell.dart';

class WalkReportScreen extends StatelessWidget {
  final WalkReportData reportData;

  const WalkReportScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final String distanceStr =
        '${reportData.totalDistance.toStringAsFixed(1)}km';
    final String durationStr = _formatDuration(reportData.totalDurationStr);
    final String caloriesStr = reportData.hasCaloriesData
        ? '${reportData.calories}kcal'
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 1. 완료 체크 아이콘
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFB4D389),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 68,
                ),
              ),
              const SizedBox(height: 24),

              // 2. 타이틀 & 서브타이틀
              Text(
                '오늘 산책 완료!',
                style: GoogleFonts.notoSansKr(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${reportData.petName}와 함께한 $durationStr',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A7955),
                ),
              ),
              const SizedBox(height: 28),

              // 3. 3개 통계 카드 (거리, 시간, 칼로리)
              Row(
                children: [
                  Expanded(child: _buildStatCard(distanceStr, '이동 거리')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(durationStr, '산책 시간')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(caloriesStr, '소모 칼로리')),
                ],
              ),
              const SizedBox(height: 18),

              // 서버가 경험치 통계를 제공한 경우에만 표시한다.
              if (reportData.hasEarnedExperienceData ||
                  reportData.hasExperienceData)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F6634),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '진화 경험치',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '+${reportData.earnedExp} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      if (reportData.hasExperienceData) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: reportData.expRatio,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF88C15A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '다음 진화까지 ${reportData.expToNextLevel} XP 남았어요',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // 종료 API가 이번 산책에 지급한 배지만 표시한다.
              for (final badge in reportData.acquiredBadges) ...[
                _buildBadgeCard(badge),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),

              // 6. 하단 버튼
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: '공유하기',
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      borderColor: const Color(0xFFD3D8BA),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: '확인',
                      backgroundColor: const Color(0xFF3F6634),
                      textColor: Colors.white,
                      onPressed: () {
                        // 💡 산책 완료 후 MainShellScreen 메인 홈으로 초기화 이동
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainShellScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeData badge) {
    return Semantics(
      label: '새로운 배지 획득: ${badge.title}. ${badge.description}',
      child: CustomPaint(
        foregroundPainter: const _DashedBadgeBorder(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEFDA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE4F0C9),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2280964D),
                      blurRadius: 3,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: badge.tagLabel == 'Day 1'
                      ? const _FirstWalkBadgeIcon()
                      : const Icon(
                          Icons.workspace_premium_rounded,
                          size: 34,
                          color: Color(0xFF83865C),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새로운 뱃지 획득!',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '뱃지 ‘${badge.title}’이 도감에 추가되었어요.',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF838365),
                        height: 1.5,
                      ),
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

  String _formatDuration(String durationStr) {
    if (durationStr.isEmpty || durationStr == '0초') return '00분 00초';
    final minMatch = RegExp(r'(\d+)분').firstMatch(durationStr);
    final secMatch = RegExp(r'(\d+)초').firstMatch(durationStr);

    final String min = (minMatch?.group(1) ?? '0').padLeft(2, '0');
    final String sec = (secMatch?.group(1) ?? '0').padLeft(2, '0');

    return '$min분 $sec초';
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6CEB2), width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

// 첫 산책 배지: 별도 이미지 다운로드 없이 참조 화면의 달력 모양을 그린다.
class _FirstWalkBadgeIcon extends StatelessWidget {
  const _FirstWalkBadgeIcon();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 38,
    height: 44,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 5,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF424733), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFAFC985),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Icon(Icons.pets, size: 14, color: Color(0xFF838365)),
                Text(
                  'Day 1',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final left in [7.0, 27.0])
          Positioned(
            left: left,
            top: 1,
            child: Container(
              width: 3,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF424733), width: 0.8),
              ),
            ),
          ),
      ],
    ),
  );
}

class _DashedBadgeBorder extends CustomPainter {
  const _DashedBadgeBorder();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.6, 0.6, size.width - 1.2, size.height - 1.2),
          const Radius.circular(16),
        ),
      );
    final pen = Paint()
      ..color = const Color(0xFFA9AC83)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 12) {
        final end = (offset + 7).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(offset, end), pen);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
