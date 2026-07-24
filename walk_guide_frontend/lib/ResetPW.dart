import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 파동 이미지
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

          // 2. 나무 이미지
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
                      'Password',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 입력 폼 필드들
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

                    // 비밀번호 재설정 버튼
                    CustomButton(
                      text: '비밀번호 재설정',
                      onPressed: () {
                        print('비밀번호 재설정 시도');
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
