import 'package:flutter/material.dart';
import '../api/api_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await ApiService.getCurrentUser();
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thông tin tài khoản")),
        body: Center(child: Text(_error!)),
      );
    }

    final userData = _user ?? {};

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
                      (userData['full_name'] ?? "Không rõ").toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Thông tin chi tiết
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  "Họ tên: ${(userData['full_name'] ?? '-').toString()}",
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text("Email: ${(userData['email'] ?? '-').toString()}"),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(
                  "Số điện thoại: ${(userData['phone'] ?? '-').toString()}",
                ),
              ),

              // Quản lý phương thức thanh toán
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Quản lý phương thức thanh toán"),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đi tới trang quản lý thanh toán"),
                    ),
                  );
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
                      content: const Text(
                        "Bạn có chắc muốn xoá tài khoản không?",
                      ),
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
                          child: const Text(
                            "Xoá",
                            style: TextStyle(color: Colors.red),
                          ),
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
