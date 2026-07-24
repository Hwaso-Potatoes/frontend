import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://your-api-domain.com/api'; // 실제 API 서버 URL로 수정하세요.

  // 로그인 API
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
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
  }

  // 회원가입 API
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? '회원가입에 실패했습니다.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
  }

  // 비밀번호 재설정 API
  static Future<Map<String, dynamic>> resetPassword(
    String currentPassword,
    String newPassword,
  ) async {
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
        return {
          'success': false,
          'message': body['message'] ?? '비밀번호 변경에 실패했습니다.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': '서버 연결에 실패했습니다.'};
    }
  }
}
