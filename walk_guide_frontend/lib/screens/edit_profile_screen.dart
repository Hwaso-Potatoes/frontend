// lib/screens/edit_profile_screen.dart

// Edits the shared user/pet snapshot with documented partial PATCH fields.

import 'package:flutter/material.dart';
import '../services/active_pet_store.dart';
import '../models/active_pet_model.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kNeutralGrayKhaki = Color(0xFFA9AA80);
const Color _kAccentGreen = Color(0xFF27722F);

/// 성향 한글 라벨 -> 화면 아이콘 및 명세에 정의된 API 키
class _PersonalityOption {
  final String label;
  final IconData icon;
  final String apiKey;

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
  _PersonalityOptionWithSize('겁쟁이형', Icons.shield_outlined, 'timid', 13),
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
  final _ownerNameController = TextEditingController();
  final _petNameController = TextEditingController();
  final Set<String> _selectedPersonalities = {};
  DateTime? _birthDate;
  bool _ready = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ActivePetStore.instance.ensureLoaded();
    if (!mounted) return;
    final state = ActivePetStore.instance;
    if (state.pet == null) {
      setState(() => _ready = false);
      return;
    }
    _ownerNameController.text = state.user['nickname']?.toString() ?? '';
    _petNameController.text = state.pet!.name;
    _birthDate = state.pet!.birthDate;
    _selectedPersonalities.addAll(state.pet!.personalities);
    setState(() => _ready = true);
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate != null && _birthDate!.year >= 1900
          ? _birthDate
          : today,
      firstDate: DateTime(1900),
      lastDate: today,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _kAccentGreen),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) setState(() => _birthDate = selected);
  }

  Future<void> _handleSave() async {
    final owner = _ownerNameController.text.trim(),
        name = _petNameController.text.trim();
    String? validation;
    if (owner.isEmpty || owner.length > 8)
      validation = '반려인 이름은 1~8자로 입력해주세요.';
    else if (name.isEmpty || name.length > 30)
      validation = '반려견 이름은 1~30자로 입력해주세요.';
    else if (_birthDate == null)
      validation = '생년월일을 선택해주세요.';
    if (validation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }
    try {
      await ActivePetStore.instance.saveProfile(
        nickname: owner,
        name: name,
        birthDate: _birthDate!,
        personalities: _selectedPersonalities.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _kOliveText,
      ),
    ),
  );
  Widget _input(TextEditingController controller, int max) => TextField(
    controller: controller,
    enabled: !ActivePetStore.instance.saving,
    maxLength: max,
    decoration: InputDecoration(
      counterText: '',
      hintText: '이름을 입력해 주세요',
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _kAccentGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _kAccentGreen, width: 2),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ActivePetStore.instance,
    builder: (context, _) {
      final state = ActivePetStore.instance;
      return Scaffold(
        backgroundColor: _kBgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!_ready)
                return Center(
                  child: state.loading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.error ?? '정보를 불러오지 못했습니다.'),
                            TextButton(
                              onPressed: () async {
                                await state.refresh();
                                await _load();
                              },
                              child: const Text('다시 조회'),
                            ),
                          ],
                        ),
                );
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: _kOliveText,
                                  size: 24,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  '내 정보 수정',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          _label('반려인 이름'),
                          _input(_ownerNameController, 8),
                          const SizedBox(height: 15),
                          _label('반려견 이름'),
                          _input(_petNameController, 30),
                          const SizedBox(height: 15),
                          _label('생년월일'),
                          OutlinedButton(
                            onPressed: state.saving ? null : _selectBirthDate,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: _kAccentGreen),
                              minimumSize: const Size(double.infinity, 49),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              _birthDate == null
                                  ? '생년월일을 선택해 주세요'
                                  : apiDate(_birthDate!).replaceAll('-', ' . '),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _label('반려견 성향'),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (final option in [
                                ..._row1Options,
                                ..._row2Options,
                              ])
                                _PersonalityChip(
                                  option: option,
                                  isSelected: _selectedPersonalities.contains(
                                    option.apiKey,
                                  ),
                                  onTap: () {
                                    if (state.saving) return;
                                    setState(() {
                                      if (!_selectedPersonalities.add(
                                        option.apiKey,
                                      ))
                                        _selectedPersonalities.remove(
                                          option.apiKey,
                                        );
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 45),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: state.saving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kAccentGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 49),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              state.saving ? '저장 중...' : '저장하기',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
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
