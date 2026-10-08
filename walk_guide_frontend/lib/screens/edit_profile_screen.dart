// lib/screens/edit_profile_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 (지우지 말 것) ──
// 1. PATCH api/pets/:pet_id/ 는 name, breed, birth_date, profile_image,
//    personalities(form-data)를 받는데, 이 화면엔 "나이(숫자)"만 있고
//    breed/birth_date/profile_image 입력 필드가 없음.
//    - 나이(숫자) -> birth_date로 어떻게 변환할지 확인 필요
//      (예: DateTime(현재 연도 - 나이, 1, 1) 같은 방식으로 대략 계산해도 되는지)
//    - breed/profile_image는 이 화면에서 안 바꾸는 거라면, 기존 값을 어디서
//      가져와서 그대로 재전송해야 하는지 확인 필요
//    -> 위 내용이 확정되기 전까지 _handleSave()의 실제 API 호출 부분은
//       TODO로 비워두고 우선 화면만 완성함.
// 2. personalities의 정확한 영문 키 값. 응답 예시에서 "energy"(에너지형)만
//    확인됨. 나머지 5개(social/coward/curious/relaxed/calm)는 추측이라
//    실제 값 확인 필요 -> _personalityApiKey 맵 참고.
// 3. 성향 아이콘은 widgets/personality_tag.dart에 이미 있는 매핑을 재사용하고
//    싶었으나 파일 내용을 못 받아서 임의 Material 아이콘으로 대체함.
//    personality_tag.dart 공유되면 아이콘 통일할 것.
// 4. "선택됨" 상태 디자인이 피그마 스펙에 없어서, 앱의 다른 선택 UI(탭 선택 시
//    초록 강조)와 비슷하게 임의로 추가함 (테두리 27722F + 연한 초록 배경).

import 'package:flutter/material.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kNeutralGrayKhaki = Color(0xFFA9AA80);
const Color _kAccentGreen = Color(0xFF27722F);

/// 성향 한글 라벨 -> 화면에 쓸 아이콘 + (추정) API 키
class _PersonalityOption {
  final String label;
  final IconData icon;
  final String apiKey; // TODO(backend): energy 외 나머지는 추정값, 확인 필요

  const _PersonalityOption(this.label, this.icon, this.apiKey);
}

// NOTE: 아이콘/크기는 widgets/personality_tag.dart와 동일하게 맞춤
// (에너지형16, 사회성형15, 겁쟁이형13, 호기심형14, 느긋형12, 얌전형14)
class _PersonalityOptionWithSize extends _PersonalityOption {
  final double iconSize;
  const _PersonalityOptionWithSize(
    super.label,
    super.icon,
    super.apiKey,
    this.iconSize,
  );
}

const List<_PersonalityOptionWithSize> _row1Options = [
  _PersonalityOptionWithSize('에너지형', Icons.bolt, 'energy', 16),
  _PersonalityOptionWithSize('사회성형', Icons.groups, 'social', 15),
  _PersonalityOptionWithSize('겁쟁이형', Icons.shield_outlined, 'coward', 13),
];

const List<_PersonalityOptionWithSize> _row2Options = [
  _PersonalityOptionWithSize('호기심형', Icons.search, 'curious', 14),
  _PersonalityOptionWithSize('느긋형', Icons.dark_mode_outlined, 'relaxed', 12),
  _PersonalityOptionWithSize('얌전형', Icons.local_florist, 'calm', 14),
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();

  int _age = 1;
  final Set<String> _selectedPersonalities = {};

  @override
  void dispose() {
    _ownerNameController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  void _togglePersonality(String apiKey) {
    setState(() {
      if (_selectedPersonalities.contains(apiKey)) {
        _selectedPersonalities.remove(apiKey);
      } else {
        _selectedPersonalities.add(apiKey);
      }
    });
  }

  void _incrementAge() => setState(() => _age++);

  void _decrementAge() {
    if (_age <= 0) return;
    setState(() => _age--);
  }

  Future<void> _handleSave() async {
    // TODO(backend): 아래 두 호출을 실제 API로 교체할 것.
    // 1) PATCH api/users/:user_id/  body: { "nickname": _ownerNameController.text }
    // 2) PATCH api/pets/:pet_id/    body(form-data): {
    //      name: _petNameController.text,
    //      breed: ???,        // 이 화면에서 안 바꾸는 값 -> 기존 값 재전송 필요
    //      birth_date: ???,   // _age를 어떻게 변환할지 확인 필요
    //      personalities: _selectedPersonalities.toList(),
    //    }
    // 지금은 저장 흐름만 보여주기 위해 스낵바만 띄움.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장 로직은 API 스펙 확정 후 연결 예정이에요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── 뒤로가기 + "내 정보 수정" 타이틀 (설정 화면들과 스타일 통일) ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 24,
                        color: _kOliveText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '내 정보 수정',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        height: 1.1,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ── 반려인 이름 ──
                _buildFieldLabel('반려인 이름'),
                const SizedBox(height: 9),
                _buildTextInput(
                  controller: _ownerNameController,
                  hint: '이름을 입력해 주세요',
                ),

                const SizedBox(height: 15),

                // ── 반려견 이름 ──
                _buildFieldLabel('반려견 이름'),
                const SizedBox(height: 9),
                _buildTextInput(
                  controller: _petNameController,
                  hint: '이름을 입력해 주세요',
                ),

                const SizedBox(height: 15),

                // ── 나이 ──
                _buildFieldLabel('나이'),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Container(
                      width: 224,
                      height: 49,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kAccentGreen, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_age',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              height: 1.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '살',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 1.0,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 19),
                    _buildAgeStepButton('-', _decrementAge),
                    const SizedBox(width: 9),
                    _buildAgeStepButton('+', _incrementAge),
                  ],
                ),

                const SizedBox(height: 15),

                // ── 반려견 성향 ──
                _buildFieldLabel('반려견 성향'),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final option in [..._row1Options, ..._row2Options])
                      _PersonalityChip(
                        option: option,
                        isSelected: _selectedPersonalities.contains(option.apiKey),
                        onTap: () => _togglePersonality(option.apiKey),
                      ),
                  ],
                ),

                const SizedBox(height: 45),

                // ── 저장하기 버튼 ──
                GestureDetector(
                  onTap: _handleSave,
                  child: Container(
                    width: double.infinity,
                    height: 49,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kAccentGreen,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _kAccentGreen, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(3, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      '저장하기',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
        fontSize: 12,
        height: 1.0,
        color: _kOliveText.withOpacity(0.8),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kAccentGreen, width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildAgeStepButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFECE8E2),
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            color: _kOliveText,
          ),
        ),
      ),
    );
  }
}

/// 성향 선택 칩 (아이콘 + 라벨, 알약 모양)
class _PersonalityChip extends StatelessWidget {
  final _PersonalityOptionWithSize option;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonalityChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? _kAccentGreen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? _kAccentGreen : _kNeutralGrayKhaki,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: option.iconSize,
              color: isSelected ? _kAccentGreen : Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              option.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.0,
                color: isSelected ? _kAccentGreen : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}