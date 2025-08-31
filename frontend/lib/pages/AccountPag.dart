import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // dữ liệu tạm (sau này thay bằng API hoặc Firebase)
    final userData = {
      "name": "Tuyết Sang",
      "email": "huynhthutuyetsang@gmail.com",
      "phone": "0123 456 789",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin tài khoản"),
        backgroundColor: Colors.green[300],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar + Tên
              Container(
                color: Colors.red[100],
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userData['name']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Thông tin chi tiết
              ListTile(
                leading: const Icon(Icons.person),
                title: Text("Họ tên: ${userData['name']}"),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text("Email: ${userData['email']}"),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text("Số điện thoại: ${userData['phone']}"),
              ),

              // Quản lý phương thức thanh toán
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Quản lý phương thức thanh toán"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đi tới trang quản lý thanh toán")),
                  );
                  // Navigator.pushNamed(context, "/payment"); // ví dụ
                },
              ),

              // Xóa tài khoản
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Xoá tài khoản"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Xác nhận"),
                      content: const Text("Bạn có chắc muốn xoá tài khoản không?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Huỷ"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã xoá tài khoản")),
                            );
                          },
                          child: const Text("Xoá", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(),

              // Đăng xuất
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Đăng xuất"),
                onTap: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
