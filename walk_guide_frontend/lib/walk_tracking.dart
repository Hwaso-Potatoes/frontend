import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/custom_widgets.dart';
import 'walk_report.dart';

class WalkTrackingScreen extends StatefulWidget {
  const WalkTrackingScreen({super.key});

  @override
  State<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends State<WalkTrackingScreen> {
  int _currentIndex = 2; // 산책 탭 활성화
  bool _isWalking = true;
  int _seconds = 1945; // 32분 25초
  double _distance = 1.8;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWalking) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '$min분 ${sec.toString().padLeft(2, '0')}초';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6DF), // 지도 영역 연두 베이지
      body: Stack(
        children: [
          // 1. 지도 캔버스 영역 (실제 네이버/구글맵 지도 연동 전 더미 캔버스)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF6F8E5),
              child: Stack(
                children: [
                  // 내 위치 화살표 인디케이터
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.46,
                    left: MediaQuery.of(context).size.width * 0.46,
                    child: const Icon(
                      Icons.navigation,
                      color: Color(0xFF3F6F33),
                      size: 38,
                    ),
                  ),

                  // 주변 친구 마커 ('토리')
                  Positioned(
                    top: 150,
                    right: 48,
                    child: _buildFriendMarker(
                      '토리',
                      'assets/images/dog_main.png',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 하단 산책 트래킹 컨트롤 카드 (거리, 시간, 일시정지/종료)
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 이동 거리
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_distance.toStringAsFixed(1)}km',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          '이동 거리',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.black12),
                  const SizedBox(width: 18),

                  // 산책 시간
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDuration(_seconds),
                          style: GoogleFonts.notoSansKr(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          '산책 시간',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),

                  // 산책 종료/재생 버튼 (누르면 리포트 화면으로 이동)
                  GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalkReportScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF75A64C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 공통 하단 네비게이션 바
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 0) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendMarker(String name, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFF3F6634),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.pets,
                      color: Color(0xFF3F6634),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
