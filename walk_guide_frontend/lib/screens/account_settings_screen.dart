// lib/screens/account_settings_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. SNS 계정 연동/해제(Google/Apple/Kakao) 엔드포인트 확인 필요 (아직 안 받음)
// 2. 이메일/휴대폰 번호는 GET api/users/:user_id/ 응답에 없어서(닉네임만 옴)
//    실제로 어디서 이 값들을 가져오는지 확인 필요. 지금은 더미로 표시함.
// 3. 화살표(이메일 -> 이메일 변경 화면, 비밀번호 재설정 -> 비밀번호 재설정 화면)
//    네비게이션은 지금 임시 placeholder로 연결해뒀음. change_email_screen,
//    reset_password_screen 파일 완성되면 실제 화면으로 교체할 것.

import 'package:flutter/material.dart';
import '../widgets/slide_up_sheet_route.dart';
import 'change_email_screen.dart';
import 'reset_password_screen.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kAccentGreen = Color(0xFF27722F);
const Color _kToggleOn = Color(0xFFAAD480);
const Color _kToggleOff = Color(0xFFB3B49F);

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // TODO(backend): 실제로는 GET api/users/:user_id/ 등에서 받아와야 함
  final String _email = 'Tori@mail.com';
  final String _phoneNumber = '010-50**-68**';

  bool _googleLinked = true;
  bool _appleLinked = false;
  bool _kakaoLinked = false;


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

                // ── 뒤로가기 + "환경설정" 타이틀 ──
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
                      '환경설정',
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

                // ── 계정 ──
                _buildSectionLabel('계정'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _AccountRow(
                      title: '이메일',
                      trailingText: _email,
                      showChevron: true,
                      onTap: () => pushSlideUpSheet(
                        context,
                        (context) => const ChangeEmailScreen(),
                      ),
                    ),
                    _AccountRow(
                      title: '비밀번호 재설정',
                      showChevron: true,
                      onTap: () => pushSlideUpSheet(
                        context,
                        (context) => const ResetPasswordScreen(),
                      ),
                    ),
                    _AccountRow(
                      title: '휴대폰 번호',
                      trailingText: _phoneNumber,
                      showChevron: false,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── SNS 계정 연동 ──
                _buildSectionLabel('SNS 계정 연동'),
                const SizedBox(height: 11),
                _SettingsCard(
                  children: [
                    _SnsToggleRow(
                      title: 'Google',
                      value: _googleLinked,
                      onChanged: (v) => setState(() => _googleLinked = v),
                    ),
                    _SnsToggleRow(
                      title: 'Apple',
                      value: _appleLinked,
                      onChanged: (v) => setState(() => _appleLinked = v),
                    ),
                    _SnsToggleRow(
                      title: 'Kakao',
                      value: _kakaoLinked,
                      onChanged: (v) => setState(() => _kakaoLinked = v),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
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
}

/// 흰 배경 + 초록 테두리 카드 (환경설정 전용, 구분선 없이 행들을 쌓음)
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kAccentGreen, width: 1),
      ),
      child: Column(children: children),
    );
  }
}

/// 계정 정보 한 줄 (제목 + 선택적 보충 텍스트 + 선택적 화살표)
class _AccountRow extends StatelessWidget {
  final String title;
  final String? trailingText;
  final bool showChevron;
  final VoidCallback? onTap;

  const _AccountRow({
    required this.title,
    this.trailingText,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.0,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (trailingText != null)
              Text(
                trailingText!,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.0,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: _kOliveText.withOpacity(0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SNS 연동 한 줄 (제목 + 토글) - 알림 설정 화면의 토글과 동일한 스타일 재사용
class _SnsToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SnsToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.0,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          _AccountToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 커스텀 토글 스위치 (notification_settings_screen.dart와 동일 스타일)
class _AccountToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AccountToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: value ? _kToggleOn : _kToggleOff,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}