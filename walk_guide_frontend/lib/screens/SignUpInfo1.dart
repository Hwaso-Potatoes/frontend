import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignUpInfo2.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);

class SignUpInfo1 extends StatefulWidget {
  final String userId;

  const SignUpInfo1({super.key, required this.userId});

  @override
  State<SignUpInfo1> createState() => _SignUpInfo1State();
}

class _SignUpInfo1State extends State<SignUpInfo1> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      showCustomDialog(context: context, title: '안내', message: '성함을 입력해주세요.');
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SignUpInfo2(userId: widget.userId, nickname: nickname),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 커스텀 상단바
            Padding(
              padding: const EdgeInsets.only(top: 79.0),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(13, 0),
                      child: SizedBox(
                        height: 28,
                        child: SvgPicture.asset(
                          'assets/images/Walk_Guide2.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20.0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: primaryGreen,
                          size: 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. 본문 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 진행 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(begin: 0.0, end: 0.33),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: const Color(0xFFEAE7DE),
                            color: const Color(0xFF72AA4F),
                            minHeight: 10,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      '성함을 알려주세요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _nicknameController,
                      hintText: '이름을 입력해 주세요',
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      '나중에 프로필 설정에서 바꿀 수 있어요',
                      style: TextStyle(fontSize: 12, color: Color(0xFF817F5A)),
                    ),

                    const Spacer(),

                    CustomButton(text: '다음으로', onPressed: _nextStep),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
