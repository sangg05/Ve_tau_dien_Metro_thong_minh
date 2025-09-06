import 'package:flutter/material.dart';
import 'home_page.dart';
// Màn hình đăng nhập
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Ảnh minh họa phía trên
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.asset("assets/anh_nen.webp", fit: BoxFit.cover),
            ),

            // 2. Nội dung đăng nhập
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nút quay lại (mũi tên)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false, // Xóa tất cả route trước đó
                    );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tiêu đề "Đăng nhập"
                  const Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  // Ô nhập email
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ô nhập mật khẩu
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Mật khẩu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Nút đăng nhập
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý đăng nhập
                    },
                    child: const Text("Đăng nhập"),
                  ),

                  const SizedBox(height: 20),

                  // Link đến trang đăng ký
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Đăng kí tài khoản?",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
