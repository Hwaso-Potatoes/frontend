// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../models/dog_model.dart';       // DogModel, dummyDog 가져오기
import '../widgets/icons/dog_icon.dart';       // DogIcon 위젯 가져오기
//import '../badge_book_screen.dart';
import '../widgets/personality_tag.dart';
import '../widgets/stat_card.dart';
import '../widgets/exp_bar.dart';
import '../widgets/badge_row.dart';
import '../widgets/walk_goal_card.dart'; // _buildWalkGoalCard 대신 공용 위젯 사용

// 배경색 (home.dart에서 쓰던 색이랑 통일)
const Color backgroundColor = Color(0xFFF8F9E5);

/// 프로필 화면
/// StatelessWidget = "화면 안에서 값이 바뀌지 않는(정적인) 화면"이라는 뜻
/// 나중에 서버에서 실시간 데이터 받아서 갱신해야 하면 StatefulWidget으로 바꿔야 함
/// (지금은 더미 데이터 하나만 보여줄 거라 Stateless로 충분)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 지금은 서버 연결 전이라 더미 데이터를 그대로 사용
    // 나중엔 이 자리에 실제 API에서 받아온 DogModel이 들어감
    final DogModel dog = dummyDog;

    return Scaffold(
      backgroundColor: backgroundColor,

      // SafeArea: 아이폰 노치, 안드로이드 상태바 등을 피해서 내용 배치해줌
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
        
            padding: const EdgeInsets.symmetric(horizontal: 28), //화면 전체 좌우 여백
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
              const SizedBox(height: 24),

              // ── 상단: "프로필" 타이틀 + 점 세개(더보기) 버튼 ──
                Row( //가로배치. 프로필 텍스트와 더보기 버튼을 한 줄에.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, //spaceBetween = 양 끝으로 밀어냄. (왼쪽엔 텍스트, 오른쪽엔 버튼)
                  children: [
                    const Text(
                    '프로필', 
                    style: TextStyle(
                      fontFamily: 'inter',
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.1, //행간 110%
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                      // TODO: 더보기 메뉴 (설정으로 이동 등) 연결 예정
                    },
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF636037), size: 28, ),
                  ),
                ],
              ),

              const SizedBox(height: 0),

              Center( //강아지 사진 + 뒷배경
                child: SizedBox(
                  width: 190,
                  height: 193,
                  child: Stack(
                    children: [
                      //뒤 배경박스 
                      Positioned(
                        top: 27, 
                        left: 11,
                        child: Container(
                          width: 172,
                          height: 166,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA9AA80).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            ) //boxd
                          ),
                        ),
                        Positioned(
                          //강아지 견종 일러스트
                          top: 0,
                          left:0,
                          child: DogIcon(
                            breed: dog.breed,
                            size: 190,
                          ),
                        ),
        
                    ],
                  ),
                ),
              ),

              

              const SizedBox(height: 14),

              // ── 강아지 이름 ──
              Center(
                child: Text(
                  dog.name,
                  style: const TextStyle(
                    fontFamily: 'inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 1),

              // ── 견종 · 나이 · 레벨 ──
              Center(
                child: Text(
                  '${dog.breed} . ${dog.age}세 . Lv.${dog.level}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── 성격 태그들 (에너지형, 호기심형 등) ──
              Center(
                child: Wrap(
                  // Wrap: Row와 비슷하지만, 공간 부족하면 자동으로 다음 줄로 넘김
                  spacing: 5, // 태그 사이 가로 간격
                  children: dog.personalityTags
                  .map((tag) => PersonalityTag(label: tag)) 
                  .toList(),
                  // map 결과를 리스트로 변환 (Wrap의 children은 List여야 함)
                ),
              ),

              const SizedBox(height: 11),

              // ── 레벨업 진행 바 ──
              ExpBar(currentExp: dog.currentExp, requiredExp: dog.requiredExp),

              const SizedBox(height: 27),

              // ── "이번 달 권장 산책 달성률" 섹션 ──
              const Text(
                '이번 달 권장 산책 달성률',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  height: 1.1,
                  ),
              ),
              const SizedBox(height: 13),
              WalkGoalCard(
                breed: dog.breed,
                goalDistanceKm: dog.monthlyWalkGoal,
                actualDistanceKm: dog.monthlyWalkDistance,
                achievementRate: dog.achievementRate,
              ),

              const SizedBox(height: 27),

              // ── 통계 3개 카드 (누적거리 / 연속산책 / 획득뱃지) ──
              Row(
                children: [
                  Expanded(child: StatCard(value: '${dog.totalDistance.toInt()}km', label: '누적 거리')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '${dog.consecutiveDays}일', label: '연속 산책')),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '${dog.badgeCount}개', label: '획득 뱃지')),
                ],
              ),

              const SizedBox(height: 27),

              // ── 보유 뱃지 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '보유 뱃지',
                    style: TextStyle(fontSize: 20,
                     fontWeight: FontWeight.w600,
                     fontFamily: 'Inter',
                     height: 1.1,
                     ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 뱃지도감 화면으로 이동 연결 예정
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('더보기',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:const Color(0xFF636037).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              BadgeRow(badgeImagePaths: dog.ownedBadgeImagePaths, maxCount: 3),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}