// lib/screens/notification_settings_screen.dart

// ── 백엔드 연결 시 확인/요청해야 할 것 ──
// 1. 알림 설정 조회/저장 엔드포인트가 아직 없음. 지금은 화면 안에서만
//    로컬 state로 토글이 동작하고, 새로고침하면 초기값으로 돌아감.
//    엔드포인트 생기면 initState에서 GET으로 초기값 불러오고,
//    각 토글 onChanged에서 PATCH로 저장하도록 교체할 것.
// 2. "전체 알림 허용"을 껐을 때 개별 설정들(활동/소셜/마케팅 알림)의 값 자체가
//    서버에 저장이 되는지, 아니면 그냥 화면에서 숨기기만 하고 값은 유지하는
//    건지 확인 필요. 지금은 후자로 구현함 (꺼도 개별 값은 메모리에 유지,
//    다시 켜면 이전 상태 그대로 보임).

import 'package:flutter/material.dart';

const Color _kBgColor = Color(0xFFF8F9E5);
const Color _kOliveText = Color(0xFF636037);
const Color _kNeutralGrayKhaki = Color(0xFFA9AA80);
const Color _kAccentGreen = Color(0xFF27722F);
const Color _kToggleOn = Color(0xFFAAD480);
const Color _kToggleOff = Color(0xFFB3B49F);

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allEnabled = true;

  // 활동 알림
  bool _walkReminder = true;
  bool _walkReport = true;
  bool _levelUpBadge = true;
  bool _accessoryBoxArrival = false;

  // 소셜 알림
  bool _friendWalkActivity = true;
  bool _locationSharing = false;

  // 마케팅 알림
  bool _eventBenefit = true;

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

                // ── 뒤로가기 + "알림 설정" 타이틀 ──
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
                      '알림 설정',
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

                const SizedBox(height: 23),

                // ── 전체 알림 허용 ──
                _NotificationCard(
                  children: [
                    _NotificationRow(
                      title: '전체 알림 허용',
                      value: _allEnabled,
                      onChanged: (v) => setState(() => _allEnabled = v),
                    ),
                  ],
                ),

                // ── 전체 알림이 꺼지면 아래 섹션들은 전부 숨김 ──
                if (_allEnabled) ...[
                  const SizedBox(height: 23),
                  _buildSectionLabel('활동 알림'),
                  const SizedBox(height: 10),
                  _NotificationCard(
                    children: [
                      _NotificationRow(
                        title: '산책 리마인더',
                        subtitle: '매일 오후 6:00',
                        value: _walkReminder,
                        onChanged: (v) => setState(() => _walkReminder = v),
                      ),
                      _buildDivider(),
                      _NotificationRow(
                        title: '산책리포트',
                        subtitle: '주간, 월간 요약 도착 시',
                        value: _walkReport,
                        onChanged: (v) => setState(() => _walkReport = v),
                      ),
                      _buildDivider(),
                      _NotificationRow(
                        title: '레벨업 & 뱃지 알림',
                        value: _levelUpBadge,
                        onChanged: (v) => setState(() => _levelUpBadge = v),
                      ),
                      _buildDivider(),
                      _NotificationRow(
                        title: '악세서리 상자 도착 알림',
                        value: _accessoryBoxArrival,
                        onChanged: (v) =>
                            setState(() => _accessoryBoxArrival = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 23),
                  _buildSectionLabel('소셜 알림'),
                  const SizedBox(height: 10),
                  _NotificationCard(
                    children: [
                      _NotificationRow(
                        title: '친구의 산책 활동',
                        value: _friendWalkActivity,
                        onChanged: (v) =>
                            setState(() => _friendWalkActivity = v),
                      ),
                      _buildDivider(),
                      _NotificationRow(
                        title: '산책 시 위치 공유',
                        value: _locationSharing,
                        onChanged: (v) => setState(() => _locationSharing = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  _buildSectionLabel('마케팅 알림'),
                  const SizedBox(height: 10),
                  _NotificationCard(
                    children: [
                      _NotificationRow(
                        title: '이벤트 및 혜택 알림',
                        subtitle: '광고성 정보 수신 동의',
                        value: _eventBenefit,
                        onChanged: (v) => setState(() => _eventBenefit = v),
                      ),
                    ],
                  ),
                ],

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
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
        fontSize: 12,
        height: 1.0,
        color: _kOliveText,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: _kNeutralGrayKhaki.withOpacity(0.5),
      indent: 0,
      endIndent: 0,
    );
  }
}

/// 알림 설정 카드 (흰 배경 + 초록 테두리, radius15)
class _NotificationCard extends StatelessWidget {
  final List<Widget> children;

  const _NotificationCard({required this.children});

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

/// 알림 설정 한 줄 (제목 + 선택적 설명 + 토글)
class _NotificationRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _NotificationToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 커스텀 토글 스위치 (46x25, radius14, 초록/회색 + 흰 원)
class _NotificationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({required this.value, required this.onChanged});

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