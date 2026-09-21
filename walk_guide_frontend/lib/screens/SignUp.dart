import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
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
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isRequestingCode = false;

  bool _isCodeSent = false;
  bool _isCodeVerified = false;

  // 백엔드로부터 발급받은 인증 프리패스 토큰을 저장할 변수
  String _verificationToken = "";

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showStyledDialog(String title, String subtitle) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 45.0,
                    bottom: 35.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA5D179),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '!',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A7955),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 26,
                      color: Color(0xFF7A7955),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleRequestAuthCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showStyledDialog('입력 오류', '이메일을 입력해주세요.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showStyledDialog('입력 오류', '올바른 이메일 형식이 아닙니다.');
      return;
    }

    setState(() => _isRequestingCode = true);

    try {
      final result = await ApiService.requestEmailVerification(email);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _isRequestingCode = false;
          _isCodeSent = true;
        });
      } else {
        setState(() => _isRequestingCode = false);
        _showStyledDialog('오류', '인증번호 발송에 실패했습니다.');
      }
    } catch (e) {
      setState(() => _isRequestingCode = false);
      if (!mounted) return;
      _showStyledDialog('오류', '서버와의 통신 중\n오류가 발생했습니다.');
    }
  }

  Future<void> _handleVerifyAuthCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showStyledDialog('입력 오류', '인증번호를 입력해주세요.');
      return;
    }

    setState(() => _isRequestingCode = true);

    try {
      final result = await ApiService.verifyEmailCode(email, code);
      if (!mounted) return;

      setState(() => _isRequestingCode = false);

      if (result['success'] == true && result['verification_token'] != null) {
        setState(() {
          _isCodeVerified = true;
          _verificationToken = result['verification_token'];
        });
        _showStyledDialog('인증 성공', '인증번호가 확인되었습니다.');
      } else {
        _showStyledDialog('인증번호 불일치', '인증번호가 올바르지 않습니다.');
      }
    } catch (e) {
      setState(() => _isRequestingCode = false);
      if (!mounted) return;
      _showStyledDialog('오류', '인증 확인 중\n오류가 발생했습니다.');
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showStyledDialog('입력 오류', '모든 필드를 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      _showStyledDialog('입력 오류', '비밀번호는 최소 6자리\n이상이어야 합니다.');
      return;
    }

    if (password != confirmPassword) {
      _showStyledDialog('비밀번호가\n일치하지 않습니다', '다시 입력해주시겠어요');
      return;
    }

    if (!_isCodeVerified || _verificationToken.isEmpty) {
      _showStyledDialog('인증 필요', '이메일 인증을 먼저 완료해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. 회원가입 API 호출
      final signUpResult = await ApiService.signUp(
        email,
        password,
        confirmPassword,
        _verificationToken,
      );

      if (signUpResult['success'] == true) {
        setState(() => _isLoading = false);

        if (!mounted) return;

        final String userId =
            signUpResult['id']?.toString() ?? '1';

        final String accessToken =
            signUpResult['access'] ?? '';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpInfo1(
              userId: userId,
              accessToken: accessToken,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showStyledDialog('오류', '서버와의 통신 중\n오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPasswordMismatch =
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text;

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
                    const SizedBox(height: 30),
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
                    if (isPasswordMismatch)
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0, left: 6.0),
                        child: Text(
                          '* 비밀번호가 일치하지 않습니다.',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _codeController,
                            hintText: 'Enter code',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 118,
                          child: _isRequestingCode
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryGreen,
                                  ),
                                )
                              : CustomButton(
                                  text: _isCodeVerified
                                      ? '인증 완료'
                                      : (_isCodeSent ? '인증번호 확인' : '인증번호 받기'),
                                  backgroundColor: _isCodeVerified
                                      ? Colors.grey
                                      : primaryGreen,
                                  onPressed: _isCodeVerified
                                      ? () {}
                                      : (_isCodeSent
                                            ? _handleVerifyAuthCode
                                            : _handleRequestAuthCode),
                                  fontSize: 12.0,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(text: '회원가입', onPressed: _handleSignUp),
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
