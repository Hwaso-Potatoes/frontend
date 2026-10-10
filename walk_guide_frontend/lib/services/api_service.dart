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
  final String breed;
  final double? distanceMeters;

  FriendDogDisplay({
    required this.name,
    this.profileImage,
    this.breed = '',
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
  final bool walkingFriendsStatusAvailable;
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
    this.walkingFriendsStatusAvailable = true,
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
      id: int.tryParse((json['id'] ?? json['walk_id'])?.toString() ?? '') ?? 0,
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
  final int? id;
  final String title; // 서버의 name; 기존 title 호출도 호환한다.
  final String description;
  final String tagLabel;
  final String? acquiredAt;

  BadgeData({
    this.id,
    required this.title,
    required this.description,
    this.tagLabel = '',
    this.acquiredAt,
  });

  factory BadgeData.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['title'])?.toString() ?? '배지';
    return BadgeData(
      id: int.tryParse(json['id']?.toString() ?? ''),
      title: name,
      description: json['description']?.toString() ?? '',
      tagLabel:
          json['tag_label']?.toString() ??
          (name == '첫 발자국' || name == '첫 발걸음' ? 'Day 1' : ''),
      acquiredAt: json['acquired_at']?.toString(),
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
  final List<BadgeData> acquiredBadges;
  // 기존 호출부가 newBadge를 사용해도 첫 배지에 접근할 수 있다.
  BadgeData? get newBadge =>
      acquiredBadges.isEmpty ? null : acquiredBadges.first;

  WalkReportData({
    required this.petName,
    required this.totalDistance,
    required this.totalDurationStr,
    required this.calories,
    required this.earnedExp,
    required this.expToNextLevel,
    required this.expRatio,
    BadgeData? newBadge,
    List<BadgeData>? acquiredBadges,
    this.hasExperienceData = true,
    this.hasCaloriesData = true,
    this.hasEarnedExperienceData = true,
  }) : acquiredBadges = List<BadgeData>.unmodifiable(
         acquiredBadges ?? (newBadge == null ? <BadgeData>[] : [newBadge]),
       );

  final bool hasExperienceData;
  final bool hasCaloriesData;
  final bool hasEarnedExperienceData;

  factory WalkReportData.fromJson(
    Map<String, dynamic> json, {
    double? fallbackDistance,
    String? fallbackDuration,
    String? fallbackPetName,
  }) {
    Map<String, dynamic> asMap(dynamic value) =>
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    int? asInt(dynamic value) => int.tryParse(value?.toString() ?? '');
    double? asDouble(dynamic value) => double.tryParse(value?.toString() ?? '');
    final fields = {...asMap(json['data']), ...json};
    final pet = asMap(fields['pet']);
    final nestedWalk = asMap(fields['walk']);
    final walk = nestedWalk.isEmpty ? fields : nestedWalk;
    final seconds = asInt(walk['total_duration']);
    final duration =
        walk['total_duration_str']?.toString() ??
        (seconds == null
            ? fallbackDuration ?? '00분 00초'
            : '${seconds ~/ 60}분 ${seconds % 60}초');
    final earned = asInt(
      fields['earned_experience'] ??
          fields['earned_exp'] ??
          walk['earned_experience'] ??
          walk['earned_exp'],
    );
    final next = asInt(pet['exp_to_next_level'] ?? fields['exp_to_next_level']);
    final current = asInt(pet['current_exp'] ?? fields['current_exp']);
    final max = asInt(pet['max_exp'] ?? fields['max_exp']);
    final suppliedRatio = asDouble(pet['exp_ratio'] ?? fields['exp_ratio']);
    final ratio =
        suppliedRatio ??
        (current != null && max != null && max > 0 ? current / max : null);
    final calories = asInt(walk['calories'] ?? fields['calories']);
    final badges = <BadgeData>[];
    final rawBadges = fields['acquired_badges'] ?? walk['acquired_badges'];
    if (rawBadges is List) {
      final seenIds = <int>{};
      for (final item in rawBadges) {
        if (item is! Map) continue;
        final badge = BadgeData.fromJson(Map<String, dynamic>.from(item));
        if (badge.id != null && !seenIds.add(badge.id!)) continue;
        badges.add(badge);
      }
    } else {
      // 기존 new_badge 응답만 있는 경우 호환. 명시적인 빈 배열은 보상 없음.
      final oldBadge = asMap(fields['new_badge'] ?? walk['new_badge']);
      if (oldBadge.isNotEmpty) badges.add(BadgeData.fromJson(oldBadge));
    }
    return WalkReportData(
      petName:
          pet['name']?.toString() ??
          fields['pet_name']?.toString() ??
          fallbackPetName ??
          '반려견',
      totalDistance:
          asDouble(walk['total_distance']) ?? fallbackDistance ?? 0.0,
      totalDurationStr: duration,
      calories: calories ?? 0,
      earnedExp: earned ?? 0,
      expToNextLevel: next ?? 0,
      expRatio: (ratio ?? 0.0).clamp(0.0, 1.0).toDouble(),
      hasExperienceData: earned != null && next != null && ratio != null,
      hasCaloriesData: calories != null,
      hasEarnedExperienceData: earned != null,
      acquiredBadges: badges,
    );
  }
}

// -----------------------------------------------------------------------------
// [API 공통 예외] - 상태코드를 화면까지 전달해서 401이면 재로그인 유도
// -----------------------------------------------------------------------------
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? responseBody;

  ApiException(this.statusCode, this.message, {this.responseBody});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// -----------------------------------------------------------------------------
// [4. ApiService 메인 클래스]
// -----------------------------------------------------------------------------
class ApiService {
  static Future<dynamic> requestData(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) => _authenticatedRequest(method, path, '정보 요청', body: body);

  static const String baseUrl = kApiBaseUrl;
  static const bool useMockData = kUseMockData;

  /// API의 상대 미디어 경로를 서버 origin 기준으로 해석한다.
  /// 앱 내부 asset 경로와 이미 완성된 HTTP(S) URL은 그대로 사용한다.
  static String? resolveMediaUrl(String? value) {
    final path = value?.trim();
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('assets/')) return path;
    final uri = Uri.tryParse(path);
    if (uri == null) return null;
    if (uri.hasScheme) {
      return uri.scheme == 'http' || uri.scheme == 'https'
          ? uri.toString()
          : null;
    }
    return Uri.parse(baseUrl).resolve('/').resolveUri(uri).toString();
  }

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
      return text.trim().isEmpty ? null : jsonDecode(text);
    }
    String message = '$label 요청 실패 (${res.statusCode})';
    Map<String, dynamic>? errorBody;
    try {
      final body = jsonDecode(text);
      if (body is Map) {
        errorBody = Map<String, dynamic>.from(body);
        final detail = body['detail'] ?? body['message'];
        message =
            detail?.toString() ??
            body.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        if (message.isEmpty) message = '$label 요청 실패 (${res.statusCode})';
      }
    } catch (_) {}
    throw ApiException(res.statusCode, message, responseBody: errorBody);
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
  static Future<int?> _resolvePetId() async {
    final saved = int.tryParse(await storage.read(key: _kPetId) ?? '');
    if (saved != null) return saved;
    try {
      final pets = _asList(
        await _authenticatedRequest('GET', '/api/pets/', '반려견 목록'),
      );
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
        walkingFriends: const [],
        walkingFriendsStatusAvailable: false,
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
      var access = await getAccessToken();
      if (access == null || access.isEmpty)
        access = await _refreshSessionToken();
      if (access == null || access.isEmpty) {
        throw ApiException(401, '로그인 정보가 없습니다. 다시 로그인해주세요.');
      }
      final resolvedUserId = userId ?? await getUserId();
      if (resolvedUserId == null) {
        throw ApiException(401, '사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      }
      final resolvedPetId = petId ?? await _resolvePetId();
      if (resolvedPetId == null) {
        throw ApiException(404, '등록된 반려견을 찾을 수 없습니다.');
      }

      var friendLookupFailed = false;
      // 부가 정보는 응답을 기다리고, 조회 실패 시 빈 목록을 사용한다.
      Future<List<dynamic>> optionalList(String path, String label) async {
        try {
          final body = await _authenticatedRequest('GET', path, label);
          return _asList(body);
        } on ApiException catch (e) {
          if (e.isUnauthorized) rethrow;
          if (path == '/api/friends/') friendLookupFailed = true;
          return const [];
        } catch (_) {
          if (path == '/api/friends/') friendLookupFailed = true;
          return const [];
        }
      }

      final responses = await Future.wait<dynamic>([
        _authenticatedRequest('GET', '/api/users/$resolvedUserId/', '사용자 정보'),
        _authenticatedRequest('GET', '/api/pets/$resolvedPetId/', '반려견 정보'),
        optionalList('/api/pets/$resolvedPetId/missions/?period=DAILY', '미션'),
        optionalList('/api/friends/', '친구'),
      ], eagerError: true);

      final userData = _walkMap(responses[0]);
      final petData = _walkMap(responses[1]);
      if (userData.isEmpty || petData.isEmpty) {
        throw ApiException(502, '사용자 또는 반려견 정보 응답이 비어 있습니다.');
      }
      final missionList = (responses[2] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(PetMissionItem.fromJson)
          .toList();
      final friendRows = (responses[3] as List<dynamic>);
      // 기존 명세에는 산책 상태가 없다. 아래 키는 백엔드 확인이 필요한
      // 연동 계약: is_walking_now(boolean). 누락/잘못된 타입은 상태 미확인.
      final walkingFriendsStatusAvailable =
          !friendLookupFailed &&
          friendRows.every((f) => f is Map && f['is_walking_now'] is bool);
      final friendList = <FriendDogDisplay>[];
      for (final row in friendRows) {
        if (row is! Map || row['is_walking_now'] != true) continue;
        final pets = row['pets'];
        final firstPet = pets is List && pets.isNotEmpty && pets.first is Map
            ? Map<String, dynamic>.from(pets.first as Map)
            : null;
        if (firstPet == null) continue;
        friendList.add(
          FriendDogDisplay(
            name: firstPet['name']?.toString() ?? '친구 반려견',
            breed: firstPet['breed']?.toString() ?? '',
            profileImage: resolveMediaUrl(
              firstPet['profile_image']?.toString(),
            ),
          ),
        );
      }

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
        walkingFriendsStatusAvailable: walkingFriendsStatusAvailable,
        dailyMissions: missionList,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(503, '홈 데이터를 불러오지 못했습니다. 연결 상태를 확인하고 다시 시도해주세요.');
    }
  }

  static Future<String?>? _refreshInFlight;

  static Future<String?> _refreshSessionToken() async {
    final running = _refreshInFlight;
    if (running != null) return running;
    final request = refreshAccessToken();
    _refreshInFlight = request;
    try {
      return await request;
    } finally {
      _refreshInFlight = null;
    }
  }

  /// 401에 한해 토큰을 갱신하고 한 번 재요청한다.
  /// 타임아웃/서버 오류에는 POST를 자동 재실행하지 않는다.
  static Future<dynamic> _authenticatedRequest(
    String method,
    String path,
    String label, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    var access = token ?? await getAccessToken();
    if (access == null || access.isEmpty) access = await _refreshSessionToken();
    if (access == null || access.isEmpty) {
      throw ApiException(401, '로그인 정보가 없습니다. 다시 로그인해주세요.');
    }
    Future<http.Response> send(String bearer) {
      Future<http.Response> perform() async {
        final request = http.Request(method, Uri.parse('$baseUrl$path'));
        request.headers.addAll(await _headers(token: bearer));
        if (body != null) request.body = jsonEncode(body);
        return http.Response.fromStream(await request.send());
      }

      return perform().timeout(const Duration(seconds: 25));
    }

    var response = await send(access);
    if (response.statusCode == 401) {
      final saved = await getAccessToken();
      // 명시적으로 다른 계정 토큰을 전달한 요청에 저장된 세션을 섞지 않는다.
      if (token == null || token == saved) {
        final fresh = saved != null && saved != access
            ? saved
            : await _refreshSessionToken();
        if (fresh != null && fresh.isNotEmpty) response = await send(fresh);
      }
    }
    return _decodeOrThrow(response, label);
  }

  static Map<String, dynamic> _walkMap(dynamic body) {
    if (body is! Map) return <String, dynamic>{};
    final data = body['data'];
    return Map<String, dynamic>.from(data is Map ? data : body);
  }

  static Map<String, dynamic> _walkResponseMap(dynamic body) =>
      body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

  static Future<Map<String, dynamic>> _withReportPet(
    Map<String, dynamic> data,
  ) async {
    data = {..._walkMap(data), ...data};
    final walk = _walkMap(data['walk'] ?? data);
    final reference = data['pet'] ?? walk['pet'];
    if (reference is Map || data['pet_name'] != null) return data;
    final petId = int.tryParse(reference?.toString() ?? '');
    if (petId == null || petId <= 0) return data;
    try {
      final pet = _walkMap(
        await _authenticatedRequest('GET', '/api/pets/$petId/', '반려견 정보'),
      );
      return {...data, 'pet': pet};
    } catch (_) {
      return data;
    }
  }

  // [산책 시작 API]
  static Future<WalkData> startWalk({
    int? petId,
    bool isLocationShared = true,
    bool closeBlockingWalk = false,
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

    var resolvedPetId =
        petId ?? int.tryParse(await storage.read(key: _kPetId) ?? '');
    if (resolvedPetId == null) {
      final pets = _asList(
        await _authenticatedRequest('GET', '/api/pets/', '반려견 목록'),
      );
      if (pets.isNotEmpty && pets.first is Map) {
        resolvedPetId = int.tryParse(pets.first['id']?.toString() ?? '');
        if (resolvedPetId != null) await savePetId(resolvedPetId);
      }
    }
    if (resolvedPetId == null || resolvedPetId <= 0) {
      throw ApiException(404, '등록된 반려견을 찾을 수 없습니다.');
    }
    Future<dynamic> requestStart() => _authenticatedRequest(
      'POST',
      '/api/walks/start/',
      '산책 시작',
      body: {'pet': resolvedPetId, 'is_location_shared': isLocationShared},
    );
    dynamic body;
    try {
      body = await requestStart();
    } on ApiException catch (error) {
      final conflict = _walkMap(error.responseBody);
      final activeId = int.tryParse(conflict['walk_id']?.toString() ?? '');
      final activeStatus = conflict['status'];
      if (!closeBlockingWalk ||
          (error.statusCode != 400 && error.statusCode != 409) ||
          activeId == null ||
          activeId <= 0 ||
          (activeStatus != 'WALKING' && activeStatus != 'PAUSED'))
        rethrow;

      // 이전 화면 이탈로 남은 세션만 서버가 알려준 ID로 정리한다.
      // 새 화면의 0 거리/시간으로 이전 산책 기록을 덮어쓰지 않는다.
      final details = _walkMap(await getWalkDetails(activeId));
      final oldWalk = WalkData.fromJson(_walkMap(details['walk'] ?? details));
      final ownUserId = int.tryParse(await getUserId() ?? '');
      if (oldWalk.id != activeId ||
          (oldWalk.userId > 0 && oldWalk.userId != ownUserId)) {
        throw ApiException(409, '이전 산책의 정보를 확인하지 못했습니다.');
      }
      if (oldWalk.status == 'WALKING' || oldWalk.status == 'PAUSED') {
        try {
          await endWalk(
            activeId,
            currentDistance: oldWalk.totalDistance,
            currentDurationSeconds: oldWalk.totalDuration,
            currentDurationStr: oldWalk.totalDurationStr,
          );
        } catch (_) {
          // 응답이 유실돼도 이미 종료됐다면 종료 요청을 반복하지 않는다.
          final finished = await getFinishedWalkReport(activeId);
          if (finished == null) rethrow;
        }
      } else if (oldWalk.status != 'FINISHED') {
        throw ApiException(409, '이전 산책 상태를 확인하지 못했습니다.');
      }
      // 무한 재시도 없이 한 번만 새 산책을 요청한다.
      body = await requestStart();
    }
    final data = _walkMap(body);
    final walk = WalkData.fromJson({
      'status': 'WALKING',
      'is_location_shared': isLocationShared,
      ..._walkMap(data['walk'] ?? data),
    });
    if (walk.id <= 0) {
      throw ApiException(502, '시작 응답에 산책 ID가 없습니다. 서버 응답을 확인해주세요.');
    }
    return walk;
  }

  // [산책 종료 API]
  static Future<WalkReportData> endWalk(
    int walkId, {
    double? currentDistance,
    String? currentDurationStr,
    int? currentDurationSeconds,
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
          title: '첫 발걸음',
          description: "뱃지 '첫 발걸음'이 도감에 추가되었어요.",
          tagLabel: 'Day 1',
        ),
      );
    }

    if (walkId <= 0) throw ArgumentError.value(walkId, 'walkId');
    final minMatch = RegExp(r'(\d+)분').firstMatch(currentDurationStr ?? '');
    final secMatch = RegExp(r'(\d+)초').firstMatch(currentDurationStr ?? '');
    final totalSeconds =
        currentDurationSeconds ??
        ((int.tryParse(minMatch?.group(1) ?? '') ?? 0) * 60 +
            (int.tryParse(secMatch?.group(1) ?? '') ?? 0));
    final body = await _authenticatedRequest(
      'POST',
      '/api/walks/$walkId/end/',
      '산책 종료',
      body: {
        'total_distance': currentDistance ?? 0.0,
        'total_duration': totalSeconds,
      },
    );
    // 종료 응답 최상위의 acquired_badges/earned_experience를 보존한다.
    var data = _walkResponseMap(body);
    final endedWalk = _walkMap(data['walk'] ?? data);
    // 성공한 종료 요청은 다시 보내지 않는다. 응답에 통계가 없으면 상세 조회.
    if (!endedWalk.containsKey('total_distance')) {
      try {
        final details = await getWalkDetails(walkId);
        data = {...data, 'walk': _walkMap(details['walk'] ?? details)};
      } catch (_) {
        // 종료 자체는 성공했다. 화면에서 측정한 거리/시간으로 리포트를 표시한다.
      }
    }
    return WalkReportData.fromJson(
      await _withReportPet(data),
      fallbackDistance: currentDistance,
      fallbackDuration:
          currentDurationStr ?? '${totalSeconds ~/ 60}분 ${totalSeconds % 60}초',
    );
  }

  /// 종료 응답이 유실된 경우 GET으로 종료 여부를 확인한 뒤 리포트를 복구한다.
  static Future<WalkReportData?> getFinishedWalkReport(
    int walkId, {
    double? fallbackDistance,
    String? fallbackDuration,
  }) async {
    final data = await getWalkDetails(walkId);
    final walk = _walkMap(data['walk'] ?? data);
    final status = walk['status'];
    if (status == 'WALKING' || status == 'PAUSED') return null;
    if (status != 'FINISHED') {
      throw ApiException(502, '산책 종료 상태를 확인하지 못했습니다. 서버 응답을 확인해주세요.');
    }
    return WalkReportData.fromJson(
      await _withReportPet(data),
      fallbackDistance: fallbackDistance,
      fallbackDuration: fallbackDuration,
    );
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

    if (walkId <= 0) throw ArgumentError.value(walkId, 'walkId');
    return _walkResponseMap(
      await _authenticatedRequest(
        'PATCH',
        '/api/walks/$walkId/location-share/',
        '위치 공유 변경',
        token: token,
        body: {'is_location_shared': isLocationShared},
      ),
    );
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

    if (walkId <= 0) throw ArgumentError.value(walkId, 'walkId');
    if (!['WALKING', 'PAUSED', 'FINISHED'].contains(status)) {
      throw ArgumentError.value(status, 'status');
    }
    return _walkMap(
      await _authenticatedRequest(
        'PATCH',
        '/api/walks/$walkId/',
        '산책 상태 변경',
        token: token,
        body: {'status': status},
      ),
    );
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

    if (walkId <= 0) throw ArgumentError.value(walkId, 'walkId');
    return _walkMap(
      await _authenticatedRequest(
        'POST',
        '/api/walks/$walkId/locations/',
        '산책 위치 저장',
        token: token,
        body: {'latitude': latitude, 'longitude': longitude},
      ),
    );
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

    if (walkId <= 0) throw ArgumentError.value(walkId, 'walkId');
    return _walkResponseMap(
      await _authenticatedRequest(
        'GET',
        '/api/walks/$walkId/',
        '산책 상세 조회',
        token: token,
      ),
    );
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

  // 회원가입 - 3. 최종 회원가입 API
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String passwordConfirm,
    String verificationToken,
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
          'verification_token': verificationToken,
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
      const personalityMap = {
        '에너지형': 'energy',
        '사회성형': 'social',
        '겁쟁이형': 'timid',
        '호기심형': 'curious',
        '느긋형': 'relaxed',
        '얌전형': 'calm',
      };

      // 첨부 명세: POST /api/pets/ 는 application/json이며
      // personalities는 문자열 배열, profile_image는 문자열 필드이다.
      // 기존 호출부 호환을 위해 이름은 유지한다. 로컬 파일 업로드 경로가
      // 아니라 API에서 받는 이미지 문자열(URL/미디어 경로)을 전달한다.
      final image = profileImagePath?.trim();
      final response = await http.post(
        Uri.parse('$baseUrl/api/pets/'),
        headers: await _headers(token: accessToken),
        body: jsonEncode({
          'nickname': nickname,
          'name': name,
          'breed': breed,
          'birth_date': birthDate,
          if (image != null && image.isNotEmpty) 'profile_image': image,
          'personalities': (personalities ?? const <String>[])
              .map((value) => personalityMap[value] ?? value)
              .toList(),
        }),
      );
      final body = _decodeOrThrow(response, '반려견 등록');
      final data = body is Map ? (body['data'] ?? body) : null;
      final petId = data is Map
          ? int.tryParse(data['id']?.toString() ?? '')
          : null;
      if (petId != null) await savePetId(petId);
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'statusCode': e.statusCode,
      };
    } catch (_) {
      return {'success': false, 'message': '반려견 등록 중 서버와 연결하지 못했습니다.'};
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

  // 응답 목록이 객체로 감싸져 있어도 처리하되, 알 수 없는 구조를
  // 빈 목록으로 바꾸어 조회 성공으로 표시하지 않는다.
  static List<dynamic> _attendanceRows(dynamic body, String label) {
    if (body is List) return body;
    if (body is Map) {
      for (final key in ['results', 'rewards', 'data']) {
        final inner = body[key];
        if (inner is List) return inner;
        if (inner is Map) return _attendanceRows(inner, label);
      }
      throw FormatException(
        '$label 응답의 목록 필드를 확인해주세요. '
        '수신 필드: ${body.keys.join(', ')}',
      );
    }
    throw FormatException('$label 응답이 목록 형식이 아닙니다.');
  }

  static Map<String, dynamic> _attendanceObject(dynamic body, String label) {
    if (body is! Map) throw FormatException('$label 응답이 객체 형식이 아닙니다.');
    final inner = body['data'];
    return Map<String, dynamic>.from(inner is Map ? inner : body);
  }

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

    final body = await _authenticatedRequest(
      'GET',
      '/api/attendance/summary/',
      '출석 요약 조회',
      token: token,
    );
    final json = _attendanceObject(body, '출석 요약');
    if (json['today'] is! Map) {
      throw FormatException('출석 요약 응답의 today 필드를 확인해주세요.');
    }
    return AttendanceSummaryResponse.fromJson(json);
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

    final body = await _authenticatedRequest(
      'GET',
      '/api/attendance/calendar/?year=$year&month=$month',
      '출석 달력 조회',
      token: token,
    );
    return AttendanceCalendarResponse.fromJson(
      _attendanceObject(body, '출석 달력'),
    );
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

    final body = await _authenticatedRequest(
      'GET',
      '/api/attendance/rewards/',
      '출석 보상 목록 조회',
      token: token,
    );
    return _attendanceRows(body, '출석 보상 목록').map((item) {
      if (item is! Map) {
        throw FormatException('출석 보상 목록의 항목이 객체 형식이 아닙니다.');
      }
      return AttendanceRewardItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
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

    if (rewardId <= 0) throw ArgumentError.value(rewardId, 'rewardId');
    final body = await _authenticatedRequest(
      'PATCH',
      '/api/attendance/rewards/$rewardId/open/',
      '출석 보상 열기',
      token: token,
    );
    final json = _attendanceObject(body, '출석 보상 열기');
    final reward = AttendanceRewardItem.fromJson(json);
    if (reward.id != rewardId) {
      throw FormatException(
        '보상 열기 응답의 id 필드를 확인해주세요. '
        '서버에서 열렸을 수 있으니 출석 화면을 다시 조회해주세요.',
      );
    }
    return reward;
  }

  /// 실제 친구 목록 조회. 이 화면에는 목데이터를 반환하지 않는다.
  /// GET /api/friends/ → [{id, nickname, pets: [{id, name, breed}]}]
  static Future<List<Friend>> getMyFriends({String? token}) async {
    final response = await _authenticatedRequest(
      'GET',
      '/api/friends/',
      '친구 목록 조회',
      token: token,
    );
    // 명세의 배열 응답과 목록 래퍼를 지원한다.
    final dynamic items = response is Map
        ? response['results'] ?? response['data']
        : response;
    if (items is! List) {
      throw const FormatException('친구 목록 응답이 배열 형식이 아닙니다.');
    }
    return items.map<Friend>((item) {
      if (item is! Map) {
        throw const FormatException('친구 항목의 응답 형식이 올바르지 않습니다.');
      }
      return Friend.fromJson(Map<String, dynamic>.from(item));
    }).toList();
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
        if (newAccess != null && newAccess.isNotEmpty) {
          final rotatedRefresh = data['refresh']?.toString();
          if (rotatedRefresh != null && rotatedRefresh.isNotEmpty) {
            await storage.write(key: _kRefreshToken, value: rotatedRefresh);
          }
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
        },
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
    final weekList =
        ApiService._attendanceRows(json['week'] ?? [], '출석 요약 week')
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
    final daysList =
        ApiService._attendanceRows(json['days'] ?? [], '출석 달력 days')
            .map((e) => AttendanceDayItem.fromJson(e as Map<String, dynamic>))
            .toList();
    return AttendanceCalendarResponse(
      year: json['year'] ?? 2026,
      month: json['month'] ?? 10,
      days: daysList,
    );
  }
}
