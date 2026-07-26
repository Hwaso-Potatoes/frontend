import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';
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
      MaterialPageRoute(
        builder: (context) =>
            SignUpInfo2(userId: widget.userId, nickname: nickname),
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

            // 2. 상단바 ~ 진행바 사이의 여백
            const SizedBox(height: 30),

            // 3. 본문 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 진행 바
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor: const Color(0xFFEAE7DE),
                          color: Color(0xFF72AA4F),
                          minHeight: 10, // 진행바 두께
                        ),
                      ),
                    ),

                    // 진행바 ~ 타이틀 간격
                    const SizedBox(height: 30),

                    // 타이틀
                    Text(
                      '성함을 알려주세요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: Colors.black,
                      ),
                    ),

                    // 타이틀 ~ 입력창 간격
                    const SizedBox(height: 24),

                    // 입력창
                    CustomTextField(
                      controller: _nicknameController,
                      hintText: '이름을 입력해 주세요',
                    ),

                    // 입력창 ~ 안내문구 간격
                    const SizedBox(height: 12),

                    // 안내 문구
                    const Text(
                      '나중에 프로필 설정에서 바꿀 수 있어요',
                      style: TextStyle(fontSize: 12, color: Color(0xFF817F5A)),
                    ),

                    // 버튼을 화면 하단으로 밀어주는 역할
                    const Spacer(),

                    // 다음 버튼
                    CustomButton(text: '다음으로', onPressed: _nextStep),

                    // 하단 여백
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
