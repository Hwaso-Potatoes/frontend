import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';
import 'SignUpInfo2.dart';

const Color backgroundColor = Color(0xFFF7F8E9);
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/Walk_Guide_text2.png',
          width: 259,
          height: 35,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 여백 (높이 조절 가능)
              const SizedBox(height: 24),

              // 2. 진행 바
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.33,
                  minHeight: 8,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                ),
              ),

              // 진행바 ~ 타이틀 간격
              const SizedBox(height: 36),

              // 3. 타이틀
              const Text(
                '성함을 알려주세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // 타이틀 ~ 입력창 간격
              const SizedBox(height: 24),

              // 4. 입력창
              CustomTextField(
                controller: _nicknameController,
                hintText: '이름을 입력해 주세요',
              ),

              // 입력창 ~ 안내문구 간격
              const SizedBox(height: 12),

              // 5. 안내 문구
              const Text(
                '나중에 프로필 설정에서 바꿀 수 있어요',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),

              // 버튼을 화면 하단으로 밀어주는 역할
              const Spacer(),

              // 6. 다음 버튼
              CustomButton(text: '다음으로', onPressed: _nextStep),

              // 하단 여백
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
