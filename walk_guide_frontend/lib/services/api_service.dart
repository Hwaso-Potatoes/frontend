import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home.dart';

class ApiService {
  // 1. 백엔드 팀 서버 도메인 주소로 변경
  static const String baseUrl =
      'http://10.0.2.2:8000'; // 예: https://api.yourdomain.com

  // 2. 내일 백엔드 연결 시 false로만 바꾸면 실서버 API와 통신합니다.
  static const bool useMockData = true;

  // ---------------------------------------------------------------------------
  // [홈 화면 종합 데이터 로드 API]
  // GET api/users/:user_id/ + GET api/pets/:pet_id/ + GET api/friends/ + GET api/pets/:pet_id/missions/
  // ---------------------------------------------------------------------------
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
        petImageUrl: null, // 서버 이미지 URL (null 시 기본 이미지)
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

    // 실서버 연동 시 실행되는 코드
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
              name: f['pet_name'],
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

  // [1. 일반 로그인] POST api/users/login/
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'user_id': '1',
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
        'message': '로그인 성공!',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user_id': data['user_id']?.toString(),
          'access': data['access'],
          'refresh': data['refresh'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '이메일 또는 비밀번호를 확인해주세요.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [2. 소셜 로그인] POST api/users/socaillogin
  static Future<Map<String, dynamic>> socialLogin(String provider) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'success': true,
        'user_id': '1',
        'is_new_user': false,
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
        'message': '$provider 소셜 로그인 성공!',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/socaillogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider': provider}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'user_id': data['user_id']?.toString(),
          'is_new_user': data['is_new_user'] ?? false,
          'access': data['access'],
          'refresh': data['refresh'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? '소셜 로그인 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [3. 회원가입] POST api/users/register/
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String phone,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'user_id': '1', 'message': '회원가입이 완료되었습니다.'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'user_id': data['id']?.toString()};
      }
      return {'success': false, 'message': data['message'] ?? '회원가입 실패'};
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [4. 유저 프로필 수정] PATCH api/users/:user_id/
  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    String nickname,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': '프로필 업데이트 완료!'};
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': nickname}),
      );

      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [5. 반려견 등록] POST api/pets/
  static Future<Map<String, dynamic>> registerPet({
    required String userId,
    required String name,
    required String breed,
    required String birthDate,
    String? profileImage,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': '반려견 등록 완료!'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': userId,
          'name': name,
          'breed': breed,
          'birth_date': birthDate,
          'profile_image': profileImage,
        }),
      );

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
      };
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }

  // [6. 비밀번호 재설정] POST api/users/password/reset/
  static Future<Map<String, dynamic>> resetPassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {'success': true, 'message': '비밀번호가 성공적으로 변경되었습니다.'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/password/reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': '서버 연결 실패'};
    }
  }
}
