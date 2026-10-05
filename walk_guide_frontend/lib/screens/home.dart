import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'decorate_screen.dart';
import 'attendance_screen.dart';

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
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  void _navigateToDecorationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DecorationScreen()),
    );
  }

  void _handleAttendanceTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AttendanceScreen()),
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
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
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
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeroSection(
                    data.userName,
                    data.petImageUrl,
                    data.petBreed,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -35),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 24,
                        bottom: 60,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPetProfileHeader(data),
                          const SizedBox(height: 16),
                          _buildWalkProgressCard(
                            data,
                            walkRatio,
                            walkPercentage,
                          ),
                          const SizedBox(height: 20),
                          _buildWalkingFriendsSection(data.walkingFriends),
                          const SizedBox(height: 16),
                          _buildAttendanceBanner(),
                          const SizedBox(height: 12),
                        ],
                      ),
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
          Positioned(
            right: 20,
            bottom: 75,
            child: SvgPicture.asset(
              'assets/images/trees1.svg',
              width: 125,
              height: 135,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
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
                      Positioned(
                        bottom: 26,
                        child: Container(
                          width: 180,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF636037).withOpacity(0.28),
                            borderRadius: const BorderRadius.all(
                              Radius.elliptical(135, 14),
                            ),
                          ),
                        ),
                      ),
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
                    onTap: _navigateToDecorationScreen,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '꾸미러가기',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF676543),
                            ),
                          ),
                          SizedBox(width: 2),
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
              '${data.petBreed} . ${data.petAge}세',
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
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
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
        Text(
          '지금 산책 중인 친구',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFA9AA80).withOpacity(0.15),
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

  // 출석 체크 배너 UI (2번 사진 시안과 완벽 일치)
  Widget _buildAttendanceBanner() {
    return GestureDetector(
      onTap: _handleAttendanceTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F1CD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFB4D58B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Color(0xFF4B6B2B),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 출석선물이 도착했어요!',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E4416),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '클릭하여 자세히 보세요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B8A46),
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

// -----------------------------------------------------------------------------
// [권한 안내 팝업 위젯 (PermissionDialog)]
// -----------------------------------------------------------------------------
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 48, color: primaryGreen),
            const SizedBox(height: 16),
            Text(
              '위치 권한 안내',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '산책 경로 기록 및 근처 친구 확인을 위해 위치 서비스 권한이 필요합니다.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
