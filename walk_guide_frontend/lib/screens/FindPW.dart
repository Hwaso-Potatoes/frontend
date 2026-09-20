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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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

  // 비밀번호 재설정 링크 API 호출 연동
  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showStyledDialog('입력 오류', '이메일을 입력해주세요.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showStyledDialog('입력 오류', '올바른 이메일 형식이 아닙니다.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.requestPasswordResetLink(email);
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showStyledDialog('전송 완료', '비밀번호 재설정 링크가 포함된\n이메일을 발송했습니다.');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // 팝업 닫기
            Navigator.pop(context); // 로그인 화면으로 돌아가기
          }
        });
      } else {
        _showStyledDialog('오류', '링크 전송에 실패했습니다.\n가입된 이메일인지 확인해주세요.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
                    Text(
                      'Find Password',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 30),

                    CustomTextField(
                      controller: _emailController,
                      hintText: '가입하신 E-mail을 입력해주세요',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(
                            text: '재설정 링크 받기',
                            onPressed: _handleSendResetLink,
                          ),
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
