import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api.dart'; // baseUrl
import '../session.dart'; // Session.userId()

class ApiService {
  // Đăng ký
  static Future<http.Response> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    final url = Uri.parse('$baseUrl/api/register/');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
  }

  // Đăng nhập
  static Future<http.Response> login({
    required String email,
    required String password,
  }) {
    final url = Uri.parse('$baseUrl/api/auth/login/');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // LẤY THÔNG TIN USER HIỆN TẠI BẰNG user_id (đã lưu trong SharedPreferences)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final uid = await Session.userId();
    if (uid == null || uid.isEmpty) {
      throw Exception('Chưa đăng nhập (không có user_id)');
    }

    // Backend DRF: cần lookup_field='user_id' trong UserViewSet
    final url = Uri.parse('$baseUrl/api/users/$uid/'); // chú ý dấu / cuối
    final res = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // In thêm để debug dễ
    throw Exception('Lấy user thất bại: ${res.statusCode} - ${res.body}');
  }
}
