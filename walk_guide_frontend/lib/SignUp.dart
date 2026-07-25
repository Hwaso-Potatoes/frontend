import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/custom_widgets.dart';
import 'services/api_service.dart';
import 'SignUpInfo1.dart';

const Color primaryGreen = Color(0xFF27722F);

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll('-', '');
    return RegExp(r'^01[016789]\d{7,8}$').hasMatch(cleanPhone);
  }

  Future<void> _handleNextStep() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty) {
      showCustomDialog(context: context, title: '안내', message: '이메일을 입력해주세요.');
      return;
    }

    if (!_isValidEmail(email)) {
      showCustomDialog(
        context: context,
        title: '입력 오류',
        message: '올바른 이메일 형식이 아닙니다.',
      );
      return;
    }

    if (password.isEmpty) {
      showCustomDialog(context: context, title: '안내', message: '비밀번호를 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      showCustomDialog(
        context: context,
        title: '입력 오류',
        message: '비밀번호는 최소 6자리 이상이어야 합니다.',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '비밀번호 확인을 입력해주세요.',
      );
      return;
    }

    if (password != confirmPassword) {
      showCustomDialog(
        context: context,
        title: '비밀번호 불일치',
        message: '비밀번호가 서로 일치하지 않습니다.',
      );
      return;
    }

    if (phone.isEmpty) {
      showCustomDialog(context: context, title: '안내', message: '전화번호를 입력해주세요.');
      return;
    }

    if (!_isValidPhone(phone)) {
      showCustomDialog(
        context: context,
        title: '입력 오류',
        message: '올바른 전화번호 형식이 아닙니다.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.signUp(email, password, phone);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        final String userId = result['user_id']?.toString() ?? '1';

        // 💡 "회원가입 완료" 팝업 없이, 방금 생성된 userId를 들고 즉시 SignUpInfo1 화면으로 이동합니다!
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpInfo1(userId: userId)),
        );
      } else {
        await showCustomDialog(
          context: context,
          title: '오류',
          message: result['message'] ?? '처리 중 오류가 발생했습니다.',
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
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(text: '다음', onPressed: _handleNextStep),
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
