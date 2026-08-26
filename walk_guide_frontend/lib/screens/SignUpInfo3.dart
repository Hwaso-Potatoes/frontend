import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
import 'main_shell.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);

class SignUpInfo3 extends StatefulWidget {
  final String userId;
  final String nickname;
  final String petName;
  final String breed;
  final String birthDate;
  final String? profileImage;

  const SignUpInfo3({
    super.key,
    required this.userId,
    required this.nickname,
    required this.petName,
    required this.breed,
    required this.birthDate,
    this.profileImage,
  });

  @override
  State<SignUpInfo3> createState() => _SignUpInfo3State();
}

class _SignUpInfo3State extends State<SignUpInfo3> {
  final Set<String> _selectedPersonalities = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _personalityOptions = [
    {'title': '에너지형', 'icon': Icons.bolt, 'color': const Color(0xFFEFF2C5)},
    {'title': '사회성형', 'icon': Icons.people, 'color': const Color(0xFFCDE5E7)},
    {
      'title': '겁쟁이형',
      'icon': Icons.shield_outlined,
      'color': const Color(0xFFF3D5DE),
    },
    {'title': '호기심형', 'icon': Icons.search, 'color': const Color(0xFFE2DEAC)},
    {
      'title': '느긋형',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFFC8E8D5),
    },
    {
      'title': '얌전형',
      'icon': Icons.local_florist,
      'color': const Color(0xFFE3E1DC),
    },
  ];

  Future<void> _submitData() async {
    setState(() => _isLoading = true);

    try {
      final userRes = await ApiService.updateUserProfile(
        widget.userId,
        widget.nickname,
      );

      final petRes = await ApiService.registerPet(
        userId: widget.userId,
        name: widget.petName,
        breed: widget.breed,
        birthDate: widget.birthDate,
        profileImage: widget.profileImage,
        personalities: _selectedPersonalities.toList(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (userRes['success'] == true && petRes['success'] == true) {
        // 성공 시 메인쉘(권한 팝업 옵션 활성화)로 전환
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainShellScreen(showPermissionDialog: true),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation.drive(
                      CurveTween(curve: Curves.easeInOut),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
          (route) => false,
        );
      } else {
        final errorMsg =
            userRes['message'] ?? petRes['message'] ?? '등록에 실패했습니다.';
        showCustomDialog(context: context, title: '오류', message: errorMsg);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showCustomDialog(
        context: context,
        title: '오류',
        message: '통신 중 오류가 발생했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 네비게이션 헤더
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

            // 본문 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(begin: 0.66, end: 1.0),
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

                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              '우리 아이는\n어떤 성격인가요?',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 17.0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _submitData,
                            child: const Text(
                              '건너뛰기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '맞춤형 활동을 추천해드리기 위해 필요해요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xC0636037),
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      '복수선택 가능',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xCC636037),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 성격 옵션 카드 그리드
                    Expanded(
                      child: GridView.builder(
                        itemCount: _personalityOptions.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.25,
                            ),
                        itemBuilder: (context, index) {
                          final item = _personalityOptions[index];
                          final String title = item['title'];
                          final isSelected = _selectedPersonalities.contains(
                            title,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedPersonalities.remove(title);
                                } else {
                                  _selectedPersonalities.add(title);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(color: primaryGreen, width: 2)
                                    : Border.all(
                                        color: Colors.transparent,
                                        width: 2,
                                      ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? primaryGreen
                                            : Colors.white54,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black26,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          item['icon'],
                                          size: 36,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          )
                        : CustomButton(text: '시작하기', onPressed: _submitData),

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
