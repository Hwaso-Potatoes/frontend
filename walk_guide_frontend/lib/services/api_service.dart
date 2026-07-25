import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //실제 백엔드 서버 URL 입력
  static const String baseUrl = 'https://your-api-domain.com/api';

  // 1. 회원가입 API
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String phone,
  ) async {
    //[MOCK 테스트용]
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'user_id': '1', 'message': '회원가입이 완료되었습니다.'};

    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'phone': phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? '회원가입에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
    */
  }

  // 2. 유저 프로필 수정 (PATCH /users/:user_id/)
  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    String nickname,
  ) async {
    //[MOCK 테스트용]
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'message': '프로필 업데이트 완료!'};

    /*
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': nickname}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '프로필이 업데이트되었습니다.'};
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? '프로필 수정에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
    */
  }

  // 3. 반려견 등록 (POST /pets/)
  static Future<Map<String, dynamic>> registerPet({
    required String userId,
    required String name,
    required String breed,
    required String birthDate,
    String? profileImage,
  }) async {
    //[MOCK 테스트용]
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'message': '반려견 등록 완료!'};

    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': userId,
          'name': name,
          'breed': breed,
          'birth_date': birthDate,
          'profile_image': profileImage,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': '반려견이 등록되었습니다.'};
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? '반려견 등록에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
    */
  }

  // 4. 로그인 API
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    //[MOCK 테스트용]
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'user_id': '1', 'message': '로그인 성공!'};

    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? '로그인에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
    */
  }

  // 5. 비밀번호 재설정 API
  static Future<Map<String, dynamic>> resetPassword(
    String currentPassword,
    String newPassword,
  ) async {
    //[MOCK 테스트용]
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'message': '비밀번호가 성공적으로 변경되었습니다.'};

    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final body = jsonDecode(response.body);
        return {'success': false, 'message': body['message'] ?? '비밀번호 변경에 실패했습니다.'};
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
    */
  }
}
