// lib/screens/qr_friend_add_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  // 내 QR 상태
  bool _isLoadingQr = true;
  String? _qrToken;
  String? _qrErrorMessage;
  int _remainingSeconds = 300;
  Timer? _countdownTimer;

  // 내 반려견 정보
  String _petName = '반려견';
  String _petBreed = '견종';
  int _petLevel = 1;
  String? _petImageUrl;

  // 스캔 상태
  bool _isRedeeming = false;
  MobileScannerController? _scannerController;
  final TextEditingController _manualTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _initScanner();
    _loadMyPetInfo();
    _loadMyQr();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scannerController?.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  /// 내 반려견 정보 조회 (GET api/pets/)
  Future<void> _loadMyPetInfo() async {
    try {
      final pets = await ApiService.getMyPets();
      if (!mounted) return;
      if (pets.isNotEmpty) {
        final pet = pets.first;
        setState(() {
          _petName = pet['name']?.toString() ?? '반려견';
          _petBreed = pet['breed']?.toString() ?? '견종';
          _petLevel = pet['level'] is int ? pet['level'] : 1;
          _petImageUrl = ApiService.resolveMediaUrl(
            pet['profile_image']?.toString(),
          );
        });
      }
    } catch (_) {}
  }

  /// 나의 QR 코드 발급 (POST api/friends/qr/)
  Future<void> _loadMyQr() async {
    setState(() {
      _isLoadingQr = true;
      _qrErrorMessage = null;
    });

    _countdownTimer?.cancel();

    try {
      final res = await ApiService.generateMyQrCode();
      if (!mounted) return;

      setState(() {
        _qrToken = res.token;
        _remainingSeconds = res.expiresIn > 0 ? res.expiresIn : 300;
        _isLoadingQr = false;
      });

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingQr = false;
        _qrErrorMessage = 'QR 코드를 불러오지 못했습니다.\n다시 시도해주세요.';
      });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatRemainingTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// QR 스캔 후 친구 추가 (POST api/friends/qr/redeem/)
  Future<void> _handleRedeem(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty || _isRedeeming) return;

    setState(() => _isRedeeming = true);

    try {
      final newFriend = await ApiService.redeemQrCode(cleanToken);
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

      final msg = e is ApiException ? e.message : '친구 등록 실패: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR 토큰 직접 입력'),
        content: TextField(
          controller: _manualTokenController,
          decoration: const InputDecoration(
            hintText: '발급받은 QR 토큰 문자열 입력',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () {
              final text = _manualTokenController.text.trim();
              Navigator.pop(ctx);
              if (text.isNotEmpty) {
                _handleRedeem(text);
              }
            },
            child: const Text('등록', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
  // [내 QR 코드 카드 뷰]
  // ---------------------------------------------------------------------------
  Widget _buildMyQrView() {
    final bool isExpired = _remainingSeconds == 0;

    return Center(
      key: const ValueKey('myQrView'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. 하단 흰색 둥근 카드
              Container(
                margin: const EdgeInsets.only(top: 40),
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 56,
                  bottom: 28,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 실제 내 반려견 이름 및 견종/레벨
                    Text(
                      _petName,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_petBreed | Lv.$_petLevel',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 실제 표준 규격 QR 코드 렌더링 위젯
                    if (_isLoadingQr)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryGreen),
                        ),
                      )
                    else if (_qrErrorMessage != null)
                      SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _qrErrorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadMyQr,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                              ),
                              child: const Text(
                                '다시 시도',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isExpired)
                      SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_off_outlined,
                              color: Colors.orange,
                              size: 48,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'QR 코드가 만료되었습니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _loadMyQr,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                              ),
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                '새 QR 생성하기',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        child: QrImageView(
                          data: _qrToken!,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    // 남은 만료 시간 표시 (카운트다운)
                    if (!_isLoadingQr && _qrToken != null && !isExpired)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '유효시간 ${_formatRemainingTime(_remainingSeconds)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            color: Colors.black54,
                            tooltip: 'QR 새로고침',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _loadMyQr,
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // 안내 문구
                    const Text(
                      '산책 중 만난 친구에게\nQR 코드를 보여주세요',
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

              // 2. 상단 중앙 반려견 원형 아바타
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
                    child: _buildPetImage(),
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
  // [스캔 카메라 뷰]
  // ---------------------------------------------------------------------------
  Widget _buildPetImage() {
    Widget breedImage() {
      const breeds = <String, String>{
        '비글': 'beagle',
        '비숑': 'bichon',
        '치와와': 'chihuahua',
        '웰시코기': 'corgi',
        '닥스훈트': 'dachshund',
        '도베르만': 'doberman',
        '프렌치불독': 'french_bulldog',
        '골든리트리버': 'golden_retriever',
        '그레이하운드': 'greyhound',
        '허스키': 'husky',
        '말티즈': 'maltese',
        '포메라니안': 'pomeranian',
        '푸들': 'poodle',
        '퍼그': 'pug',
        '사모예드': 'samoyed',
        '슈나우저': 'schnauzer',
      };
      final normalized = _petBreed.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      String? file;
      for (final entry in breeds.entries) {
        if (normalized.contains(entry.key) ||
            normalized == entry.value.replaceAll('_', '')) {
          file = entry.value;
          break;
        }
      }
      if (file == null)
        return const Icon(Icons.pets, size: 40, color: Colors.white);
      return Image.asset(
        'assets/dogs/$file.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets, size: 40, color: Colors.white),
      );
    }

    final image = _petImageUrl;
    if (image == null || image.isEmpty) return breedImage();
    return image.startsWith('assets/')
        ? Image.asset(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => breedImage(),
          )
        : Image.network(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => breedImage(),
          );
  }

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
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. 실제 MobileScanner 카메라 프리뷰
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error) {
                    return Container(
                      color: const Color(0xFF222222),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.videocam_off_outlined,
                              color: Colors.white70,
                              size: 54,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '카메라를 실행할 수 없습니다.\n(권한 확인 또는 웹 브라우저 지원 여부)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showManualInputDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                              ),
                              child: const Text(
                                '토큰 직접 입력하기',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onDetect: (capture) {
                    if (_isRedeeming) return;
                    for (final barcode in capture.barcodes) {
                      final rawValue = barcode.rawValue;
                      if (rawValue != null && rawValue.isNotEmpty) {
                        _handleRedeem(rawValue);
                        break;
                      }
                    }
                  },
                ),

              // 2. 조준 가이드 오버레이
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '친구의 QR 코드를\n사각형에 맞추면 자동으로 인식됩니다',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.3,
                          shadows: const [
                            Shadow(blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isRedeeming)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '친구 등록 중...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        TextButton.icon(
                          onPressed: _showManualInputDialog,
                          icon: const Icon(
                            Icons.keyboard,
                            color: Colors.white70,
                            size: 18,
                          ),
                          label: const Text(
                            '토큰 직접 입력하기',
                            style: TextStyle(
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                              fontSize: 13,
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
              onTap: () {
                setState(() => _currentTab = QrTab.myQr);
              },
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
                            color: Colors.black.withValues(alpha: 0.06),
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
              onTap: () {
                setState(() => _currentTab = QrTab.scan);
              },
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
                            color: Colors.black.withValues(alpha: 0.06),
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
