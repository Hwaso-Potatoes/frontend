// lib/screens/mission_screen.dart

import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/accessory_box_model.dart';
import '../widgets/mission_card.dart';
import 'accessory_box_screen.dart';

// 배경색 (다른 화면들과 통일)
const Color backgroundColor = Color(0xFFF8F9E5);

enum MissionTab { daily, weekly }

/// 미션 화면
/// 탭(일일/주간)에 따라 보여주는 리스트가 바뀌어야 해서 StatefulWidget 사용
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  MissionTab _selectedTab = MissionTab.daily;

  /// 박스 열기 버튼을 눌렀을 때 호출.
  /// TODO(backend): mockClaimMissionReward()를 실제 "미션 보상 수령" API 호출로 교체할 것.
  /// (엔드포인트 URL/HTTP method 확정되면 여기서 mission.id 등을 실어서 요청 보내야 함)
  Future<void> _handleBoxOpenPressed() async {
    final boxData = await mockClaimMissionReward();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccessoryBoxScreen(boxData: boxData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 지금은 더미 데이터, 나중에 서버 연결되면 API 응답으로 교체
    final List<MissionModel> missions =
        _selectedTab == MissionTab.daily ? dummyDailyMissions : dummyWeeklyMissions;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 뒤로가기 + "미션" 타이틀 (내 친구 화면과 스타일 통일) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: Color(0xFF636037),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '미션',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── 일일미션 / 주간미션 탭 ──
              Row(
                children: [
                  Expanded(child: _buildTabButton('일일 미션', MissionTab.daily)),
                  const SizedBox(width: 18),
                  Expanded(child: _buildTabButton('주간 미션', MissionTab.weekly)),
                ],
              ),

              const SizedBox(height: 27),

              // ── 미션 리스트 ──
              Expanded(
                child: ListView.separated(
                  itemCount: missions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 13),
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    return MissionCard(
                      mission: mission,
                      onBoxOpenPressed: _handleBoxOpenPressed,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 일일미션/주간미션 탭 버튼 (너비는 Expanded가 알아서 채움)
  Widget _buildTabButton(String label, MissionTab tab) {
    final bool isSelected = _selectedTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF27722F)
              : const Color(0xFFA9AA80).withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: isSelected
                ? const Color(0xFFF8F9E5)
                : Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}