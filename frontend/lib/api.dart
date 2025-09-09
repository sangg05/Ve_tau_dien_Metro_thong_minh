import 'package:flutter/foundation.dart' show kIsWeb;

const String baseUrl = kIsWeb
    ? 'http://127.0.0.1:8000' // Flutter Web chạy cùng máy với Django
    : 'http://10.0.2.2:8000'; // Android emulator truy cập localhost máy
