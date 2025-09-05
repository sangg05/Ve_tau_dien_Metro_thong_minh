import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import thư viện http
import 'dart:convert'; // Import thư viện để mã hóa/giải mã JSON

class Register_page extends StatefulWidget {
  const Register_page({super.key});

  @override
  State<Register_page> createState() => _Register_pageState();
}

class _Register_pageState extends State<Register_page> {
  // Tạo controller cho các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hàm xử lý đăng ký người dùng
  Future<void> _registerUser() async {
    final String url = 'http://10.0.2.2:8000/api/register/';

    // Tạo dữ liệu gửi đi dưới dạng JSON
    final Map<String, dynamic> data = {
      'email': _emailController.text,
      'phone': _phoneController.text,
      'password': _passwordController.text,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng ký thành công! User ID: ${responseData['user_id']}',
            ),
          ),
        );
      } else {
        // Đăng ký thất bại, hiển thị lỗi từ Django
        String errorMessage =
            responseData['error'] ?? 'Có lỗi xảy ra, vui lòng thử lại.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $errorMessage')));
      }
    } catch (e) {
      // Xử lý lỗi kết nối
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: Không thể kết nối tới máy chủ.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Container(
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/anh_nen.webp"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tiêu đề
            const Text(
              "Đăng Kí",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Ô nhập Email
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            // Ô nhập Số điện thoại
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            // Ô nhập Mật khẩu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nút Đăng kí
            ElevatedButton(
              onPressed: _registerUser, // Gọi hàm xử lý
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade100,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Đăng kí",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Link sang Login
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Đã có tài khoản? Đăng nhập",
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
