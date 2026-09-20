import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kAccentGreen = Color(0xFF27722F);
const Color _kCloseIconColor = Color(0xFF817F5A);

class FindPWReset extends StatefulWidget {
  // 메일 링크(딥링크)를 통해 앱이 켜질 때 전달받을 필수 파라미터들
  final String uid;
  final String token;

  const FindPWReset({super.key, required this.uid, required this.token});

  @override
  State<FindPWReset> createState() => _FindPWResetState();
}

class _FindPWResetState extends State<FindPWReset> {
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

  //  API 연동 로직으로 교체
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) return;

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (context) => const _PasswordMismatchDialog(),
      );
      return;
    }

    if (newPassword.length < 6) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '비밀번호는 최소 6자리 이상이어야 합니다.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // api_service.dart에 추가했던 로그인 전 재설정 API 호출
      final result = await ApiService.confirmPasswordReset(
        uid: widget.uid,
        token: widget.token,
        newPassword: newPassword,
        newPassword2: confirmPassword,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        await showCustomDialog(
          context: context,
          title: '변경 완료',
          message: '비밀번호가 성공적으로 변경되었습니다.\n새 비밀번호로 로그인해주세요.',
        );
        // 완료 후 로그인 화면으로 완전히 돌아가기
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        showCustomDialog(
          context: context,
          title: '오류',
          message: '비밀번호 변경에 실패했습니다. 링크가 만료되었을 수 있습니다.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showCustomDialog(
        context: context,
        title: '오류',
        message: '서버 통신 중 오류가 발생했습니다.',
      );
    }
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
                    // 독립된 화면이므로 그냥 pop 처리
                    onTap: () => Navigator.of(context).pop(),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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

/// 비밀번호 불일치 안내 모달
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
