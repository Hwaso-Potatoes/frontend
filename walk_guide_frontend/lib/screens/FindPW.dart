import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';

const Color primaryGreen = Color(0xFF27722F);

class FindPW extends StatefulWidget {
  const FindPW({super.key});

  @override
  State<FindPW> createState() => _FindPWState();
}

class _FindPWState extends State<FindPW> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _isRequestingCode = false;
  bool _isRequestingTempPW = false;

  // 인증번호 발송 상태를 추적하여 하단 UI를 조건부로 띄움
  bool _isCodeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 커스텀 팝업
  void _showStyledDialog(String title, String subtitle) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 45.0,
                    bottom: 35.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                    children: [
                      // 연두색 느낌표 원형 아이콘
                      Container(
                        width: 85,
                        height: 85,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA5D179),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '!',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 메인 타이틀
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 서브 타이틀
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A7955),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 26,
                      color: Color(0xFF7A7955),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. 인증번호 받기 로직
  Future<void> _handleRequestAuthCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showStyledDialog('입력 오류', '이메일을 입력해주세요.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showStyledDialog('입력 오류', '올바른 이메일 형식이 아닙니다.');
      return;
    }

    setState(() => _isRequestingCode = true);

    try {
      // TODO: 백엔드 API 연동 (인증번호 발송 API)
      await Future.delayed(const Duration(seconds: 1)); // 통신 딜레이 모방

      if (!mounted) return;

      setState(() {
        _isRequestingCode = false;
        _isCodeSent = true;
      });
    } catch (e) {
      setState(() => _isRequestingCode = false);
      if (!mounted) return;
      _showStyledDialog('오류', '서버와의 통신 중\n오류가 발생했습니다.');
    }
  }

  // 2. 임시 비밀번호 받기 로직
  Future<void> _handleIssueTempPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      _showStyledDialog('입력 오류', '이메일과 인증번호를\n모두 입력해주세요.');
      return;
    }

    // 예시: 인증번호가 틀렸다고 가정한 UI 테스트 (실 연동시에는 서버 응답값으로 처리)
    if (code != "1234") {
      _showStyledDialog('인증번호가\n일치하지 않습니다', '다시 입력해주시겠어요');
      return;
    }

    setState(() => _isRequestingTempPW = true);

    try {
      // TODO: 백엔드 API 연동 (인증번호 검증 및 임시 비밀번호 발급 API)
      await Future.delayed(const Duration(seconds: 1)); // 통신 딜레이 모방

      setState(() => _isRequestingTempPW = false);
      if (!mounted) return;

      _showStyledDialog('발급 완료', '이메일로 임시 비밀번호가 전송되었습니다.\n로그인 후 비밀번호를 변경해주세요.');

      // 2초 뒤 로그인 화면으로 자동 복귀
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() => _isRequestingTempPW = false);
      if (!mounted) return;
      _showStyledDialog('오류', '서버와의 통신 중\n오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 경로 이미지
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/background1.png',
              fit: BoxFit.fill,
            ),
          ),
          // 우측 나무 이미지
          Positioned(
            top: 103,
            left: 269,
            width: 119,
            height: 147,
            child: Image.asset('assets/images/trees.png', fit: BoxFit.contain),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 228),

                    // 뒤로가기 버튼
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back, size: 16, color: primaryGreen),
                          SizedBox(width: 4),
                          Text(
                            'Back to login',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 타이틀
                    Text(
                      'Find Password',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. 이메일 입력 영역
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _isRequestingCode
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(
                            text: '인증번호 받기',
                            onPressed: _handleRequestAuthCode,
                          ),

                    // 2. 인증번호 발송이 완료되었을 때 하단 UI 표시
                    if (_isCodeSent) ...[
                      const SizedBox(height: 50),

                      CustomTextField(
                        controller: _codeController,
                        hintText: 'Enter code',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _isRequestingTempPW
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryGreen,
                              ),
                            )
                          : CustomButton(
                              text: '임시 비밀번호 받기',
                              onPressed: _handleIssueTempPassword,
                            ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
