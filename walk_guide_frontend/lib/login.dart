import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart'; // 공통 위젯 임포트
import 'package:google_fonts/google_fonts.dart';
import 'SignUp.dart';
import 'ResetPW.dart';

void main() {
  runApp(const WalkGuideApp());
}

const Color primaryGreen = Color(0xFF27722F);

class WalkGuideApp extends StatelessWidget {
  const WalkGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walk Guide',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9E5),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9E5),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 파동 이미지 (top: 415 -> 400으로 15px 위로 이동)
          Positioned(
            top: 400,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/background1.png',
              fit: BoxFit.fill,
            ),
          ),

          // 2. 나무 이미지 (top: 290 -> 275로 15px 위로 이동)
          Positioned(
            top: 275,
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
                    // 상단 여백 (125 -> 110으로 15px 줄임)
                    const SizedBox(height: 110),

                    // 메인 로고 이미지
                    Center(
                      child: Image.asset(
                        'assets/images/Walk_Guide_text.png',
                        height: 176,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 1),

                    // 메인 서브 타이틀
                    const Center(
                      child: Text(
                        '매일 산책이, 우리 아이의 진화가 되는 순간',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),

                    // Login 서브 타이틀
                    Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. 이메일 입력창
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // 5. 비밀번호 입력창
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    // 6. 로그인 버튼
                    CustomButton(
                      text: '로그인',
                      onPressed: () {
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        print('로그인 버튼 클릭 - 이메일: $email, 비밀번호: $password');
                      },
                    ),
                    const SizedBox(height: 13),

                    // 7. 비밀번호 재설정 / 회원가입 링크
                    // 비밀번호 재설정 / 회원가입 링크 부분
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResetPW(),
                              ),
                            );
                          },
                          child: const Text(
                            '비밀번호 재설정',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '·',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.5),

                    // 8. 구분선
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Colors.black26)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            '또는 소셜 계정으로 시작',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.black26)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 9. 소셜 로그인 이미지 아이콘 그룹
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => print('구글 로그인'),
                          child: Image.asset(
                            'assets/images/google.png',
                            width: 46,
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => print('애플 로그인'),
                          child: Image.asset(
                            'assets/images/apple.png',
                            width: 46,
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => print('카카오 로그인'),
                          child: Image.asset(
                            'assets/images/kakao.png',
                            width: 46,
                            height: 46,
                          ),
                        ),
                      ],
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
