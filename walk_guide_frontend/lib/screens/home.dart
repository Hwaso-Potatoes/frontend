import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'decorate_screen.dart';
import 'attendance_screen.dart';
import 'login.dart';
import '../services/active_pet_store.dart';
import '../widgets/pet_identity.dart';
import '../widgets/personality_tag.dart';
import '../widgets/decoration/dog_character.dart';

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
  AttendanceSummaryResponse? _attendanceSummary;
  bool _attendanceLoading = true;
  String? _attendanceError;
  int _attendanceRequest = 0;

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
      _homeDataFuture = () async {
        if (ActivePetStore.instance.error != null) {
          await ActivePetStore.instance.refresh();
        } else {
          await ActivePetStore.instance.ensureLoaded();
        }
        if (ActivePetStore.instance.error != null)
          throw ApiException(
            ActivePetStore.instance.errorStatus ?? 500,
            ActivePetStore.instance.error!,
          );
        return ApiService.getHomeDashboardData();
      }();
    });
    _loadAttendanceStatus();
  }

  Future<void> _loadAttendanceStatus() async {
    final request = ++_attendanceRequest;
    setState(() {
      _attendanceLoading = true;
      _attendanceError = null;
      _attendanceSummary = null;
    });
    try {
      final summary = await ApiService.getAttendanceSummary();
      if (!mounted || request != _attendanceRequest) return;
      setState(() => _attendanceSummary = summary);
    } catch (e) {
      if (!mounted || request != _attendanceRequest) return;
      debugPrint('홈 출석 상태 조회 실패: $e');
      setState(() => _attendanceError = '출석 정보를 불러오지 못했어요');
    } finally {
      if (mounted && request == _attendanceRequest) {
        setState(() => _attendanceLoading = false);
      }
    }
  }

  /// 토큰이 없거나 만료(401)된 경우: 저장된 세션을 지우고 로그인 화면으로
  Future<void> _goToLogin() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
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

  Future<void> _handleAttendanceTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AttendanceScreen()),
    );
    if (mounted) await _loadAttendanceStatus();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ActivePetStore.instance,
    builder: (context, _) => _buildHome(context),
  );
  Widget _buildHome(BuildContext context) {
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
            final error = snapshot.error;
            final bool needsLogin =
                error is ApiException && error.isUnauthorized;
            final String message = error is ApiException
                ? error.message
                : '데이터를 불러오지 못했습니다.';
            debugPrint('🚨 홈 데이터 로드 실패: $error');

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: needsLogin ? _goToLogin : () => _loadDashboard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                    ),
                    child: Text(
                      needsLogin ? '다시 로그인' : '다시 시도',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final original = snapshot.data!;
          final state = ActivePetStore.instance;
          final pet = state.pet;
          final data = HomeDashboardResponse(
            userName: state.user['nickname']?.toString() ?? original.userName,
            petId: pet?.id ?? original.petId,
            petName: pet?.name ?? original.petName,
            petBreed: pet?.breed ?? original.petBreed,
            petAge: pet?.age ?? original.petAge,
            petLevel: pet?.level ?? original.petLevel,
            petImageUrl: null,
            petPersonalities: pet?.traits ?? original.petPersonalities,
            targetDistance: original.targetDistance,
            currentDistance: original.currentDistance,
            walkingFriends: original.walkingFriends,
            dailyMissions: original.dailyMissions,
          );

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
          // 인사말 아래부터 강아지 영역을 시작해 긴 견종도 글자와 겹치지 않는다.
          Positioned(
            top: MediaQuery.of(context).padding.top + 130,
            bottom: 75,
            left: 24,
            right: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableSize =
                    constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                final baseSize = availableSize.clamp(0.0, 250.0).toDouble();
                final dogSize = baseSize * _heroBreedScale(breed);
                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: dogSize * 0.65,
                        height: 14,
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
                      child: DogCharacter(
                        breed: breed,
                        size: dogSize,
                        equipped: ActivePetStore.instance.equipped,
                      ),
                    ),
                  ],
                );
              },
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

  // 홈의 큰 강아지 이미지에만 적용한다. 친구 썸네일 크기는 유지한다.
  // 원본 이미지의 투명 여백에 따라 이 비율만 조정하면 된다.
  double _heroBreedScale(String breed) {
    const scales = <String, double>{
      '골든리트리버': 0.88,
      '그레이하운드': 0.82,
      '도베르만': 0.84,
      '허스키': 0.88,
      '사모예드': 0.90,
      '푸들': 0.90,
      '슈나우저': 0.92,
      '비글': 0.94,
      '웰시코기': 1.00,
      '닥스훈트': 1.00,
      '비숑': 1.00,
      '말티즈': 1.00,
      '치와와': 0.94,
      '포메라니안': 1.00,
      '프렌치불독': 0.94,
      '퍼그': 0.94,
      '시추': 1.00,
    };
    final normalized = breed.replaceAll(RegExp(r'\s+'), '');
    for (final entry in scales.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }
    return 1.0;
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
          alignment: Alignment.bottomCenter,
          errorBuilder: (context, error, stackTrace) =>
              _buildBreedDogAsset(breedOrName, size: size),
        );
      } else {
        return Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
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

    // 가입 화면/서버의 '골든 리트리버'도 '골든리트리버'와 같은 견종이다.
    final normalizedKeyword = keyword.replaceAll(RegExp(r'\s+'), '');
    String fileName = 'maltese.png';
    for (final entry in breedFileMap.entries) {
      if (normalizedKeyword.contains(entry.key)) {
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
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/dog_main.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
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
    final pet = ActivePetStore.instance.pet;
    if (pet == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: PetIdentity(pet: pet)),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Lv.${pet.level}',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6,
                    runSpacing: 6,
                    children: pet.traits.map(_buildPersonalityTag).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (ActivePetStore.instance.accessoriesError != null)
          TextButton(
            onPressed: ActivePetStore.instance.reloadAccessories,
            child: const Text('장착 정보 다시 조회'),
          ),
      ],
    );
  }

  Widget _buildPersonalityTag(String trait) =>
      PersonalityTag(label: trait, homeStyle: true);

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

  // 출석 요약의 실제 보상·수령 상태를 표시한다.
  Widget _buildAttendanceBanner() {
    final today = _attendanceSummary?.today;
    final reward = today?.reward;
    final hasReward = (reward?.id ?? 0) > 0;
    final opened = hasReward && (reward?.opened ?? false);
    final title = _attendanceLoading
        ? '오늘의 출석 정보를 확인하고 있어요'
        : _attendanceError ??
              (opened
                  ? '오늘의 출석선물을 받았어요!'
                  : hasReward
                  ? '오늘의 출석선물이 도착했어요!'
                  : today?.attended == true
                  ? '오늘 출석을 완료했어요!'
                  : '오늘의 출석 현황을 확인해보세요');
    final subtitle = _attendanceLoading
        ? '잠시만 기다려주세요'
        : _attendanceError != null
        ? '눌러서 다시 확인하세요'
        : opened
        ? '받은 선물과 출석 기록을 확인하세요'
        : hasReward
        ? '눌러서 선물을 열어보세요'
        : '출석 기록과 보상 현황을 확인하세요';
    return GestureDetector(
      onTap: () {
        if (_attendanceError != null) {
          _loadAttendanceStatus();
        } else {
          _handleAttendanceTap();
        }
      },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E4416),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B8A46),
                    ),
                  ),
                ],
              ),
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
