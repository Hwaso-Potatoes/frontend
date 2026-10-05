// lib/screens/qr_friend_add_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'qr_friend_success_screen.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);
const Color darkGreenButton = Color(0xFF386628);
const Color pillBgColor = Color(0xFFCDE2B5);

enum QrTab { myQr, scan }

class QrFriendAddScreen extends StatefulWidget {
  final QrTab initialTab;

  const QrFriendAddScreen({super.key, this.initialTab = QrTab.myQr});

  @override
  State<QrFriendAddScreen> createState() => _QrFriendAddScreenState();
}

class _QrFriendAddScreenState extends State<QrFriendAddScreen> {
  late QrTab _currentTab;
  bool _isLoadingQr = true;
  String _qrToken = '340972816434';
  bool _isRedeeming = false;

  final TextEditingController _scanTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _loadMyQr();
  }

  @override
  void dispose() {
    _scanTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadMyQr() async {
    try {
      final res = await ApiService.generateMyQrCode();
      if (!mounted) return;
      setState(() {
        _qrToken = res.token;
        _isLoadingQr = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingQr = false);
    }
  }

  Future<void> _handleRedeem([String? inputToken]) async {
    final token = inputToken ?? _scanTokenController.text.trim();
    final targetToken = token.isNotEmpty
        ? token
        : 'XmCCVYeINOhy-wFMdAC2Jwlv_-mye3imyaomG-uMo7o';

    setState(() => _isRedeeming = true);

    try {
      final newFriend = await ApiService.redeemQrCode(targetToken);
      if (!mounted) return;

      setState(() => _isRedeeming = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QrFriendSuccessScreen(friend: newFriend),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRedeeming = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('친구 등록 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 상단 헤더: "< QR 친구 추가" ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 32,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'QR 친구 추가',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 메인 콘텐츠 (탭에 따라 내 QR / 스캔) ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _currentTab == QrTab.myQr
                    ? _buildMyQrView()
                    : _buildScanView(),
              ),
            ),

            // ── 하단 세그먼트 토글 바 (내 QR | 스캔하기) ──
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 24,
                top: 12,
              ),
              child: _buildSegmentedPillToggle(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // [Screen 2: 내 QR 코드 카드 뷰]
  // ---------------------------------------------------------------------------
  Widget _buildMyQrView() {
    return Center(
      key: const ValueKey('myQrView'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. 하단 흰색 둥근 카드 (높이 / 패딩)
              Container(
                margin: const EdgeInsets.only(top: 40),
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 56,
                  bottom: 32,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 강아지 이름 및 견종/레벨
                    Text(
                      '뭉치',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '사모예드 | Lv.5',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QR 코드 일러스트 위젯
                    if (_isLoadingQr)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryGreen),
                        ),
                      )
                    else
                      CustomQrCodePainterWidget(token: _qrToken, size: 210),

                    const SizedBox(height: 20),

                    // ID 텍스트 및 안내 문구
                    Text(
                      'ID : ${_qrToken.length > 12 ? _qrToken.substring(0, 12) : _qrToken}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '산책 중 만난 친구에게\n보여주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. 상단 중앙 솟아오른 반려견 원형 아바타 (초록 원 배경 + 사모예드)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF86B453),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/dogs/samoyed.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.pets, size: 40, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // [Screen 3: 스캔 카메라 뷰]
  // ---------------------------------------------------------------------------
  Widget _buildScanView() {
    return Center(
      key: const ValueKey('scanView'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          width: double.infinity,
          height: 480,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. 카메라 라이브 뷰 배경 흉내 (거리 풍경 샘플 일러스트/배경)
              Image.asset(
                'assets/images/dog_main.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF333333),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              ),

              // 2. 카메라 조준 가이드 사각형 뷰
              Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'QR 코드를\n사각형에 맞추세요',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.3,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isRedeeming ? null : () => _handleRedeem(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: _isRedeeming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.qr_code_scanner, size: 18),
                        label: Text(
                          _isRedeeming ? '등록 중...' : 'QR 자동 스캔 실행',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // [하단 세그먼트 토글 바 (내 QR | 스캔하기)]
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedPillToggle() {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pillBgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // 내 QR 탭
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = QrTab.myQr),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentTab == QrTab.myQr
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _currentTab == QrTab.myQr
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '내 QR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _currentTab == QrTab.myQr
                        ? FontWeight.w900
                        : FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // 스캔하기 탭
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = QrTab.scan),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentTab == QrTab.scan
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: _currentTab == QrTab.scan
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '스캔하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: _currentTab == QrTab.scan
                        ? FontWeight.w900
                        : FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// [QR 코드 캔버스 렌더러 위젯]
// -----------------------------------------------------------------------------
class CustomQrCodePainterWidget extends StatelessWidget {
  final String token;
  final double size;

  const CustomQrCodePainterWidget({
    super.key,
    required this.token,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        size: Size(size - 24, size - 24),
        painter: FullQrPainter(token),
      ),
    );
  }
}

class FullQrPainter extends CustomPainter {
  final String token;
  FullQrPainter(this.token);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const int gridSize = 25;
    final double cellSize = size.width / gridSize;

    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          x + 2 * cellSize,
          y + 2 * cellSize,
          3 * cellSize,
          3 * cellSize,
        ),
        paint,
      );
    }

    drawFinder(0, 0);
    drawFinder((gridSize - 7) * cellSize, 0);
    drawFinder(0, (gridSize - 7) * cellSize);

    final hash = token.codeUnits;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if ((r < 7 && c < 7) ||
            (r < 7 && c >= gridSize - 7) ||
            (r >= gridSize - 7 && c < 7)) {
          continue;
        }
        final idx = (r * gridSize + c) % (hash.isNotEmpty ? hash.length : 1);
        final val = hash.isNotEmpty ? hash[idx] : 0;
        if ((val + r * 3 + c * 2) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * cellSize,
              r * cellSize,
              cellSize * 0.92,
              cellSize * 0.92,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
