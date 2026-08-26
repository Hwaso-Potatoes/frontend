import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';

const Color primaryGreen = Color(0xFF27722F);

class ResetPW extends StatefulWidget {
  const ResetPW({super.key});

  @override
  State<ResetPW> createState() => _ResetPWState();
}

class _ResetPWState extends State<ResetPW> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPW() async {
    final currentPassword = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '현재 비밀번호를 입력해주세요.',
      );
      return;
    }

    if (newPassword.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '새 비밀번호를 입력해주세요.',
      );
      return;
    }

    if (newPassword.length < 6) {
      showCustomDialog(
        context: context,
        title: '입력 오류',
        message: '새 비밀번호는 최소 6자리 이상이어야 합니다.',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '새 비밀번호 확인을 입력해주세요.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showCustomDialog(
        context: context,
        title: '비밀번호 불일치',
        message: '새 비밀번호가 서로 일치하지 않습니다.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.resetPassword(
        currentPassword,
        newPassword,
      );
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        await showCustomDialog(
          context: context,
          title: '재설정 완료',
          message: result['message'] ?? '비밀번호가 성공적으로 변경되었습니다.',
        );
        if (mounted) Navigator.pop(context);
      } else {
        await showCustomDialog(
          context: context,
          title: '재설정 실패',
          message: result['message'] ?? '비밀번호 변경에 실패했습니다.',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showCustomDialog(
        context: context,
        title: '오류',
        message: '서버와의 통신 중 오류가 발생했습니다.',
      );
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
                      'Password',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _newPasswordController,
                      hintText: 'New Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 73),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(
                            text: '비밀번호 재설정',
                            onPressed: _handleResetPW,
                          ),
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
