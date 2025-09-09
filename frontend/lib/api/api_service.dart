import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

class ApiService {
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
}
