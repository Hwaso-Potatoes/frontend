// lib/screens/change_email_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. POST api/users/email/change/ 실제 연동 지점은 _handleSubmit()에 표시해둠.
// 2. 이 화면은 일반 push가 아니라 widgets/slide_up_sheet_route.dart의
//    pushSlideUpSheet()로 열어야 함 (환경설정 화면 위에 시트처럼 뜸).

import 'package:flutter/material.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kAccentGreen = Color(0xFF27722F);

/// POST api/users/email/change/ 를 흉내낸 mock.
/// TODO(backend): 실제 HTTP 호출로 교체할 것.
Future<void> mockChangeEmail(String newEmail) async {
  await Future.delayed(const Duration(milliseconds: 300));
}

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    // TODO(backend): mockChangeEmail() -> 실제 POST api/users/email/change/ 호출로 교체
    await mockChangeEmail(email);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이메일이 변경되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 37),

              // ── 뒤로가기 + "이메일 변경" 타이틀 ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: _kOliveText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '이메일 변경',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 57),

              // ── "이메일을 적어주세요" ──
              Text(
                '이메일을 적어주세요',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  height: 1.0,
                  color: _kOliveText.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 16),

              // ── 이메일 입력칸 ──
              Container(
                width: double.infinity,
                height: 49,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _kAccentGreen, width: 1),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '이메일 주소',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),

              const Spacer(),

              // ── 이메일 변경 버튼 ──
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onTap: _handleSubmit,
                  child: Container(
                    width: double.infinity,
                    height: 49,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kAccentGreen,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _kAccentGreen, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(3, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '이메일 변경',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              height: 1.0,
                              color: Colors.white,
                            ),
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
}