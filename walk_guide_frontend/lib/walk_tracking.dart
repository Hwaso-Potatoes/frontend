import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'widgets/custom_widgets.dart';
import 'services/api_service.dart';
import 'walk_report.dart';

// 백엔드 웹소켓 수신 스키마 모델
class FriendLocation {
  final int userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? profileImage;

  FriendLocation({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.profileImage,
  });

  factory FriendLocation.fromJson(Map<String, dynamic> json) {
    return FriendLocation(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      name: json['pet_name'] ?? json['name'] ?? '토리',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      profileImage: json['profile_image'],
    );
  }
}

class WalkTrackingScreen extends StatefulWidget {
  final int petId;
  const WalkTrackingScreen({super.key, this.petId = 1});

  @override
  State<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends State<WalkTrackingScreen> {
  int _currentIndex = 2;
  bool _isWalking = true;
  int _seconds = 0;
  double _distance = 0.0;
  Timer? _timer;
  int? _walkId;
  bool _isEnding = false;

  final MapController _mapController = MapController();
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<ll.LatLng> _routePoints = [];

  List<FriendLocation> _nearbyFriends = [];

  // 기본 중심 위치 (서울시청)
  ll.LatLng _currentLatLng = const ll.LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _initWalkSession();
    _checkPermissionAndStartTracking();
  }

  Future<void> _checkPermissionAndStartTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(position);

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3,
            ),
          ).listen((Position newPosition) {
            if (_isWalking && mounted) {
              _updateLocation(newPosition);
            }
          });
    } catch (e) {
      debugPrint('위치 트래킹 오류: $e');
    }
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLatLng = ll.LatLng(position.latitude, position.longitude);
      _routePoints.add(_currentLatLng);

      if (_lastPosition != null) {
        double movedMeters = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (movedMeters > 0.5 && movedMeters < 30) {
          _distance += (movedMeters / 1000.0);
        }
      }
      _lastPosition = position;

      _updateFriendsNearby();
    });

    _mapController.move(_currentLatLng, 17.5);
  }

  void _updateFriendsNearby() {
    if (_nearbyFriends.isEmpty) {
      _nearbyFriends = [
        FriendLocation(
          userId: 1,
          name: '토리',
          latitude: _currentLatLng.latitude + 0.0006,
          longitude: _currentLatLng.longitude + 0.0006,
          profileImage: null,
        ),
      ];
    }
  }

  Future<void> _initWalkSession() async {
    try {
      final walkData = await ApiService.startWalk(
        petId: widget.petId,
        isLocationShared: true,
      );
      if (mounted) {
        setState(() => _walkId = walkData.id);
        _startTimer();
      }
    } catch (_) {
      if (mounted) _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWalking && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  // 💡 [수정] ApiService.endWalk의 반환 타입(WalkReportData)을 그대로 받아서 리포트 화면으로 전달
  Future<void> _handleEndWalk() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);
    _timer?.cancel();
    _positionStreamSubscription?.cancel();

    try {
      final WalkReportData report = await ApiService.endWalk(
        _walkId ?? 1,
        currentDistance: _distance,
        currentDurationStr: _formatDuration(_seconds),
      );
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WalkReportScreen(reportData: report),
        ),
      );
    } catch (_) {
      setState(() => _isEnding = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}분 ${sec.toString().padLeft(2, '0')}초';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6DF),
      body: Stack(
        children: [
          // 1. 지도 영역
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLatLng,
                initialZoom: 17.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.walkguide',
                ),

                // 경로 선 (Polyline)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.5,
                      color: const Color(0xFF27722F).withValues(alpha: 0.7),
                    ),
                  ],
                ),

                // 마커 레이어
                MarkerLayer(
                  markers: [
                    // 내 위치 내비게이션 화살표 마커
                    Marker(
                      point: _currentLatLng,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF27722F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    // 물방울 형태 주변 친구 마커
                    ..._nearbyFriends.map((friend) {
                      return Marker(
                        point: ll.LatLng(friend.latitude, friend.longitude),
                        width: 68,
                        height: 94,
                        alignment: Alignment.topCenter,
                        child: _buildDropPinMarker(
                          friend.name,
                          friend.profileImage,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // 2. 하단 컨트롤 카드
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_distance.toStringAsFixed(1)}km',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          '이동 거리',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.black12),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDuration(_seconds),
                          style: GoogleFonts.notoSansKr(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          '산책 시간',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isEnding ? null : _handleEndWalk,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF75A64C),
                        shape: BoxShape.circle,
                      ),
                      child: _isEnding
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 하단 네비게이션 바
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 0) Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropPinMarker(String name, String? imageUrl) {
    return CustomPaint(
      painter: PinDropShadowPainter(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 7),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF9EBA9F),
              shape: BoxShape.circle,
            ),
            child: Center(child: _buildDogImage(imageUrl)),
          ),
          const SizedBox(height: 3),
          Text(
            name,
            style: GoogleFonts.notoSansKr(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDogImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            imageUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildDefaultDogIcon(),
          ),
        );
      } else {
        return ClipOval(
          child: Image.asset(
            imageUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildDefaultDogIcon(),
          ),
        );
      }
    }
    return _buildDefaultDogIcon();
  }

  Widget _buildDefaultDogIcon() {
    return const Icon(Icons.pets, size: 24, color: Color(0xFF3F6634));
  }
}

class PinDropShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F6634)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double radius = w / 2;

    path.moveTo(0, radius);
    path.arcToPoint(
      Offset(w, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.quadraticBezierTo(w * 0.85, h * 0.72, w / 2, h);
    path.quadraticBezierTo(w * 0.15, h * 0.72, 0, radius);
    path.close();

    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
