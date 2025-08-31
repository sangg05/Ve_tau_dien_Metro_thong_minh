import 'package:flutter/material.dart';
import 'register_page.dart';
// Màn hình đăng nhập
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. Ảnh minh họa phía trên
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              "assets/anh_nen.webp", // ảnh bạn đưa vào thư mục assets
              fit: BoxFit.cover,
            ),
          ),

          // 2. Nội dung đăng nhập
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
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
                        Navigator.pop(context);
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

                  // Nút đăng nhập bằng Google
                  ElevatedButton.icon(
                    onPressed: () {
                      // Xử lý khi bấm nút
                    },
                    icon: Image.asset(
                      "assets/logo_google.png", // logo Google
                      height: 24,
                    ),
                    label: const Text(
                      "Đăng nhập bằng Google",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Dòng chữ "Đăng kí tài khoản?"
                  // Dòng chữ "Đăng kí tài khoản?" có thể bấm
                TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register_page()),
                  );
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
          ),
        ],
      ),
    );
  }
}
