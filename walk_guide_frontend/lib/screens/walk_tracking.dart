import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'walk_report.dart';
import 'login.dart';

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
          : int.parse(json['user_id'].toString()),
      name:
          (json['pet_name'] ??
                  json['name'] ??
                  json['nickname'] ??
                  '친구 ${json['user_id']}')
              .toString(),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      profileImage: ApiService.resolveMediaUrl(
        json['profile_image']?.toString(),
      ),
    );
  }
}

class WalkTrackingScreen extends StatefulWidget {
  final int? petId;
  const WalkTrackingScreen({super.key, this.petId});

  @override
  State<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends State<WalkTrackingScreen>
    with WidgetsBindingObserver {
  bool _isWalking = false;
  bool _isStarting = false;
  String? _startError;
  bool _endOutcomeUnknown = false;
  bool _walkFinished = false;
  Future<void> _locationWrites = Future<void>.value();
  bool _hasLocationError = false;
  bool _isSavingLocation = false;
  Position? _pendingPosition;
  int _seconds = 0;
  double _distance = 0.0;
  Timer? _timer;
  int? _walkId;
  bool _isEnding = false;
  bool _isLocationShared = true;
  bool _isTogglingLocation = false;
  bool _exitRequested = false;
  bool _allowPop = false;

  final MapController _mapController = MapController();
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<ll.LatLng> _routePoints = [];

  List<FriendLocation> _nearbyFriends = [];
  WebSocketChannel? _friendsChannel;
  StreamSubscription<dynamic>? _friendsSubscription;
  Timer? _friendsRetryTimer;
  Timer? _nearbyRefreshTimer;
  int _friendsGeneration = 0;
  int _friendsRetryCount = 0;
  bool _appActive = true;
  bool _friendsConnected = false;
  String? _friendsError;
  int? _currentUserId;

  bool get _shouldConnectFriends =>
      mounted &&
      _appActive &&
      _isWalking &&
      !_walkFinished &&
      _isLocationShared &&
      _walkId != null &&
      !ApiService.useMockData;

  // 기본 중심 좌표 (서울시청)
  ll.LatLng _currentLatLng = const ll.LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWalkSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    if (_appActive) {
      _syncFriendsConnection();
    } else {
      _stopFriendsConnection();
      if (mounted) setState(() => _nearbyFriends.clear());
    }
  }

  void _syncFriendsConnection() {
    if (ApiService.useMockData) {
      if (mounted)
        setState(() {
          _nearbyFriends.clear();
          if (_isLocationShared) _updateFriendsNearby();
        });
      return;
    }
    if (!_shouldConnectFriends) {
      _stopFriendsConnection();
      if (mounted)
        setState(() {
          _nearbyFriends.clear();
          _friendsError = null;
        });
    } else if (_friendsChannel == null && _friendsRetryTimer == null) {
      unawaited(_connectFriends());
    }
  }

  // 주변 친구 조회: ws/nearby/. JWT는 기존 서버 안내대로 token 쿼리 사용.
  // 별도 실행 옵션 없이도 저장된 JWT를 token 쿼리로 전달한다.
  Future<Uri> _friendsSocketUri() async {
    final api = Uri.parse(ApiService.baseUrl);
    final uri = api
        .resolve('/ws/nearby/')
        .replace(scheme: api.scheme == 'https' ? 'wss' : 'ws');
    const configuredQuery = String.fromEnvironment(
      'WALK_WS_TOKEN_QUERY',
      defaultValue: 'token',
    );
    final tokenQuery = configuredQuery.trim().isEmpty
        ? 'token'
        : configuredQuery.trim();
    final token = (await ApiService.getAccessToken())?.trim();
    if (token == null || token.isEmpty) {
      throw ApiException(401, '로그인이 만료되었습니다. 다시 로그인해주세요.');
    }
    return uri.replace(queryParameters: {tokenQuery: token});
  }

  Future<void> _connectFriends() async {
    if (!_shouldConnectFriends || _friendsChannel != null) return;
    final generation = ++_friendsGeneration;
    setState(() => _friendsError = null);
    try {
      final ownId = int.tryParse(await ApiService.getUserId() ?? '');
      if (ownId == null) {
        throw ApiException(401, '내 위치를 구별할 로그인 정보를 확인하지 못했습니다.');
      }
      final uri = await _friendsSocketUri();
      if (!_shouldConnectFriends || generation != _friendsGeneration) return;
      _currentUserId = ownId;
      final channel = WebSocketChannel.connect(uri);
      _friendsChannel = channel;
      _friendsSubscription = channel.stream.listen(
        (dynamic message) {
          if (generation == _friendsGeneration && _shouldConnectFriends) {
            _receiveFriendLocation(message);
          }
        },
        onError: (Object error) => _friendsConnectionFailed(generation),
        onDone: () => _friendsConnectionFailed(generation),
        cancelOnError: true,
      );
      await channel.ready.timeout(const Duration(seconds: 12));
      if (generation != _friendsGeneration || !_shouldConnectFriends) return;
      setState(() {
        _friendsConnected = true;
        _friendsError = null;
      });
      _sendNearbyLocation();
      if (generation != _friendsGeneration || !_shouldConnectFriends) return;
      // GPS가 정지한 상태에서도 새로 산책을 시작한 친구 목록을 재조회한다.
      _nearbyRefreshTimer?.cancel();
      _nearbyRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (generation == _friendsGeneration) _sendNearbyLocation();
      });
    } catch (error) {
      _friendsConnectionFailed(
        generation,
        message: error is ApiException ? error.message : null,
        retry: error is! ApiException || !error.isUnauthorized,
      );
    }
  }

  void _sendNearbyLocation() {
    final position = _lastPosition;
    final channel = _friendsChannel;
    if (!_shouldConnectFriends ||
        !_friendsConnected ||
        position == null ||
        channel == null)
      return;
    try {
      channel.sink.add(
        jsonEncode({
          'type': 'my_location',
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );
    } catch (_) {
      _friendsConnectionFailed(_friendsGeneration);
    }
  }

  void _receiveFriendLocation(dynamic message) {
    try {
      final dynamic decoded = message is String
          ? jsonDecode(message)
          : message is List<int>
          ? jsonDecode(utf8.decode(message))
          : message;
      if (decoded is! Map) return;
      final json = Map<String, dynamic>.from(decoded);
      if (json['type'] == 'error') {
        setState(() {
          _nearbyFriends.clear();
          _friendsError = json['message']?.toString() ?? '주변 친구 조회에 실패했습니다.';
        });
        return;
      }
      if (json['type'] != 'nearby_friends') return;
      final rows = json['friends'];
      if (rows is! List) throw const FormatException('friends 배열이 없습니다.');
      final byUser = <int, FriendLocation>{};
      var invalidRows = false;
      for (final row in rows) {
        try {
          if (row is! Map) throw const FormatException('친구 형식 오류');
          // latitude/longitude는 기존 좌표 명세의 필드 사용.
          // nearby 응답에 다른 구조를 쓰는지는 전체 응답으로 확인해야 한다.
          final friend = FriendLocation.fromJson(
            Map<String, dynamic>.from(row),
          );
          if (friend.userId == _currentUserId) continue;
          if (friend.userId <= 0 ||
              !friend.latitude.isFinite ||
              !friend.longitude.isFinite ||
              friend.latitude.abs() > 90 ||
              friend.longitude.abs() > 180) {
            throw const FormatException('친구 좌표 오류');
          }
          byUser[friend.userId] = friend;
        } catch (_) {
          invalidRows = true;
        }
      }
      setState(() {
        // 전체 목록으로 교체: 종료/공유 해제/반경 밖 친구의 이전 핀도 제거.
        _nearbyFriends = byUser.values.toList();
        _friendsRetryCount = 0;
        _friendsError = invalidRows ? '친구 좌표 응답 형식을 확인해야 합니다.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _nearbyFriends.clear();
        _friendsError = '주변 친구 응답 형식을 확인해야 합니다.';
      });
    }
  }

  void _friendsConnectionFailed(
    int generation, {
    String? message,
    bool retry = true,
  }) {
    if (generation != _friendsGeneration || !mounted) return;
    _stopFriendsConnection(resetRetry: false);
    setState(() {
      _nearbyFriends.clear();
      _friendsError = message ?? '친구 위치 연결이 끊겼습니다. 재연결 중…';
    });
    if (!retry || !_shouldConnectFriends) return;
    final seconds = _friendsRetryCount < 4 ? 2 << _friendsRetryCount : 30;
    _friendsRetryCount++;
    _friendsRetryTimer = Timer(Duration(seconds: seconds), () {
      _friendsRetryTimer = null;
      if (_shouldConnectFriends) unawaited(_connectFriends());
    });
  }

  void _stopFriendsConnection({bool resetRetry = true}) {
    // 이미 닫힌 연결의 지연 콜백은 새 연결에 영향을 주지 않는다.
    _friendsGeneration++;
    _nearbyRefreshTimer?.cancel();
    _nearbyRefreshTimer = null;
    _friendsRetryTimer?.cancel();
    _friendsRetryTimer = null;
    final subscription = _friendsSubscription;
    final channel = _friendsChannel;
    _friendsSubscription = null;
    _friendsChannel = null;
    _friendsConnected = false;
    if (resetRetry) _friendsRetryCount = 0;
    if (subscription != null)
      unawaited(subscription.cancel().catchError((Object _) {}));
    if (channel != null)
      unawaited(
        channel.sink.close().then<void>(
          (_) {},
          onError: (Object _, StackTrace __) {},
        ),
      );
  }

  void _retryFriendsConnection() {
    _stopFriendsConnection();
    _syncFriendsConnection();
  }

  Future<void> _toggleLocationShare() async {
    final walkId = _walkId;
    if (_isTogglingLocation || _isEnding || walkId == null) return;
    final newStatus = !_isLocationShared;
    setState(() {
      _isTogglingLocation = true;
    });

    try {
      final res = await ApiService.updateLocationShareStatus(walkId, newStatus);
      if (mounted) {
        // 서버가 상태를 반환하면 그 값을 우선 사용한다.
        final data = res['data'] is Map ? res['data'] as Map : res;
        final confirmedStatus = data['is_location_shared'];
        setState(() {
          _isLocationShared = confirmedStatus is bool
              ? confirmedStatus
              : newStatus;
        });
        _syncFriendsConnection();
        final msg =
            res['message']?.toString() ??
            (_isLocationShared ? '위치 공유가 켜졌습니다.' : '위치 공유가 꺼졌습니다.');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF386628),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('위치 공유 변경 실패: $e');
      if (mounted) {
        // 실패한 요청을 성공한 것처럼 표시하지 않는다.
        if (e is ApiException && e.statusCode >= 500) {
          _showError(
            ApiException(
              e.statusCode,
              '위치 공유 변경 중 서버 오류(${e.statusCode})가 발생했습니다. '
              '서버 오류 로그를 확인해야 합니다.',
            ),
          );
        } else {
          _showError(e);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingLocation = false);
        if (_exitRequested) unawaited(_leaveWalk());
      }
    }
  }

  Future<void> _checkPermissionAndStartTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateFriendsNearby();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateFriendsNearby();
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _updateFriendsNearby();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted || _walkFinished) return;
      if (!_isEnding) _updateLocation(position);

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3,
            ),
          ).listen(
            (Position newPosition) {
              if (_isWalking && !_isEnding && !_walkFinished && mounted) {
                _updateLocation(newPosition);
              }
            },
            onError: (Object error) {
              _showError(error, fallback: '위치 정보를 받지 못했습니다. GPS 상태를 확인해주세요.');
            },
          );
    } catch (e) {
      debugPrint('위치 트래킹 오류: $e');
      _updateFriendsNearby();
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

    _queueLocation(position);
    _sendNearbyLocation();
    try {
      _mapController.move(_currentLatLng, 17.0);
    } catch (_) {}
  }

  void _updateFriendsNearby() {
    if (!ApiService.useMockData) return;
    if (_nearbyFriends.isEmpty) {
      _nearbyFriends = [
        FriendLocation(
          userId: 1,
          name: '토리',
          latitude: _currentLatLng.latitude + 0.0006,
          longitude: _currentLatLng.longitude + 0.0006,
          profileImage: null,
        ),
        FriendLocation(
          userId: 2,
          name: '초코',
          latitude: _currentLatLng.latitude - 0.0005,
          longitude: _currentLatLng.longitude + 0.0004,
          profileImage: null,
        ),
      ];
    }
  }

  void _queueLocation(Position position) {
    if (_walkId == null || _isEnding || _walkFinished) return;
    // 통신이 느릴 때 무한히 쌓지 않고 다음 저장에는 최신 좌표를 사용한다.
    _pendingPosition = position;
    if (_isSavingLocation) return;
    _isSavingLocation = true;
    _locationWrites = _flushLocations();
  }

  Future<void> _flushLocations() async {
    final walkId = _walkId!;
    try {
      while (_pendingPosition != null && mounted && !_walkFinished) {
        final position = _pendingPosition!;
        _pendingPosition = null;
        try {
          await ApiService.recordWalkLocation(
            walkId,
            position.latitude,
            position.longitude,
          );
          _hasLocationError = false;
        } catch (e) {
          if (mounted && !_hasLocationError) {
            _hasLocationError = true;
            _showError(e, fallback: '경로 저장에 실패했습니다. 연결 상태를 확인해주세요.');
          }
        }
      }
    } finally {
      _isSavingLocation = false;
    }
  }

  Future<void> _goToLogin() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showError(Object error, {String? fallback}) {
    if (!mounted) return;
    final needsLogin = error is ApiException && error.isUnauthorized;
    final message = needsLogin
        ? '로그인이 만료되었습니다. 다시 로그인해주세요.'
        : error is ApiException
        ? error.message
        : fallback ?? '서버와 연결하지 못했습니다. 다시 시도해주세요.';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 8),
        action: needsLogin
            ? SnackBarAction(label: '로그인', onPressed: _goToLogin)
            : null,
      ),
    );
  }

  Future<void> _initWalkSession() async {
    if (_isStarting || _walkId != null) return;
    setState(() {
      _isStarting = true;
      _startError = null;
    });
    try {
      final walkData = await ApiService.startWalk(
        petId: widget.petId,
        isLocationShared: _isLocationShared,
        closeBlockingWalk: true,
      );
      if (!mounted) return;
      setState(() {
        _walkId = walkData.id;
        _isStarting = false;
        _isWalking = true;
        _isLocationShared = walkData.isLocationShared;
        _seconds = walkData.totalDuration;
        _distance = walkData.totalDistance;
      });
      _startTimer();
      if (_exitRequested) {
        await _handleEndWalk(leaveScreen: true);
        if (!mounted || _walkFinished) return;
      }
      _syncFriendsConnection();
      await _checkPermissionAndStartTracking();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isWalking = false;
        _startError = e is ApiException
            ? e.message
            : '산책을 시작하지 못했습니다. 연결 상태를 확인해주세요.';
      });
      _showError(e);
      _exitRequested = false;
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isWalking && !_isEnding && !_walkFinished && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _popAfterCleanup() {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    // PopScope에 새 canPop 값을 반영하고, 내비게이터 콜백 밖에서 나간다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _leaveWalk() async {
    if (!mounted || _allowPop) return;
    _exitRequested = true;
    // 시작/공유 변경 응답을 먼저 확인한 뒤 실제 ID로 종료한다.
    if (_isStarting || _isTogglingLocation || _isEnding) return;
    if (_walkId == null || _walkFinished) {
      _popAfterCleanup();
      return;
    }
    await _handleEndWalk(leaveScreen: true);
  }

  Future<void> _handleEndWalk({bool leaveScreen = false}) async {
    final walkId = _walkId;
    if (_isEnding || _isTogglingLocation || walkId == null) return;
    setState(() => _isEnding = true);
    // 타이머/스트림은 유지하고 입력만 잠근다. 실패하면 즉시 추적을 재개한다.
    try {
      await _locationWrites;
      WalkReportData? report;
      if (_endOutcomeUnknown) {
        report = await ApiService.getFinishedWalkReport(
          walkId,
          fallbackDistance: _distance,
          fallbackDuration: _formatDuration(_seconds),
        );
        _endOutcomeUnknown = false;
      }
      report ??= await ApiService.endWalk(
        walkId,
        currentDistance: _distance,
        currentDurationStr: _formatDuration(_seconds),
        currentDurationSeconds: _seconds,
      );
      if (!mounted) return;
      _walkFinished = true;
      _isWalking = false;
      _stopFriendsConnection();
      _timer?.cancel();
      await _positionStreamSubscription?.cancel();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (leaveScreen || _exitRequested) {
        _popAfterCleanup();
        return;
      }
      final completedReport = report;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WalkReportScreen(reportData: completedReport),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // 응답 유실/5xx는 서버가 이미 종료했을 수 있으므로 다음 시도에 조회한다.
      if (e is! ApiException || e.statusCode >= 500) _endOutcomeUnknown = true;
      _lastPosition = null;
      _exitRequested = false;
      setState(() => _isEnding = false);
      _showError(e, fallback: '종료 결과를 확인하지 못했습니다. 다시 누르면 서버 상태를 확인합니다.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopFriendsConnection();
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}분 ${sec.toString().padLeft(2, '0')}초';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_leaveWalk());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9E5),
        body: SizedBox.expand(
          child: Stack(
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.walk_guide_frontend',
                    ),
                    if (_routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: const Color(0xFF86B453).withOpacity(0.85),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLatLng,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF86B453),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
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
                        if (_isLocationShared)
                          ..._nearbyFriends.map((friend) {
                            return Marker(
                              point: ll.LatLng(
                                friend.latitude,
                                friend.longitude,
                              ),
                              width: 68,
                              height: 94,
                              alignment: Alignment.topCenter,
                              child: KeyedSubtree(
                                key: ValueKey(friend.userId),
                                child: _buildDropPinMarker(
                                  friend.name,
                                  friend.profileImage,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ],
                ),
              ),

              if (_startError != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 72,
                  left: 20,
                  right: 20,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_startError!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: _isStarting ? null : _initWalkSession,
                            child: const Text('산책 시작 다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 2. 상단 뒤로가기 버튼
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF496B31),
                      ),
                      onPressed: _isEnding ? null : _leaveWalk,
                    ),
                  ),
                ),
              ),

              if (_isLocationShared &&
                  _walkId != null &&
                  !ApiService.useMockData)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 156,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _friendsError ??
                              (_friendsConnected
                                  ? '친구 위치 연결됨 · ${_nearbyFriends.length}명'
                                  : '친구 위치 연결 중…'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475E33),
                          ),
                        ),
                      ),
                      if (_friendsError != null)
                        TextButton(
                          onPressed: _retryFriendsConnection,
                          child: const Text('다시 연결'),
                        ),
                    ],
                  ),
                ),

              // 3. 위치 공유 토글 버튼 ("위치기능 On" / "위치기능 Off")
              Positioned(
                left: 24,
                bottom: 126,
                child: GestureDetector(
                  onTap: _walkId == null || _isEnding || _isTogglingLocation
                      ? null
                      : _toggleLocationShare,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Toggle Switch Capsule
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _isLocationShared
                              ? const Color(0xFFB5CF9B)
                              : const Color(0xFFB5B3A4),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: _isLocationShared
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_isTogglingLocation) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF475E33),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      // Text Label outside switch
                      Text(
                        _isLocationShared ? '위치기능 On' : '위치기능 Off',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isLocationShared
                              ? const Color(0xFF475E33)
                              : const Color(0xFF4A493F),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. 하단 컨트롤 카드
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(42),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
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
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
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
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            _walkId == null || _isEnding || _isTogglingLocation
                            ? null
                            : () => _handleEndWalk(),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFF86B453),
                            shape: BoxShape.circle,
                          ),
                          child: _isEnding || _isStarting
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
                                  Icons.stop_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            child: Center(child: _buildDogImage(imageUrl, name)),
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

  Widget _buildDogImage(String? imageUrl, String name) {
    if ((imageUrl == null || imageUrl.isEmpty) && !ApiService.useMockData) {
      return const Icon(Icons.pets, size: 24, color: Color(0xFF3F6634));
    }
    final Map<String, String> nameMap = {
      '초코': 'poodle.png',
      '밀크': 'samoyed.png',
      '토리': 'corgi.png',
      '휴지': 'bichon.png',
    };

    final fileName = nameMap[name] ?? 'maltese.png';

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            imageUrl,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/dogs/$fileName',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
        );
      }
    }
    return Image.asset(
      'assets/dogs/$fileName',
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.pets, size: 24, color: Color(0xFF3F6634)),
    );
  }
}

class PinDropShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F6634)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.22)
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
