import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/api_service.dart';
import 'walk_tracking.dart';
import 'mission_screen.dart'; // ✅ "더보기" -> 미션 화면 연결용
import 'decorate_screen.dart'; // ✅ "꾸미러가기" -> 꾸미기 화면 연결용 (클래스명: DecorationScreen)

const Color backgroundColor = Color(0xFFF8F9E5);
const Color primaryGreen = Color(0xFF27722F);

class HomeScreen extends StatefulWidget {
  final bool showPermissionDialog;

  const HomeScreen({super.key, this.showPermissionDialog = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<HomeDashboardResponse>? _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();

    if (widget.showPermissionDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showPermissionDialog(context);
      });
    }
  }

  void _loadDashboard() {
    setState(() {
      _homeDataFuture = ApiService.getHomeDashboardData();
    });
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  void _navigateToWalkTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalkTrackingScreen()),
    );
  }

  // ✅ 오늘의 미션 "더보기" -> 미션 화면
  void _navigateToMissionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MissionScreen()),
    );
  }

  // ✅ "꾸미러가기" -> 꾸미기 화면
  void _navigateToDecorationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DecorationScreen()),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '데이터를 불러오지 못했습니다.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _loadDashboard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                    ),
                    child: const Text(
                      '다시 시도',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final double walkRatio = data.targetDistance > 0
              ? (data.currentDistance / data.targetDistance).clamp(0.0, 1.0)
              : 0.0;
          final int walkPercentage = (walkRatio * 100).toInt();

          return Container(
            color: backgroundColor,
            child: SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeroSection(
                        data.userName,
                        data.petImageUrl,
                        data.petBreed,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: backgroundColor, // 💡 F8F9E5로 완전 통일
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 24,
                            bottom: 60, // 바텀바와 자연스럽게 이어지도록 여백 설정
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
                                onPressed: _navigateToWalkTracking,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 우측 배경 나무 SVG
                  Positioned(
                    top: 270,
                    right: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 1),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 1.0,
                              sigmaY: 4.0,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/trees1.svg',
                              width: 125,
                              height: 135,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.35),
                                BlendMode.srcIn,
                              ),
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/trees1.svg',
                          width: 125,
                          height: 135,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 상단 히어로 영역
  Widget _buildTopHeroSection(
    String userName,

    String? petImageUrl,

    String breed,
  ) {
    return SizedBox(
      width: double.infinity,

      height: 435,

      child: Stack(
        clipBehavior: Clip.none,

        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background.svg',

              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFFF1F3D8)),
            ),
          ),

          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,

              child: Padding(
                padding: const EdgeInsets.only(bottom: 95.0),

                child: SizedBox(
                  width: 250,

                  height: 250,

                  child: Stack(
                    alignment: Alignment.bottomCenter,

                    clipBehavior: Clip.none,

                    children: [
                      // 1. 강아지 그림자
                      Positioned(
                        bottom: 26,

                        child: Container(
                          width: 180,

                          height: 18,

                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF636037,
                            ).withValues(alpha: 0.28),

                            borderRadius: const BorderRadius.all(
                              Radius.elliptical(135, 14),
                            ),
                          ),
                        ),
                      ),

                      // 2. 강아지 이미지 (240px 크기)
                      Positioned(
                        bottom: 0,

                        child: _buildDogImage(petImageUrl, breed, size: 320),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

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
                      const SizedBox(height: 50),

                      const Text(
                        '좋은 아침이에요',

                        style: TextStyle(
                          fontSize: 14,

                          fontWeight: FontWeight.w400,

                          color: Color(0xFF7A7955),

                          height: 1.0,
                        ),
                      ),

                      Text(
                        userName,

                        style: GoogleFonts.notoSansKr(
                          fontSize: 31,

                          fontWeight: FontWeight.w800,

                          color: Colors.black,

                          height: 1.1,
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: _navigateToDecorationScreen, // ✅ 연결됨

                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: const [
                          Text(
                            '꾸미러가기',

                            style: TextStyle(
                              fontSize: 13,

                              fontWeight: FontWeight.w300,

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

  Widget _buildDogImage(
    String? imageUrl,
    String breedOrName, {
    double size = 170,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildBreedDogAsset(breedOrName, size: size),
        );
      } else {
        return Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildBreedDogAsset(breedOrName, size: size),
        );
      }
    }
    return _buildBreedDogAsset(breedOrName, size: size);
  }

  Widget _buildBreedDogAsset(String keyword, {double size = 170}) {
    final Map<String, String> breedFileMap = {
      '비글': 'beagle.png',
      '비숑': 'bichon.png',
      '치와와': 'chihuahua.png',
      '웰시코기': 'corgi.png',
      '닥스훈트': 'dachshund.png',
      '도베르만': 'doberman.png',
      '프렌치불독': 'french_bulldog.png',
      '골든리트리버': 'golden_retriever.png',
      '그레이하운드': 'greyhound.png',
      '허스키': 'husky.png',
      '말티즈': 'maltese.png',
      '포메라니안': 'pomeranian.png',
      '푸들': 'poodle.png',
      '퍼그': 'pug.png',
      '사모예드': 'samoyed.png',
      '슈나우저': 'schnauzer.png',
      // ⚠️ 아래 4개는 견종이 아니라 더미 "친구" 이름을 임시로 땜빵한 것.
      // TODO: 친구 더미데이터에 실제 breed 필드 생기면 이 4줄 삭제
      '초코': 'poodle.png',
      '밀크': 'samoyed.png',
      '토리': 'corgi.png',
      '휴지': 'bichon.png',
    };

    String fileName = 'maltese.png';
    for (final entry in breedFileMap.entries) {
      if (keyword.contains(entry.key)) {
        fileName = entry.value;
        break;
      }
    }

    final dogAssetPath = 'assets/dogs/$fileName';

    return Image.asset(
      dogAssetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/dog_main.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.pets,
            size: size * 0.6,
            color: const Color(0xFFB5CF9B),
          ),
        );
      },
    );
  }

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

  Widget _buildWalkingFriendsSection(List<FriendDogDisplay> friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '지금 산책 중인 친구',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            if (friends.isNotEmpty)
              Text(
                '${friends.length}마리 산책 중',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF72AA4F),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (friends.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEFDA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '현재 주변에 산책 중인 친구가 없습니다.',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ),
          )
        else
          SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: friends.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9F0D8),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: _buildDogImage(
                            friend.profileImage,
                            friend.name,
                            size: 52,
                          ),
                        ),
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
              },
            ),
          ),
      ],
    );
  }

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
              onTap: _navigateToMissionScreen, // ✅ 연결됨
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
        if (missions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEFDA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '오늘 등록된 미션이 없습니다.',
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ),
          )
        else
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
}

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