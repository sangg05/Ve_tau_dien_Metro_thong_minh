import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<String?> userId() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('user_id');
    return (v != null && v.isNotEmpty) ? v : null;
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
