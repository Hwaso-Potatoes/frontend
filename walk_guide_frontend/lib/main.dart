import 'package:flutter/material.dart';

void main() {
  runApp(const WalkGuideApp());
}

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

  final Color primaryGreen = const Color(0xFF27722F);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFF8F9E5),
            child: Stack(
              children: [
                // 1. 배경 파동 이미지
                Positioned(
                  top: 392,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/background1.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. 나무 이미지 (우측 정렬 기준 25px 적용)
                Positioned(
                  top: 277,
                  left: 269,
                  width: 119,
                  height: 147,
                  child: Image.asset(
                    'assets/images/trees.png',
                    fit: BoxFit.contain,
                  ),
                ),

                // 3. 메인 콘텐츠
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 125),

                      // 1. 메인 로고 이미지
                      Center(
                        child: Image.asset(
                          'assets/images/Walk_Guide_text.png',
                          height: 176,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 1),

                      // 2. 메인 서브 타이틀
                      Center(
                        child: Text(
                          '매일 산책이, 우리 아이의 진화가 되는 순간',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 94),

                      // 3. Login 서브 타이틀
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. 이메일 입력창
                      Center(
                        child: SizedBox(
                          width: 336,
                          height: 49,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: primaryGreen, width: 1),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'E-mail',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 5. 비밀번호 입력창
                      Center(
                        child: SizedBox(
                          width: 336,
                          height: 49,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: primaryGreen, width: 1),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. 로그인 버튼
                      Center(
                        child: SizedBox(
                          width: 336,
                          height: 49,
                          child: ElevatedButton(
                            onPressed: () {
                              final email = _emailController.text;
                              final password = _passwordController.text;
                              print('로그인 버튼 클릭 - 이메일: $email, 비밀번호: $password');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. 비밀번호 재설정 / 회원가입 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
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
                            onTap: () {},
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

                      const SizedBox(height: 28),

                      // 8. 구분선
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.black26)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '또는 소셜 계정으로 시작',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.black26)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 9. 소셜 로그인 아이콘 그룹
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            bgColor: Colors.white,
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _socialButton(
                            bgColor: Colors.black,
                            child: const Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 20),
                          _socialButton(
                            bgColor: const Color(0xFFFEE500),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required Color bgColor, required Widget child}) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(child: child),
    );
  }
}
