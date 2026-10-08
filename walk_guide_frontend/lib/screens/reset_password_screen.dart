// lib/screens/reset_password_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. POST api/users/password/reset/ 실제 연동 지점은 _handleSubmit()에 표시해둠.
// 2. 이 화면은 일반 push가 아니라 widgets/slide_up_sheet_route.dart의
//    pushSlideUpSheet()로 열어야 함 (환경설정 화면 위에 시트처럼 뜸).

import 'package:flutter/material.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kAccentGreen = Color(0xFF27722F);
const Color _kCloseIconColor = Color(0xFF817F5A);

/// POST api/users/password/reset/ 를 흉내낸 mock.
/// TODO(backend): 실제 HTTP 호출로 교체할 것.
Future<void> mockResetPassword(String newPassword) async {
  await Future.delayed(const Duration(milliseconds: 300));
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) return;

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) => const _PasswordMismatchDialog(),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO(backend): mockResetPassword() -> 실제 POST api/users/password/reset/ 호출로 교체
    await mockResetPassword(newPassword);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
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

              // ── 뒤로가기 + "비밀번호 재설정" 타이틀 ──
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
                    '비밀번호 재설정',
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

              // ── "비밀번호를 적어주세요" ──
              Text(
                '비밀번호를 적어주세요',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  height: 1.0,
                  color: _kOliveText.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 16),

              _buildPasswordField(
                controller: _newPasswordController,
                hint: '새 비밀번호',
              ),

              const SizedBox(height: 17),

              _buildPasswordField(
                controller: _confirmPasswordController,
                hint: '새 비밀번호 확인',
              ),

              const Spacer(),

              // ── 비밀번호 재설정 버튼 ──
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
                            '비밀번호 재설정',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
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
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
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
    );
  }
}

/// 비밀번호 불일치 안내 모달 (로그아웃 모달과 같은 틀, 버튼 대신 X로 닫음)
class _PasswordMismatchDialog extends StatelessWidget {
  const _PasswordMismatchDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 43),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── 초록 원 + 느낌표 ──
                Container(
                  width: 77,
                  height: 77,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFAAD480),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                      height: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '비밀번호가\n일치하지 않습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.1,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '다시 입력해주시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.0,
                    color: _kOliveText.withOpacity(0.75),
                  ),
                ),
              ],
            ),
            // ── 오른쪽 위 X 닫기 버튼 ──
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: _kCloseIconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}