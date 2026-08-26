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
    final String caloriesStr = '${reportData.calories}kcal';

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
                  color: Color(0xFF9ECA78),
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

              // 4. 진화 경험치 바
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
                ),
              ),
              const SizedBox(height: 16),

              // 5. 새로운 뱃지 획득 카드
              if (reportData.newBadge != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEFDA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFC7D3B0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF75A64C),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.pets,
                              size: 16,
                              color: Color(0xFF75A64C),
                            ),
                            Text(
                              reportData.newBadge!.tagLabel,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF75A64C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reportData.newBadge!.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reportData.newBadge!.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 16),

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
