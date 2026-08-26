import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignUpInfo3.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
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

  DateTime _selectedDate = DateTime.now();
  String? _profileImagePath;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

    final String year = _selectedDate.year.toString();
    final String month = _selectedDate.month.toString().padLeft(2, '0');
    final String day = _selectedDate.day.toString().padLeft(2, '0');
    final birthDate = '$year-$month-$day';

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignUpInfo3(
          userId: widget.userId,
          nickname: widget.nickname,
          petName: petName,
          breed: breed.isEmpty ? '미정' : breed,
          birthDate: birthDate,
          profileImage: _profileImagePath,
        ),
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
    final String formattedDateDisplay =
        "${_selectedDate.year} . ${_selectedDate.month.toString().padLeft(2, '0')} . ${_selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단바
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 진행 바 (0.33 -> 0.66)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(begin: 0.33, end: 0.66),
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
                        '함께 떠날 강아지는\n누구인가요?',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 프로필 사진 등록
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

                      const SizedBox(height: 24),

                      // 강아지 이름
                      const Text(
                        '강아지 이름',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xCC636037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _petNameController,
                        hintText: '이름을 입력해 주세요',
                      ),

                      const SizedBox(height: 16),

                      // 견종 선택
                      const Text(
                        '견종 선택',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xCC636037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _breedController,
                        hintText: '견종을 검색해주세요',
                      ),

                      const SizedBox(height: 16),

                      // 생년월일
                      const Text(
                        '생년월일',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xCC636037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: const Color(0xFFC8E6C9),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDateDisplay,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        '정확한 정보를 입력해주시면 강아지의 연령과 체력에 맞는 맞춤형 산책 코스를 추천해드려요',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: -0.3,
                          color: Color(0xCC636037),
                        ),
                      ),

                      const SizedBox(height: 32),

                      CustomButton(text: '다음으로', onPressed: _nextStep),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
