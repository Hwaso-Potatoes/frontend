import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위해 추가
import 'package:google_sign_in/google_sign_in.dart';

//애플 패키지는 당장 사용하지 않으므로 임시 주석 처리
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
import 'SignUp.dart';
import 'SignUpInfo1.dart';
import 'FindPW.dart';
import 'main_shell.dart';

const Color primaryGreen = Color(0xFF27722F);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !_isValidEmail(email) || password.length < 6) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '올바른 이메일과 6자리 이상 비밀번호를 입력해주세요.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email, password);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainShellScreen()),
          (route) => false,
        );
      } else {
        await showCustomDialog(
          context: context,
          title: '로그인 실패',
          message: result['message'] ?? '정보를 확인해주세요.',
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

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    String? realSocialToken;

    try {
      if (provider == 'KAKAO') {
        if (kIsWeb) {
          final token = await kakao.UserApi.instance.loginWithKakaoAccount();
          realSocialToken = token.accessToken;
        } else {
          if (await kakao.isKakaoTalkInstalled()) {
            try {
              final token = await kakao.UserApi.instance.loginWithKakaoTalk();
              realSocialToken = token.accessToken;
            } catch (error) {
              final token = await kakao.UserApi.instance
                  .loginWithKakaoAccount();
              realSocialToken = token.accessToken;
            }
          } else {
            final token = await kakao.UserApi.instance.loginWithKakaoAccount();
            realSocialToken = token.accessToken;
          }
        }
      } else if (provider == 'GOOGLE') {
        /*final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: kIsWeb ? '여기에_웹_클라이언트_ID를_넣어야_합니다' : null,
        );

        try {
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

          if (googleUser != null) {
            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;
            realSocialToken = googleAuth.accessToken ?? 'mock_google_token';
          } else {
            setState(() => _isLoading = false);
            return;
          }
        } catch (error) {
          print('🚨 구글 로그인 에러: $error');
          setState(() => _isLoading = false);
          if (!mounted) return;
          showCustomDialog(
            context: context,
            title: '오류',
            message: '구글 로그인 중 오류가 발생했습니다.',
          );
          return;
        }*/
        setState(() => _isLoading = false);
        showCustomDialog(
          context: context,
          title: '안내',
          message: '구글 로그인은 준비 중입니다.',
        );
        return;
      } else if (provider == 'APPLE') {
        // 애플 로그인은 추후 도입을 위해 코드를 유지한 채 주석 처리합니다.
        /*
        try {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: kIsWeb
                ? WebAuthenticationOptions(
                    clientId: '여기에_애플_Service_ID를_넣어야_합니다',
                    redirectUri: Uri.parse('여기에_리다이렉트_URL을_넣어야_합니다'),
                  )
                : null,
          );

          realSocialToken = credential.identityToken;

          if (realSocialToken == null) {
            setState(() => _isLoading = false);
            return;
          }
        } catch (error) {
          print('🚨 애플 로그인 에러: $error');
          setState(() => _isLoading = false);
          if (!mounted) return;
          showCustomDialog(
            context: context,
            title: '오류',
            message: '애플 로그인 중 오류가 발생했습니다.',
          );
          return;
        }
        */

        setState(() => _isLoading = false);
        showCustomDialog(
          context: context,
          title: '안내',
          message: '애플 로그인은 준비 중입니다.',
        );
        return;
      }

      if (realSocialToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      final result = await ApiService.socialLogin(provider, realSocialToken);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        final bool isNewUser = result['is_new'] ?? false;
        final String accessToken = result['access'] ?? 'mock_token';
        final String userId = result['user_id']?.toString() ?? '1';

        if (isNewUser) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SignUpInfo1(userId: userId, accessToken: accessToken),
            ),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainShellScreen()),
            (route) => false,
          );
        }
      } else {
        showCustomDialog(
          context: context,
          title: '로그인 실패',
          message: result['message'] ?? '$provider 로그인에 실패했습니다.',
        );
      }
    } catch (e) {
      print('🚨🚨🚨 카카오 로그인 상세 에러 원인: $e 🚨🚨🚨');

      setState(() => _isLoading = false);
      if (!mounted) return;
      showCustomDialog(
        context: context,
        title: '오류',
        message: '소셜 로그인 진행 중 오류가 발생했습니다.',
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
            top: 400,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/background1.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 275,
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
                    const SizedBox(height: 110),
                    Center(
                      child: Image.asset(
                        'assets/images/Walk_Guide_text.png',
                        height: 176,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 1),
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
                    Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(text: '로그인', onPressed: _handleLogin),
                    const SizedBox(height: 13),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindPW(),
                            ),
                          ),
                          child: const Text(
                            '비밀번호 찾기',
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _handleSocialLogin('GOOGLE'),
                          child: Image.asset(
                            'assets/images/google.png',
                            width: 46,
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _handleSocialLogin('APPLE'),
                          child: Image.asset(
                            'assets/images/apple.png',
                            width: 46,
                            height: 46,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => _handleSocialLogin('KAKAO'),
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
