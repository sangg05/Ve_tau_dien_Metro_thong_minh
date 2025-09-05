import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Dùng localhost nếu chạy desktop/web
final String baseUrl = "http://127.0.0.1:8000";

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load users");
    }
  }
}

