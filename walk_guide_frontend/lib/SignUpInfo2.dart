import 'package:flutter/material.dart';
import 'widgets/custom_widgets.dart';
import 'SignUpInfo3.dart';

const Color backgroundColor = Color(0xFFF7F8E9);
const Color primaryGreen = Color(0xFF27722F);

class SignUpInfo2 extends StatefulWidget {
  final String userId;
  final String nickname;

  const SignUpInfo2({super.key, required this.userId, required this.nickname});

  @override
  State<SignUpInfo2> createState() => _SignUpInfo2State();
}

class _SignUpInfo2State extends State<SignUpInfo2> {
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  int _age = 1;
  String? _profileImagePath;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final petName = _petNameController.text.trim();
    final breed = _breedController.text.trim();

    if (petName.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '강아지 이름을 입력해주세요.',
      );
      return;
    }

    final birthYear = DateTime.now().year - _age;
    final birthDate = '$birthYear-01-01';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpInfo3(
          userId: widget.userId,
          nickname: widget.nickname,
          petName: petName,
          breed: breed.isEmpty ? '미정' : breed,
          birthDate: birthDate,
          profileImage: _profileImagePath,
        ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 상단 여백
                const SizedBox(height: 16),

                // 2. 진행 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.66,
                    minHeight: 8,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                ),

                // 진행바 ~ 타이틀 간격
                const SizedBox(height: 28),

                // 3. 타이틀
                const Text(
                  '함께 떠날 강아지는\n누구인가요?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),

                // 타이틀 ~ 프로필 사진 등록 영역 간격
                const SizedBox(height: 24),

                // 4. 프로필 사진 등록 영역
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFF3C8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '사진 등록',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 프로필 사진 ~ '강아지 이름' 라벨 간격
                const SizedBox(height: 24),

                // 5. 강아지 이름 라벨 및 입력창
                const Text(
                  '강아지 이름',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _petNameController,
                  hintText: '이름을 입력해 주세요',
                ),

                // 입력창 사이 간격
                const SizedBox(height: 16),

                // 6. 견종 선택 라벨 및 입력창
                const Text(
                  '견종 선택',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _breedController,
                  hintText: '견종을 검색해주세요',
                ),

                // 입력창 사이 간격
                const SizedBox(height: 16),

                // 7. 나이 라벨 및 증감 버튼 Row
                const Text(
                  '나이',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Center(
                          child: Text(
                            '$_age  살',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (_age > 0) setState(() => _age--);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _age++),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ],
                ),

                // 나이 선택 ~ 설명 문구 간격
                const SizedBox(height: 12),

                // 8. 추가 안내 문구
                const Text(
                  '정확한 정보를 입력해주시면 강아지의 연령과 체력에 맞는 맞춤형 산책 코스를 추천해드려요',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),

                // 설명 문구 ~ 다음 버튼 간격
                const SizedBox(height: 32),

                // 9. 다음 버튼
                CustomButton(text: '다음으로', onPressed: _nextStep),

                // 하단 여백
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
