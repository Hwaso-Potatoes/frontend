import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/friend_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// -----------------------------------------------------------------------------
// [1. 홈 화면 대시보드 모델]
// -----------------------------------------------------------------------------
class PetMissionItem {
  final int id;
  final int missionId;
  final String title;
  final int currentValue;
  final int requiredCount;
  final int rewardExperience;
  final String status;

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

class FriendDogDisplay {
  final String name;
  final String? profileImage;
  final double? distanceMeters;

  FriendDogDisplay({
    required this.name,
    this.profileImage,
    this.distanceMeters,
  });
}

class HomeDashboardResponse {
  final String userName;
  final int petId;
  final String petName;
  final String petBreed;
  final int petAge;
  final int petLevel;
  final String? petImageUrl;
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
    this.petImageUrl,
    required this.petPersonalities,
    required this.targetDistance,
    required this.currentDistance,
    required this.walkingFriends,
    required this.dailyMissions,
  });
}

// -----------------------------------------------------------------------------
// [2. 산책 시작/종료 응답 모델]
// -----------------------------------------------------------------------------
class WalkData {
  final int id;
  final int userId;
  final int? petId;
  final String status;
  final bool isLocationShared;
  final String startTime;
  final String? endTime;
  final double totalDistance;
  final int totalDuration;
  final int totalPausedSeconds;
  final String pausedTimeStr;
  final String totalDurationStr;

  WalkData({
    required this.id,
    required this.userId,
    this.petId,
    required this.status,
    required this.isLocationShared,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
    required this.totalDuration,
    required this.totalPausedSeconds,
    required this.pausedTimeStr,
    required this.totalDurationStr,
  });

  factory WalkData.fromJson(Map<String, dynamic> json) {
    return WalkData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user'] is int
          ? json['user']
          : int.tryParse(json['user']?.toString() ?? '0') ?? 0,
      petId: json['pet'] is int
          ? json['pet']
          : int.tryParse(json['pet']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'FINISHED',
      isLocationShared: json['is_location_shared'] ?? false,
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString(),
      totalDistance: (json['total_distance'] is num)
          ? (json['total_distance'] as num).toDouble()
          : double.tryParse(json['total_distance']?.toString() ?? '0.0') ?? 0.0,
      totalDuration: json['total_duration'] is int
          ? json['total_duration']
          : int.tryParse(json['total_duration']?.toString() ?? '0') ?? 0,
      totalPausedSeconds: json['total_paused_seconds'] is int
          ? json['total_paused_seconds']
          : int.tryParse(json['total_paused_seconds']?.toString() ?? '0') ?? 0,
      pausedTimeStr: json['paused_time_str']?.toString() ?? '0초',
      totalDurationStr: json['total_duration_str']?.toString() ?? '0초',
    );
  }
}

// -----------------------------------------------------------------------------
// [3. 산책 리포트 뱃지 & 종합 데이터 모델]
// -----------------------------------------------------------------------------
class BadgeData {
  final String title;
  final String description;
  final String tagLabel;

  BadgeData({
    required this.title,
    required this.description,
    required this.tagLabel,
  });

  factory BadgeData.fromJson(Map<String, dynamic> json) {
    return BadgeData(
      title: json['title']?.toString() ?? '새로운 뱃지 획득!',
      description: json['description']?.toString() ?? '도감에 새로운 뱃지가 추가되었습니다.',
      tagLabel: json['tag_label']?.toString() ?? 'Day 1',
    );
  }
}

class WalkReportData {
  final String petName;
  final double totalDistance;
  final String totalDurationStr;
  final int calories;
  final int earnedExp;
  final int expToNextLevel;
  final double expRatio;
  final BadgeData? newBadge;

  WalkReportData({
    required this.petName,
    required this.totalDistance,
    required this.totalDurationStr,
    required this.calories,
    required this.earnedExp,
    required this.expToNextLevel,
    required this.expRatio,
    this.newBadge,
  });

  factory WalkReportData.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>? ?? {};
    final walk = json['walk'] as Map<String, dynamic>? ?? json;

    final double distance = (walk['total_distance'] is num)
        ? (walk['total_distance'] as num).toDouble()
        : double.tryParse(walk['total_distance']?.toString() ?? '0.0') ?? 0.0;

    final int expGained = walk['earned_exp'] is int
        ? walk['earned_exp']
        : int.tryParse(walk['earned_exp']?.toString() ?? '24') ?? 24;

    final int nextExp = pet['exp_to_next_level'] is int
        ? pet['exp_to_next_level']
        : int.tryParse(pet['exp_to_next_level']?.toString() ?? '22') ?? 22;

    final int currentExp = pet['current_exp'] is int
        ? pet['current_exp']
        : int.tryParse(pet['current_exp']?.toString() ?? '72') ?? 72;

    final int maxExp = pet['max_exp'] is int
        ? pet['max_exp']
        : int.tryParse(pet['max_exp']?.toString() ?? '100') ?? 100;

    final double calculatedRatio = maxExp > 0
        ? (currentExp / maxExp).clamp(0.0, 1.0)
        : 0.72;

    return WalkReportData(
      petName: pet['name']?.toString() ?? json['pet_name']?.toString() ?? '두부',
      totalDistance: distance,
      totalDurationStr: walk['total_duration_str']?.toString() ?? '00분 00초',
      calories: walk['calories'] is int
          ? walk['calories']
          : int.tryParse(walk['calories']?.toString() ?? '') ??
                (distance * 55).toInt().clamp(0, 999),
      earnedExp: expGained,
      expToNextLevel: nextExp,
      expRatio: calculatedRatio,
      newBadge: json['new_badge'] != null
          ? BadgeData.fromJson(json['new_badge'])
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// [API 공통 예외] - 상태코드를 화면까지 전달해서 401이면 재로그인 유도
// -----------------------------------------------------------------------------
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// -----------------------------------------------------------------------------
// [4. ApiService 메인 클래스]
// -----------------------------------------------------------------------------
class ApiService {
  static const String baseUrl = kApiBaseUrl;
  static const bool useMockData = kUseMockData;

  static const storage = FlutterSecureStorage();

  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';
  static const String _kUserId = 'user_id';
  static const String _kPetId = 'pet_id';

  // ---------------------------------------------------------------------------
  // [인증 세션 관리]
  // ---------------------------------------------------------------------------

  /// 로그인/회원가입 성공 시 토큰 저장. userId가 응답에 없으면 JWT payload의
  /// user_id 클레임(SimpleJWT 기본값)에서 꺼내 저장함.
  static Future<void> saveSession({
    required String? access,
    String? refresh,
    String? userId,
  }) async {
    if (access == null || access.isEmpty) return;
    await storage.write(key: _kAccessToken, value: access);
    if (refresh != null && refresh.isNotEmpty) {
      await storage.write(key: _kRefreshToken, value: refresh);
    }
    final id = userId ?? _userIdFromJwt(access);
    if (id != null) await storage.write(key: _kUserId, value: id);
    // 다른 계정으로 로그인했을 때 이전 계정의 반려견 id가 남지 않도록 초기화
    await storage.delete(key: _kPetId);
  }

  static Future<void> clearSession() async {
    await storage.delete(key: _kAccessToken);
    await storage.delete(key: _kRefreshToken);
    await storage.delete(key: _kUserId);
    await storage.delete(key: _kPetId);
  }

  static Future<String?> getAccessToken() => storage.read(key: _kAccessToken);

  static Future<String?> getUserId() async {
    final saved = await storage.read(key: _kUserId);
    if (saved != null && saved.isNotEmpty) return saved;
    final token = await getAccessToken();
    return token == null ? null : _userIdFromJwt(token);
  }

  static Future<void> savePetId(int petId) =>
      storage.write(key: _kPetId, value: petId.toString());

  /// JWT(header.payload.signature)의 payload에서 user_id 추출
  static String? _userIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final id = payload['user_id'] ?? payload['id'] ?? payload['sub'];
      return id?.toString();
    } catch (_) {
      return null;
    }
  }

  /// 공통 헤더. token을 직접 넘기면 그걸 쓰고, 아니면 저장된 access token을 사용.
  static Future<Map<String, String>> _headers({String? token}) async {
    final accessToken = token ?? await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  /// 상태코드 확인 후 UTF-8로 디코딩. (Django JSON 응답엔 charset이 없어서
  /// res.body를 그대로 쓰면 한글이 깨질 수 있음)
  static dynamic _decodeOrThrow(http.Response res, String label) {
    final text = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    String message = '$label 요청 실패 (${res.statusCode})';
    try {
      final body = jsonDecode(text);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }

  /// 리스트 응답이 그대로 오든, DRF 페이지네이션({results: [...]})이나
  /// {data: [...]} 형태로 오든 리스트로 꺼냄
  static List<dynamic> _asList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final inner = body['results'] ?? body['data'];
      if (inner is List) return inner;
    }
    return const [];
  }

  /// 저장된 pet_id가 없으면 GET api/pets/ 목록의 첫 번째 반려견을 사용
  static Future<int?> _resolvePetId(Map<String, String> headers) async {
    final saved = int.tryParse(await storage.read(key: _kPetId) ?? '');
    if (saved != null) return saved;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/pets/'),
        headers: headers,
      );
      final pets = _asList(_decodeOrThrow(res, '반려견 목록'));
      if (pets.isEmpty) return null;
      final id = int.tryParse(pets.first['id']?.toString() ?? '');
      if (id != null) await savePetId(id);
      return id;
    } on ApiException catch (e) {
      if (e.isUnauthorized) rethrow;
      return null;
    }
  }

  static const Map<String, String> _personalityLabels = {
    'energy': '에너지형',
    'social': '사회성형',
    'timid': '겁쟁이형',
    'curious': '호기심형',
    'relaxed': '느긋형',
    'calm': '얌전형',
  };

  static int _ageFrom(Map<String, dynamic> pet) {
    if (pet['age'] is int) return pet['age'];
    final birth = DateTime.tryParse(pet['birth_date']?.toString() ?? '');
    if (birth == null) return 1;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }

  // [홈 화면 종합 데이터 로드]
  // userId/petId를 넘기지 않으면 저장된 로그인 정보에서 꺼내 씀
  // (기존엔 '1'로 하드코딩되어 있어서 다른 계정이면 남의 데이터를 요청하게 됨)
  static Future<HomeDashboardResponse> getHomeDashboardData({
    String? userId,
    int? petId,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return HomeDashboardResponse(
        userName: '예은님',
        petId: petId ?? 1,
        petName: '두부',
        petBreed: '말티즈',
        petAge: 2,
        petLevel: 1,
        petImageUrl: null,
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

    try {
      final headers = await _headers();
      if (!headers.containsKey('Authorization')) {
        throw ApiException(401, '로그인 정보가 없습니다. 다시 로그인해주세요.');
      }

      final resolvedUserId = userId ?? await getUserId();
      if (resolvedUserId == null) {
        throw ApiException(401, '사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }
      final resolvedPetId = petId ?? await _resolvePetId(headers);
      if (resolvedPetId == null) {
        throw ApiException(404, '등록된 반려견을 찾을 수 없습니다.');
      }

      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/api/users/$resolvedUserId/'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$baseUrl/api/pets/$resolvedPetId/'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$baseUrl/api/pets/$resolvedPetId/missions/?period=DAILY'),
          headers: headers,
        ),
        http.get(Uri.parse('$baseUrl/api/friends/'), headers: headers),
      ]);

      // 사용자/반려견 정보는 필수 → 실패하면 에러
      final userData =
          _decodeOrThrow(responses[0], '사용자 정보') as Map<String, dynamic>;
      final petData =
          _decodeOrThrow(responses[1], '반려견 정보') as Map<String, dynamic>;

      // 미션/친구는 부가 정보 → 401이 아니면 실패해도 빈 목록으로 홈은 띄움
      List<dynamic> optionalList(http.Response res, String label) {
        try {
          return _asList(_decodeOrThrow(res, label));
        } on ApiException catch (e) {
          if (e.isUnauthorized) rethrow;
          return const [];
        }
      }

      final missionList = optionalList(responses[2], '미션')
          .map((m) => PetMissionItem.fromJson(m as Map<String, dynamic>))
          .toList();
      final friendList = optionalList(responses[3], '친구').map((f) {
        // GET api/friends/ 응답: { id, nickname, pets: [{ id, name, breed }] }
        final pets = f['pets'];
        final firstPet = (pets is List && pets.isNotEmpty) ? pets.first : null;
        return FriendDogDisplay(
          name:
              firstPet?['name']?.toString() ??
              f['pet_name']?.toString() ??
              f['nickname']?.toString() ??
              '친구',
          profileImage: resolveMediaUrl(
            (firstPet?['profile_image'] ?? f['profile_image_url'])?.toString(),
          ),
        );
      }).toList();

      final rawPersonalities = petData['personalities'];
      final personalities = rawPersonalities is List
          ? rawPersonalities
                .map((p) => _personalityLabels[p.toString()] ?? p.toString())
                .toList()
          : <String>[];

      return HomeDashboardResponse(
        userName: userData['nickname']?.toString() ?? '보호자님',
        petId: petData['id'] ?? resolvedPetId,
        petName: petData['name']?.toString() ?? '반려견',
        petBreed: petData['breed']?.toString() ?? '견종',
        petAge: _ageFrom(petData),
        petLevel: petData['level'] ?? 1,
        petImageUrl: resolveMediaUrl(petData['profile_image']?.toString()),
        petPersonalities: personalities,
        targetDistance: (petData['target_distance'] as num?)?.toDouble() ?? 2.0,
        currentDistance:
            (petData['current_distance'] as num?)?.toDouble() ?? 0.0,
        walkingFriends: friendList,
        dailyMissions: missionList,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('홈 데이터 로드 실패: $e');
    }
  }

  // [산책 시작 API]
  static Future<WalkData> startWalk({
    int? petId,
    bool isLocationShared = true,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return WalkData(
        id: 3,
        userId: 1,
        petId: petId,
        status: 'WALKING',
        isLocationShared: isLocationShared,
        startTime: DateTime.now().toIso8601String(),
        totalDistance: 0.0,
        totalDuration: 0,
        totalPausedSeconds: 0,
        pausedTimeStr: '0초',
        totalDurationStr: '0초',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/walks/start/'),
        headers: await _headers(),
        body: jsonEncode({
          'pet': petId,
          'is_location_shared': isLocationShared,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalkData.fromJson(body['data']);
      }
      throw Exception(body['message'] ?? '산책 시작 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [산책 종료 API]
  static Future<WalkReportData> endWalk(
    int walkId, {
    double? currentDistance,
    String? currentDurationStr,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final double distance = currentDistance ?? 1.8;
      return WalkReportData(
        petName: '두부',
        totalDistance: distance,
        totalDurationStr: currentDurationStr ?? '32분 25초',
        calories: (distance * 55).toInt().clamp(0, 999),
        earnedExp: 24,
        expToNextLevel: 22,
        expRatio: 0.72,
        newBadge: BadgeData(
          title: '새로운 뱃지 획득!',
          description: "뱃지 '첫 발걸음'이 도감에 추가되었어요.",
          tagLabel: 'Day 1',
        ),
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/walks/$walkId/end/'),
        headers: await _headers(),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalkReportData.fromJson(body['data'] ?? body);
      }
      throw Exception(body['message'] ?? '산책 종료 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [산책 중 위치 공유 토글 API (PATCH api/walks/:walk_id/location-share/)]
  static Future<Map<String, dynamic>> updateLocationShareStatus(
    int walkId,
    bool isLocationShared, {
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'message': isLocationShared ? '위치 공유가 켜졌습니다.' : '위치 공유가 꺼졌습니다.',
        'data': {
          'walk_id': walkId,
          'is_location_shared': isLocationShared,
          'changed': true,
        },
      };
    }

    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/walks/$walkId/location-share/'),
        headers: await _headers(token: token),
        body: jsonEncode({'is_location_shared': isLocationShared}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception('위치 공유 토글 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [산책 중 상태 변경 API (PATCH api/walks/:walk_id/)] - "WALKING", "PAUSED", "FINISHED"
  static Future<Map<String, dynamic>> updateWalkStatus(
    int walkId,
    String status, {
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'message': '산책 상태가 변경되었습니다.',
        'data': {'id': walkId, 'status': status, 'changed': true},
      };
    }

    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/walks/$walkId/'),
        headers: await _headers(token: token),
        body: jsonEncode({'status': status}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception('산책 상태 변경 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [산책 경로 위치 저장 API (POST api/walks/:walk_id/locations/)]
  static Future<Map<String, dynamic>> recordWalkLocation(
    int walkId,
    double latitude,
    double longitude, {
    String? token,
  }) async {
    if (useMockData) {
      return {
        'message': '1개의 위치 정보가 추가되었습니다.',
        'current_total_distance_km': 0.02,
      };
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/walks/$walkId/locations/'),
        headers: await _headers(token: token),
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      throw Exception('위치 저장 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [산책 상세 조회 API (GET api/walks/:walk_id/)]
  static Future<Map<String, dynamic>> getWalkDetails(
    int walkId, {
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'id': walkId,
        'user': 1,
        'status': 'WALKING',
        'is_location_shared': true,
        'total_distance': 1.8,
        'total_duration': 1945,
        'total_paused_seconds': 0,
        'paused_time_str': '0초',
        'total_duration_str': '32분 25초',
      };
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/walks/$walkId/'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('산책 상세 정보 조회 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [일반 로그인 API]
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      await saveSession(
        access: 'mock_access_token',
        refresh: 'mock_refresh_token',
        userId: '1',
      );
      return {
        'success': true,
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final bool success = response.statusCode == 200;
      // 기존엔 토큰을 받기만 하고 어디에도 저장하지 않아서
      // 이후 모든 API가 Authorization 없이 나가 401이 발생했음
      if (success) {
        await saveSession(
          access: data['access']?.toString(),
          refresh: data['refresh']?.toString(),
          userId: data['user_id']?.toString(),
        );
      }
      return {
        'success': success,
        'access': data['access'],
        'refresh': data['refresh'],
        'user_id': data['user_id'],
        if (!success && data is Map && data['detail'] != null)
          'message': data['detail'].toString(),
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [소셜 로그인 API]
  static Future<Map<String, dynamic>> socialLogin(
    String provider,
    String accessToken,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
        'is_new': false, // UI 테스트용
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/social/${provider.toLowerCase()}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': accessToken}),
      );
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final bool success = response.statusCode == 200;
      if (success) {
        await saveSession(
          access: data['access']?.toString(),
          refresh: data['refresh']?.toString(),
          userId: data['user_id']?.toString(),
        );
      }
      return {
        'success': success,
        'access': data['access'],
        'refresh': data['refresh'],
        'user_id': data['user_id'] ?? await getUserId(),
        'is_new': data['is_new'] ?? false,
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // 회원가입 - 1. 이메일 인증번호 요청 API
  static Future<Map<String, dynamic>> requestEmailVerification(
    String email,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register/email/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // 회원가입 - 2. 이메일 인증번호 확인 API
  static Future<Map<String, dynamic>> verifyEmailCode(
    String email,
    String code,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'verification_token': 'mock_verification_token'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register/email/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'verification_token': data['verification_token'],
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // 회원가입 - 3. 최종 회원가입 API (verification_token 포함)
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String passwordConfirm,
    String code,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'id': 1,
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'password2': passwordConfirm,
          'code': code,
        }),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'id': data['id'],
        'access': data['access'],
        'refresh': data['refresh'],
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // 로그인 전 비밀번호 찾기 (이메일로 재설정 링크 발송 API)
  static Future<Map<String, dynamic>> requestPasswordResetLink(
    String email,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true};
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return {'success': res.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  // [반려견 등록 API]
  static Future<Map<String, dynamic>> registerPet({
    required String accessToken,
    required String nickname,
    required String name,
    required String breed,
    required String birthDate,
    String? profileImagePath,
    List<String>? personalities,
  }) async {
    if (useMockData) return {'success': true};

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/pets/'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['nickname'] = nickname;
      request.fields['name'] = name;
      request.fields['breed'] = breed;
      request.fields['birth_date'] = birthDate;

      const personalityMap = {
        '에너지형': 'energy',
        '사회성형': 'social',
        '겁쟁이형': 'timid',
        '호기심형': 'curious',
        '느긋형': 'relaxed',
        '얌전형': 'calm',
      };

      if (personalities != null) {
        for (int i = 0; i < personalities.length; i++) {
          final personalityValue =
              personalityMap[personalities[i]] ?? personalities[i];

          request.fields['personalities[$i]'] = personalityValue;
        }
      }

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', profileImagePath),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      final bool success =
          response.statusCode == 200 || response.statusCode == 201;

      // 등록된 반려견 id를 저장해두면 홈 화면에서 pet_id를 하드코딩할 필요가 없음
      if (success) {
        try {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          final rawId = body is Map ? (body['id'] ?? body['data']?['id']) : null;
          final petId = int.tryParse(rawId?.toString() ?? '');
          if (petId != null) await savePetId(petId);
        } catch (_) {}
      }

      return {'success': success};
    } catch (e) {
      return {'success': false};
    }
  }

  // 로그인 전 메일 링크를 통한 비밀번호 재설정 확정 API
  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
    required String newPassword2,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true};
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/password-reset/confirm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'token': token,
          'new_password': newPassword,
          'new_password2': newPassword2,
        }),
      );
      return {'success': res.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  // -----------------------------------------------------------------------------
  // [출석 체크 관련 API 엔드포인트]
  // -----------------------------------------------------------------------------

  // 1. GET api/attendance/summary/ (출석 요약 및 보상 수령 여부)
  static Future<AttendanceSummaryResponse> getAttendanceSummary({
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return AttendanceSummaryResponse(
        currentStreak: 1,
        bestStreak: 1,
        today: AttendanceTodayItem(
          date: '2026-10-05',
          attended: true,
          isRewardDay: true,
          reward: AttendanceRewardItem(
            id: 1,
            attendanceDate: '2026-10-05',
            opened: false,
            openedAt: null,
            accessory: null,
          ),
        ),
        week: [
          AttendanceDayItem(
            date: '2026-09-28',
            attended: true,
            isRewardDay: false,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-09-29',
            attended: true,
            isRewardDay: false,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-09-30',
            attended: true,
            isRewardDay: false,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-10-01',
            attended: false,
            isRewardDay: false,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-10-02',
            attended: false,
            isRewardDay: true,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-10-03',
            attended: false,
            isRewardDay: false,
            rewardReceived: false,
          ),
          AttendanceDayItem(
            date: '2026-10-04',
            attended: false,
            isRewardDay: false,
            rewardReceived: false,
          ),
        ],
      );
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/attendance/summary/'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200) {
        return AttendanceSummaryResponse.fromJson(jsonDecode(res.body));
      }
      throw Exception('출석 요약 조회 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // 2. GET api/attendance/calendar/?year=year&month=month (월간 출석 달력)
  static Future<AttendanceCalendarResponse> getAttendanceCalendar({
    required int year,
    required int month,
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final List<int> attendedDaysList = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        11,
        12,
        13,
        14,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
      ];
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final days = List.generate(daysInMonth, (i) {
        final day = i + 1;
        final dateStr =
            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final isAttended = attendedDaysList.contains(day);
        return AttendanceDayItem(
          date: dateStr,
          attended: isAttended,
          isRewardDay: day == 5 || day == 12 || day == 19 || day == 26,
          rewardReceived: isAttended && (day == 5 || day == 12 || day == 19),
        );
      });
      return AttendanceCalendarResponse(year: year, month: month, days: days);
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/attendance/calendar/?year=$year&month=$month'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200) {
        return AttendanceCalendarResponse.fromJson(jsonDecode(res.body));
      }
      throw Exception('출석 달력 조회 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // 3. GET api/attendance/rewards/ (보상 목록)
  static Future<List<AttendanceRewardItem>> getAttendanceRewards({
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return [
        AttendanceRewardItem(
          id: 101,
          attendanceDate: '2026-10-01',
          opened: true,
          openedAt: '2026-10-01T10:00:00+09:00',
          accessory: AttendanceAccessoryItem(
            id: 1,
            name: '넥타이 케이프',
            image: null,
            category: 'CAPE',
          ),
        ),
        AttendanceRewardItem(
          id: 102,
          attendanceDate: '2026-09-30',
          opened: true,
          openedAt: '2026-09-30T10:00:00+09:00',
          accessory: AttendanceAccessoryItem(
            id: 2,
            name: '하트 핀',
            image: null,
            category: 'PIN',
          ),
        ),
        AttendanceRewardItem(
          id: 103,
          attendanceDate: '2026-09-29',
          opened: true,
          openedAt: '2026-09-29T10:00:00+09:00',
          accessory: AttendanceAccessoryItem(
            id: 3,
            name: '왕관',
            image: null,
            category: 'CROWN',
          ),
        ),
      ];
    }

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/attendance/rewards/'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((item) => AttendanceRewardItem.fromJson(item)).toList();
      }
      throw Exception('보상 목록 조회 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // 4. PATCH api/attendance/rewards/:reward_id/open/ (출석 보상 수령)
  static Future<AttendanceRewardItem> openAttendanceReward(
    int rewardId, {
    String? token,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return AttendanceRewardItem(
        id: rewardId,
        attendanceDate: '2026-10-05',
        opened: true,
        openedAt: DateTime.now().toIso8601String(),
        accessory: AttendanceAccessoryItem(
          id: 13,
          name: '하트 핀',
          image: 'http://localhost/media/accessories/IMG_2642_1.png',
          category: 'HAIR',
        ),
      );
    }

    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/attendance/rewards/$rewardId/open/'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return AttendanceRewardItem.fromJson(jsonDecode(res.body));
      }
      throw Exception('보상 수령 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [POST api/friends/qr/ - 나의 QR 생성 API]
  static Future<QrCodeGenerateResponse> generateMyQrCode({
    String? token,
  }) async {
    if (useMockData) {
      return mockGenerateMyQrCode();
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/friends/qr/'),
        headers: await _headers(token: token),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return QrCodeGenerateResponse.fromJson(data);
      }
      throw ApiException(res.statusCode, 'QR 코드 생성 실패');
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [POST api/friends/qr/redeem/ - QR 스캔 후 친구 추가 API]
  static Future<Friend> redeemQrCode(String qrToken, {String? token}) async {
    if (useMockData) {
      return mockRedeemQrCode(qrToken);
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/friends/qr/redeem/'),
        headers: await _headers(token: token),
        body: jsonEncode({'token': qrToken.trim()}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final friendJson = data['friend'] ?? data;
        return Friend.fromJson(friendJson);
      }
      String errorMsg = '친구 추가 실패';
      try {
        final errData = jsonDecode(utf8.decode(res.bodyBytes));
        if (errData is Map && errData['detail'] != null) {
          errorMsg = errData['detail'].toString();
        } else if (errData is Map && errData['message'] != null) {
          errorMsg = errData['message'].toString();
        }
      } catch (_) {}
      throw ApiException(res.statusCode, errorMsg);
    } catch (e) {
      throw Exception('서버 연결 실패: $e');
    }
  }

  // [토큰 갱신 API (POST api/users/token/refresh/)]
  static Future<String?> refreshAccessToken() async {
    final refresh = await storage.read(key: _kRefreshToken);
    if (refresh == null || refresh.isEmpty) return null;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final newAccess = data['access']?.toString();
        if (newAccess != null) {
          await storage.write(key: _kAccessToken, value: newAccess);
          return newAccess;
        }
      }
    } catch (_) {}
    return null;
  }

  // [내 반려견 목록 조회 API (GET api/pets/)]
  static Future<List<Map<String, dynamic>>> getMyPets() async {
    if (useMockData) {
      return [
        {
          'id': 1,
          'name': '두부',
          'breed': '말티즈',
          'level': 1,
          'experience': 0,
          'profile_image': null,
        }
      ];
    }
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/pets/'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final list = _asList(jsonDecode(utf8.decode(res.bodyBytes)));
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

// -----------------------------------------------------------------------------
// [5. 출석 관련 모델 데이터 클래스]
// -----------------------------------------------------------------------------
class AttendanceAccessoryItem {
  final int id;
  final String name;
  final String? image;
  final String? category;

  AttendanceAccessoryItem({
    required this.id,
    required this.name,
    this.image,
    this.category,
  });

  factory AttendanceAccessoryItem.fromJson(Map<String, dynamic> json) {
    return AttendanceAccessoryItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      category: json['category']?.toString(),
    );
  }
}

class AttendanceRewardItem {
  final int id;
  final String attendanceDate;
  final bool opened;
  final String? openedAt;
  final AttendanceAccessoryItem? accessory;

  AttendanceRewardItem({
    required this.id,
    required this.attendanceDate,
    required this.opened,
    this.openedAt,
    this.accessory,
  });

  factory AttendanceRewardItem.fromJson(Map<String, dynamic> json) {
    return AttendanceRewardItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      attendanceDate: json['attendance_date']?.toString() ?? '',
      opened: json['opened'] ?? false,
      openedAt: json['opened_at']?.toString(),
      accessory: json['accessory'] != null
          ? AttendanceAccessoryItem.fromJson(
              json['accessory'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AttendanceDayItem {
  final String date;
  final bool attended;
  final bool isRewardDay;
  final bool rewardReceived;

  AttendanceDayItem({
    required this.date,
    required this.attended,
    required this.isRewardDay,
    required this.rewardReceived,
  });

  factory AttendanceDayItem.fromJson(Map<String, dynamic> json) {
    return AttendanceDayItem(
      date: json['date']?.toString() ?? '',
      attended: json['attended'] ?? false,
      isRewardDay: json['is_reward_day'] ?? false,
      rewardReceived: json['reward_received'] ?? false,
    );
  }
}

class AttendanceTodayItem {
  final String date;
  final bool attended;
  final bool isRewardDay;
  final AttendanceRewardItem? reward;

  AttendanceTodayItem({
    required this.date,
    required this.attended,
    required this.isRewardDay,
    this.reward,
  });

  factory AttendanceTodayItem.fromJson(Map<String, dynamic> json) {
    return AttendanceTodayItem(
      date: json['date']?.toString() ?? '',
      attended: json['attended'] ?? false,
      isRewardDay: json['is_reward_day'] ?? false,
      reward: json['reward'] != null
          ? AttendanceRewardItem.fromJson(
              json['reward'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AttendanceSummaryResponse {
  final int currentStreak;
  final int bestStreak;
  final AttendanceTodayItem today;
  final List<AttendanceDayItem> week;

  AttendanceSummaryResponse({
    required this.currentStreak,
    required this.bestStreak,
    required this.today,
    required this.week,
  });

  factory AttendanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    final weekList = (json['week'] as List<dynamic>? ?? [])
        .map((e) => AttendanceDayItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AttendanceSummaryResponse(
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      today: AttendanceTodayItem.fromJson(
        json['today'] as Map<String, dynamic>? ?? {},
      ),
      week: weekList,
    );
  }
}

class AttendanceCalendarResponse {
  final int year;
  final int month;
  final List<AttendanceDayItem> days;

  AttendanceCalendarResponse({
    required this.year,
    required this.month,
    required this.days,
  });

  factory AttendanceCalendarResponse.fromJson(Map<String, dynamic> json) {
    final daysList = (json['days'] as List<dynamic>? ?? [])
        .map((e) => AttendanceDayItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return AttendanceCalendarResponse(
      year: json['year'] ?? 2026,
      month: json['month'] ?? 10,
      days: daysList,
    );
  }
}
