// lib/screens/settings_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. 알림 설정 조회/저장 엔드포인트 확인 필요 (아직 안 받음)
// 2. SNS 계정 연동/해제(Google/Apple/Kakao) 엔드포인트 확인 필요 (아직 안 받음)
// 3. 회원탈퇴 엔드포인트 없음 -> 지금은 버튼 탭해도 아무 동작 안 함 (TODO 표시)
// 4. 로그아웃 성공 후 로그인 화면으로 이동할 때, 그 이전 화면 스택을 전부
//    지워야 하므로 pushAndRemoveUntil 사용함. login.dart의 위젯 이름/경로가
//    바뀌면 이 파일의 import와 아래쪽 네비게이션 코드도 같이 고쳐야 함.

import 'package:flutter/material.dart';
import 'login.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'account_settings_screen.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kNeutralGrayKhaki = Color(0xFFA9AA80);

/// POST api/users/logout/ 를 흉내낸 mock.
/// TODO(backend): 실제 HTTP 호출로 교체할 것.
Future<void> mockLogout() async {
  await Future.delayed(const Duration(milliseconds: 200));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _onLogoutConfirmed() async {
    // TODO(backend): mockLogout() -> 실제 POST api/users/logout/ 호출로 교체
    await mockLogout();

    if (!mounted) return;

    // 로그아웃 성공 -> 이전 화면 스택 전부 지우고 로그인 화면으로 이동
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => _LogoutConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop(); // 모달 닫기
          _onLogoutConfirmed();
        },
      ),
    );
  }

  void _onWithdrawTap() {
    // TODO(backend): 회원탈퇴 엔드포인트가 아직 없어서 아무 동작 안 함.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원탈퇴 기능은 아직 준비 중이에요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 뒤로가기 + "설정" 타이틀 (다른 화면들과 스타일 통일) ──
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
                    '설정',
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

              const SizedBox(height: 36),

              // ── 메뉴 리스트 ──
              _SettingsMenuItem(
                label: '내 정보 수정',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _SettingsMenuItem(
                label: '알림 설정',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _SettingsMenuItem(
                label: '환경설정',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                ),
              ),
              _buildDivider(),
              _SettingsMenuItem(
                label: '로그아웃',
                onTap: _showLogoutDialog,
              ),

              const Spacer(),

              // ── 회원탈퇴 ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: _onWithdrawTap,
                    child: Text(
                      '회원탈퇴',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: _kNeutralGrayKhaki.withOpacity(0.5),
    );
  }
}

/// 설정 메뉴 한 줄 (텍스트 + 오른쪽 화살표), 높이 44
class _SettingsMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SettingsMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.1,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: _kOliveText.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로그아웃 확인 모달
class _LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 43),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 초록 원 + 느낌표 ──
            Container(
              width: 77,
              height: 77,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFAAD480),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '로그아웃',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 20,
                height: 1.1,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그아웃 하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.0,
                color: _kOliveText.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 16),

            // ── 아니요 / 예 버튼 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 37,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _kNeutralGrayKhaki,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '아니요',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 1.0,
                          color: Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 37,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27722F),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(3, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        '예',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}