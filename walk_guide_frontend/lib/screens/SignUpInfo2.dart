import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 💡 kIsWeb(웹 환경 체크)을 사용하기 위해 추가되었습니다.
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignUpInfo3.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);

class SignUpInfo2 extends StatefulWidget {
  final String userId;
  final String nickname;
  final String accessToken;

  const SignUpInfo2({
    super.key,
    required this.userId,
    required this.nickname,
    required this.accessToken,
  });

  @override
  State<SignUpInfo2> createState() => _SignUpInfo2State();
}

class _SignUpInfo2State extends State<SignUpInfo2> {
  final TextEditingController _petNameController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;
  String? _selectedBreed;
  DateTime _selectedDate = DateTime.now();

  final List<String> _dogBreeds = [
    '슈나우저',
    '이탈리안 그레이하운드',
    '시바견',
    '비글',
    '웰시코기',
    '비숑',
    '사모예드',
    '푸들',
    '골든 리트리버',
    '포메라니안',
    '프렌치 불독',
    '치와와',
    '퍼그',
    '말티즈',
    '닥스훈트',
    '시베리안 허스키',
    '도베르만',
    '시추',
  ];

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
    }
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

    if (petName.isEmpty) {
      showCustomDialog(
        context: context,
        title: '안내',
        message: '강아지 이름을 입력해주세요.',
      );
      return;
    }

    if (_selectedBreed == null) {
      showCustomDialog(context: context, title: '안내', message: '견종을 선택해주세요.');
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
          breed: _selectedBreed ?? '미정',
          birthDate: birthDate,
          profileImage: _profileImagePath,
          accessToken: widget.accessToken,
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
            Expanded(
              child: SingleChildScrollView(
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
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
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
                                // 💡 변경점: 웹(Chrome)과 앱을 분리하여 이미지를 다르게 불러옵니다.
                                child: _profileImagePath != null
                                    ? ClipOval(
                                        child: kIsWeb
                                            ? Image.network(
                                                _profileImagePath!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              )
                                            : Image.file(
                                                File(_profileImagePath!),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  padding: const EdgeInsets.all(6),
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
                      ),
                      const SizedBox(height: 24),
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
                      const Text(
                        '견종 선택',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xCC636037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            color: const Color(0xFFC8E6C9),
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBreed,
                            hint: const Text(
                              '견종을 선택해주세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black38,
                            ),
                            items: _dogBreeds.map((String breed) {
                              return DropdownMenuItem<String>(
                                value: breed,
                                child: Text(
                                  breed,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedBreed = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
