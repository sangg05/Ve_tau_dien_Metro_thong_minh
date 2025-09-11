import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api.dart'; // baseUrl
import '../session.dart'; // Session.userId()

class ApiService {
  // Header mặc định cho các request JSON
  static const _headers = {'Content-Type': 'application/json'};

  // ===== Helpers (giữ comment TV) =====
  // Lấy user_id hiện tại; ném lỗi nếu chưa đăng nhập
  static Future<String> _requireUserId() async {
    final uid = await Session.userId();
    if (uid == null || uid.isEmpty) {
      throw Exception('Chưa đăng nhập (không có user_id)');
    }
    return uid;
  }

  // Chuẩn hoá cách decode danh sách từ DRF (list hoặc paginated.results)
  static List<Map<String, dynamic>> _decodeList(http.Response r) {
    final data = jsonDecode(r.body);
    if (data is List) {
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    if (data is Map && data['results'] is List) {
      return List<Map<String, dynamic>>.from(
        (data['results'] as List).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      );
    }
    return const [];
  }

  // === Auth ===
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
      headers: _headers,
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
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Lấy thông tin user hiện tại
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final uid = await _requireUserId();
    final url = Uri.parse('$baseUrl/api/users/$uid/');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    }
    throw Exception('Lấy user thất bại: ${res.statusCode} - ${res.body}');
  }

  // === Stations ===
  static Future<List<Map<String, dynamic>>> getStations() async {
    final url = Uri.parse('$baseUrl/api/stations/');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      return _decodeList(res);
    }
    throw Exception(
      'Lấy danh sách ga thất bại: ${res.statusCode} - ${res.body}',
    );
  }

  // === Tickets ===
  // Mua vé
  static Future<http.Response> purchaseTicket({
    required String ticketType,
    required String price,
    required String startStationId,
    required String endStationId,
    int? days, // gửi INT (serializer yêu cầu int), KHÔNG toString()
  }) async {
    final uid = await _requireUserId();

    final url = Uri.parse('$baseUrl/api/tickets/purchase/');
    final body = <String, dynamic>{
      'user_id': uid,
      'ticket_type': ticketType,
      'price': price, // backend sẽ parse Decimal
      'start_station': startStationId,
      'end_station': endStationId,
      if (days != null) 'days': days, // chỉ gửi khi là vé ngày
    };

    return http.post(url, headers: _headers, body: jsonEncode(body));
  }

  // Lấy danh sách vé của tôi
  static Future<List<Map<String, dynamic>>> getMyTickets() async {
    final uid = await _requireUserId();
    final url = Uri.parse('$baseUrl/api/tickets/?user_id=$uid');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      return _decodeList(res);
    }
    throw Exception('Lấy vé thất bại: ${res.statusCode} - ${res.body}');
  }

  // === Ticket Products ===
  // NOTE: Dự án hiện router là 'tickets/products' → endpoint dưới đây dùng đúng path đó.
  // Nếu bạn đổi sang router 'ticket-products', hãy thay bằng: '$baseUrl/api/ticket-products/'
  static Future<List<Map<String, dynamic>>> getTicketProducts() async {
    final url = Uri.parse('$baseUrl/api/tickets/products/');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      return _decodeList(res);
    }
    throw Exception('Lỗi lấy loại vé: ${res.statusCode} - ${res.body}');
  }

  // === Transactions (lịch sử giao dịch) ===
  static Future<List<Map<String, dynamic>>> getMyTransactions() async {
    final uid = await _requireUserId();
    final url = Uri.parse('$baseUrl/api/transactions/?user_id=$uid');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      return _decodeList(res);
    }
    throw Exception(
      'Lấy lịch sử giao dịch thất bại: ${res.statusCode} - ${res.body}',
    );
  }
}
