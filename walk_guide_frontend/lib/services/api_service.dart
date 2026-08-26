import 'dart:convert';
import 'package:http/http.dart' as http;

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
// [4. ApiService 메인 클래스]
// -----------------------------------------------------------------------------
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const bool useMockData = true;

  // [홈 화면 종합 데이터 로드]
  static Future<HomeDashboardResponse> getHomeDashboardData({
    String userId = '1',
    int petId = 1,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return HomeDashboardResponse(
        userName: '예은님',
        petId: petId,
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
      final userRes = await http.get(Uri.parse('$baseUrl/api/users/$userId/'));
      final petRes = await http.get(Uri.parse('$baseUrl/api/pets/$petId/'));
      final missionRes = await http.get(
        Uri.parse('$baseUrl/api/pets/$petId/missions/?period=DAILY'),
      );
      final friendsRes = await http.get(Uri.parse('$baseUrl/api/friends/'));

      final userData = jsonDecode(userRes.body);
      final petData = jsonDecode(petRes.body);
      final missionList = (jsonDecode(missionRes.body) as List)
          .map((m) => PetMissionItem.fromJson(m))
          .toList();
      final friendList = (jsonDecode(friendsRes.body) as List)
          .map(
            (f) => FriendDogDisplay(
              name: f['pet_name'] ?? '친구',
              profileImage: f['profile_image_url'],
            ),
          )
          .toList();

      return HomeDashboardResponse(
        userName: userData['nickname'] ?? '보호자님',
        petId: petData['id'] ?? petId,
        petName: petData['name'] ?? '반려견',
        petBreed: petData['breed'] ?? '견종',
        petAge: petData['age'] ?? 1,
        petLevel: petData['level'] ?? 1,
        petImageUrl: petData['profile_image'],
        petPersonalities: List<String>.from(
          petData['personalities'] ?? ['에너지형'],
        ),
        targetDistance: (petData['target_distance'] ?? 2.0).toDouble(),
        currentDistance: (petData['current_distance'] ?? 0.0).toDouble(),
        walkingFriends: friendList,
        dailyMissions: missionList,
      );
    } catch (e) {
      throw Exception('홈 데이터 로드 실패: $e');
    }
  }

  // [산책 시작 API] POST api/walks/start/
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
        headers: {'Content-Type': 'application/json'},
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

  // [산책 종료 API] POST api/walks/:walk_id/end/
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
        headers: {'Content-Type': 'application/json'},
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

  // [로그인 / 소셜 로그인 / 회원가입 / 비밀번호 API]
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'user_id': '1', 'message': '로그인 성공!'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'user_id': data['user_id']?.toString(),
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  static Future<Map<String, dynamic>> socialLogin(String provider) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'user_id': '1',
        'is_new_user': false,
        'message': '$provider 로그인 성공!',
      };
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/socaillogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider': provider}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'user_id': data['user_id']?.toString(),
        'is_new_user': data['is_new_user'] ?? false,
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String nickname,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'user_id': '1'};
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    String nickname,
  ) async {
    if (useMockData) return {'success': true};
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': nickname}),
      );
      return {'success': res.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> registerPet({
    required String userId,
    required String name,
    required String breed,
    required String birthDate,
    String? profileImage,
    List<String>? personalities,
  }) async {
    if (useMockData) return {'success': true};
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/pets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': userId,
          'name': name,
          'breed': breed,
          'birth_date': birthDate,
          'profile_image': profileImage,
          'personalities': personalities ?? [],
        }),
      );
      return {'success': res.statusCode == 200 || res.statusCode == 201};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (useMockData) return {'success': true};
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/users/password/reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      return {'success': res.statusCode == 200};
    } catch (e) {
      return {'success': false};
    }
  }
}
