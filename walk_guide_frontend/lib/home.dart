import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 패키지 import
import 'package:google_fonts/google_fonts.dart';
import 'widgets/custom_widgets.dart';

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);

// -----------------------------------------------------------------------------
// [백엔드 API 및 DB 스키마 매핑 모델]
// -----------------------------------------------------------------------------

// GET api/pets/:pet_id/missions/?period=DAILY
class PetMissionItem {
  final int id;
  final int missionId;
  final String title;
  final int currentValue;
  final int requiredCount;
  final int rewardExperience;
  final String status; // IN_PROGRESS, CLAIMABLE, CLAIMED

  PetMissionItem({
    required this.id,
    required this.missionId,
    required this.title,
    required this.currentValue,
    required this.requiredCount,
    required this.rewardExperience,
    required this.status,
  });

  factory PetMissionItem.fromJson(Map<String, dynamic> json) {
    return PetMissionItem(
      id: json['id'] ?? 0,
      missionId: json['mission_id'] ?? 0,
      title: json['title'] ?? '',
      currentValue: json['current_value'] ?? 0,
      requiredCount: json['required_count'] ?? 1,
      rewardExperience: json['reward_experience'] ?? 0,
      status: json['status'] ?? 'IN_PROGRESS',
    );
  }
}

// GET api/friends/ (산책 중인 친구 목록)
class FriendInfo {
  final int friendId;
  final String friendName;
  final String petName;
  final String? profileImageUrl;
  final bool isWalking;

  FriendInfo({
    required this.friendId,
    required this.friendName,
    required this.petName,
    this.profileImageUrl,
    this.isWalking = false,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      friendId: json['friend_id'] ?? 0,
      friendName: json['friend_name'] ?? '',
      petName: json['pet_name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      isWalking: json['is_walking'] ?? false,
    );
  }
}

// 홈 화면 종합 응답 DTO
class HomeDashboardResponse {
  final String userName;
  final int petId;
  final String petName;
  final String petBreed;
  final int petAge;
  final int petLevel;
  final List<String> petPersonalities;
  final double targetDistance;
  final double currentDistance;
  final List<FriendDogDisplay> walkingFriends;
  final List<PetMissionItem> dailyMissions;

  HomeDashboardResponse({
    required this.userName,
    required this.petId,
    required this.petName,
    required this.petBreed,
    required this.petAge,
    required this.petLevel,
    required this.petPersonalities,
    required this.targetDistance,
    required this.currentDistance,
    required this.walkingFriends,
    required this.dailyMissions,
  });
}

class FriendDogDisplay {
  final String name;
  final String? profileImage;

  FriendDogDisplay({required this.name, this.profileImage});
}

// -----------------------------------------------------------------------------
// [HomeScreen 위젯]
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final bool showPermissionDialog;

  const HomeScreen({super.key, this.showPermissionDialog = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<HomeDashboardResponse> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _fetchHomeData();

    if (widget.showPermissionDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showPermissionDialog(context);
      });
    }
  }

  // 실제 API 호출 연동 지점
  Future<HomeDashboardResponse> _fetchHomeData() async {
    // 실제 API 호출 연동 지점 (ApiService 분리 시 연결)

    // TODO: 백엔드 API 연동 시 아래 주석 해제 후 연결
    // 1. GET api/users/:user_id/ (유저 정보)
    // 2. GET api/pets/:pet_id/ (반려견 상세 & level)
    // 3. GET api/pets/:pet_id/missions/?period=DAILY (일일 미션)
    // 4. GET api/friends/ (친구 목록)
    await Future.delayed(const Duration(milliseconds: 300)); // 모의 지연

    return HomeDashboardResponse(
      userName: '예은님',
      petId: 1,
      petName: '두부',
      petBreed: '말티즈',
      petAge: 2,
      petLevel: 1,
      petPersonalities: ['에너지형', '호기심형'],
      targetDistance: 2.0,
      currentDistance: 1.4,
      walkingFriends: [
        FriendDogDisplay(name: '초코'),
        FriendDogDisplay(name: '밀크'),
        FriendDogDisplay(name: '토리'),
        FriendDogDisplay(name: '휴지'),
      ],
      dailyMissions: [
        PetMissionItem(
          id: 101,
          missionId: 1,
          title: '첫 산책 시작하기',
          currentValue: 1,
          requiredCount: 1,
          rewardExperience: 10,
          status: 'CLAIMED',
        ),
        PetMissionItem(
          id: 102,
          missionId: 2,
          title: '새로운 친구 반려견 만나기',
          currentValue: 0,
          requiredCount: 2,
          rewardExperience: 20,
          status: 'IN_PROGRESS',
        ),
      ],
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<HomeDashboardResponse>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '데이터를 불러오지 못했습니다.\n다시 시도해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
              ),
            );
          }

          final data = snapshot.data!;
          final double walkRatio = data.targetDistance > 0
              ? (data.currentDistance / data.targetDistance).clamp(0.0, 1.0)
              : 0.0;
          final int walkPercentage = (walkRatio * 100).toInt();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 상단 히어로 섹션 (background.svg & trees1.svg 배치)
                    _buildTopHeroSection(data.userName),

                    // 2. 메인 시트 (상단 그림자 적용)
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFCEF),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPetProfileHeader(data),
                            const SizedBox(height: 20),
                            _buildWalkProgressCard(
                              data,
                              walkRatio,
                              walkPercentage,
                            ),
                            const SizedBox(height: 28),
                            _buildWalkingFriendsSection(data.walkingFriends),
                            const SizedBox(height: 28),
                            _buildDailyMissionsSection(data.dailyMissions),
                            const SizedBox(height: 28),

                            CustomButton(
                              text: '산책 시작하기',
                              onPressed: () {
                                // TODO: 산책 시작 API 호출
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 탭바
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNavigationBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  // 상단 히어로 영역 (background.svg + trees1.svg + 강아지 + 텍스트)
  Widget _buildTopHeroSection(String userName) {
    return SizedBox(
      width: double.infinity,
      height: 390,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 배경 SVG (길 모양 산책로)
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background.svg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. 우측 하단 나무 SVG (trees1.svg)
          Positioned(
            right: 20,
            bottom: 35,
            child: SvgPicture.asset(
              'assets/images/trees1.svg',
              width: 125,
              height: 135,
              fit: BoxFit.contain,
            ),
          ),

          // 3. 중앙 메인 강아지 캐릭터
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset(
                  'assets/images/dog_main.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.pets,
                    size: 130,
                    color: Color(0xFFB5CF9B),
                  ),
                ),
              ),
            ),
          ),

          // 4. 상단 인사말 및 꾸미러가기 버튼
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '좋은 아침이에요',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A7955),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: 꾸미기 화면 이동
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '꾸미러가기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF676543),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Color(0xFF676543),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 반려견 정보 & 성격 태그 & 레벨
  Widget _buildPetProfileHeader(HomeDashboardResponse data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.petName,
              style: GoogleFonts.notoSansKr(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${data.petBreed} · ${data.petAge}세',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Lv.${data.petLevel}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: data.petPersonalities.map((trait) {
                return Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: _buildTag(
                    trait.contains('에너지') ? Icons.bolt : Icons.search,
                    trait,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3DC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6CEB2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black87),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 산책 권장량 게이지 카드
  Widget _buildWalkProgressCard(
    HomeDashboardResponse data,
    double ratio,
    int percentage,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD3D8BA), width: 1.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 6.5,
                    backgroundColor: const Color(0xFFEFEFEF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF72AA4F),
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 산책 권장량',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.targetDistance}km 중 ${data.currentDistance}km 완료',
                style: GoogleFonts.notoSansKr(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 산책 중인 친구 섹션
  Widget _buildWalkingFriendsSection(List<FriendDogDisplay> friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지금 산책 중인 친구',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: friends.map((friend) {
            return Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F0D8),
                    shape: BoxShape.circle,
                  ),
                  child: friend.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            friend.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.pets,
                                  color: Color(0xFF72AA4F),
                                  size: 30,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.pets,
                          color: Color(0xFF72AA4F),
                          size: 30,
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // 오늘의 미션 섹션
  Widget _buildDailyMissionsSection(List<PetMissionItem> missions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오늘의 미션',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                '더보기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...missions.map((mission) {
          final isCompleted =
              mission.status == 'CLAIMED' || mission.status == 'CLAIMABLE';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildMissionItem(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF90C271)
                      : const Color(0xFFDDEBC8),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Center(
                        child: Text(
                          '${mission.requiredCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF496B31),
                          ),
                        ),
                      ),
              ),
              title: mission.title,
              subtitle: isCompleted
                  ? '+ ${mission.rewardExperience} XP'
                  : '${mission.currentValue} / ${mission.requiredCount} 완료',
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMissionItem({
    required Widget leading,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFDA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 하단 네비게이션 바
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home_outlined, Icons.home, '홈'),
              _buildBottomNavItem(
                1,
                Icons.insert_photo_outlined,
                Icons.insert_photo,
                '리포트',
              ),
              const SizedBox(width: 54),
              _buildBottomNavItem(3, Icons.people_outline, Icons.people, '친구'),
              _buildBottomNavItem(4, Icons.person_outline, Icons.person, '프로필'),
            ],
          ),
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: const Color(0xFFADC87F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '산책',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF708749),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? const Color(0xFF72AA4F)
                  : const Color(0xFF98A682),
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF72AA4F)
                    : const Color(0xFF98A682),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 접근 권한 안내 팝업 위젯
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '더 편리한 서비스 이용을 위한\n접근 권한을 안내드립니다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildPermissionItem(
                icon: Icons.location_on_outlined,
                title: '위치 정보',
                isOptional: true,
                description: '산책 경로 기록과 근처 친구 확인',
              ),
              const SizedBox(height: 18),
              _buildPermissionItem(
                icon: Icons.notifications_none_outlined,
                title: '알림',
                isOptional: true,
                description: '산책 리마인더와 주간 리포트 알림',
              ),
              const SizedBox(height: 28),
              CustomButton(text: '확인', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required bool isOptional,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF90C271), width: 1.8),
          ),
          child: Icon(icon, color: const Color(0xFF90C271), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '(선택)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
