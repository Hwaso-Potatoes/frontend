// lib/widgets/mission_card.dart

import 'package:flutter/material.dart';
import '../models/mission_model.dart';

/// 미션 목록 화면에서 미션 하나를 보여주는 카드
/// 완료 여부에 따라 왼쪽 상태 아이콘(체크 원 / 숫자 원)이 달라짐
class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onBoxOpenPressed;

  const MissionCard({
    super.key,
    required this.mission,
    this.onBoxOpenPressed,
  });

  /// "박스 열기" 버튼은 보상이 액세서리 박스이면서, 게이지가 100% 찼을 때만 보임
  bool get _showBoxOpenButton => mission.hasBoxReward && mission.progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFA9AA80).withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 제목 줄 ──
                // "제목+진행텍스트" 영역을 Expanded로 강제로 남는 공간 전부 차지하게 하고,
                // 버튼은 그 바깥(같은 Row의 마지막 자식)에 둠.
                // 이러면 화면이 아무리 넓어져도 버튼은 항상 이 Row의 맨 오른쪽 끝에 붙음
                // (Spacer만으로는 부모 쪽 너비 계산이 애매해질 수 있어서 더 확실한 방식으로 변경)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              mission.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                height: 1.1,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (mission.progressLabel != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              mission.progressLabel!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: const Color(0xFF636037).withOpacity(0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_showBoxOpenButton) ...[
                      const SizedBox(width: 8),
                      _buildBoxOpenButton(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mission.rewardText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: const Color(0xFF636037).withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 8),
                _buildProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 완료: 채워진 초록 원(AAD480) + 흰색 체크
  /// 미완료: 테두리만 있는 원(AAD480 outline) + 순번 숫자
  Widget _buildStatusIcon() {
    const double circleSize = 29;

    if (mission.isCompleted) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(
          color: Color(0xFFAAD480),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFAAD480), width: 3),
      ),
      child: Center(
        child: Text(
          '${mission.order}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// 흰색 배경 위에 초록색이 진행률만큼 채워지는 게이지 바
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: mission.progress.clamp(0.0, 1.0),
        minHeight: 10,
        backgroundColor: Colors.white,
        valueColor: const AlwaysStoppedAnimation(Color(0xFF72AA4F)),
      ),
    );
  }

  /// 보상이 "액세서리 박스"이고 게이지 100%일 때만 뜨는 버튼
  /// 배경/테두리 모두 27722F로 채워짐, 글씨만 밝은 색
  Widget _buildBoxOpenButton() {
    return GestureDetector(
      onTap: onBoxOpenPressed,
      child: Container(
        width: 58,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF27722F),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: const Color(0xFF27722F), width: 1),
        ),
        child: const Text(
          '박스 열기',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: Color(0xFFF8F9E5),
          ),
        ),
      ),
    );
  }
}