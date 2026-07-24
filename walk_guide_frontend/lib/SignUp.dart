import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
//이미지말고 최대한 폰트를 사용해보려고 flutter pub add google_fonts 터미널에 이거 기입 후 임포트함.

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 파동 이미지 (시안 위치 적용)
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

          // 2. 나무 이미지 (시안 위치 적용)
          Positioned(
            top: 103,
            left: 269,
            width: 119,
            height: 147,
            child: Image.asset('assets/images/trees.png', fit: BoxFit.contain),
          ),

          // 3. 메인 콘텐츠
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

                    // 로그인으로 돌아가기 버튼
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

                    // Title
                    Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 입력 폼 필드들
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

                    // 회원가입 버튼
                    CustomButton(
                      text: '회원가입',
                      onPressed: () {
                        print('회원가입 시도: ${_emailController.text}');
                      },
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
