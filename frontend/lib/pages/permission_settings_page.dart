import 'package:flutter/material.dart';

class PermissionSettingsPage extends StatelessWidget {
  const PermissionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt Quyền truy cập")),
      body: const Center(
        child: Text("Trang cài đặt quyền truy cập"),
      ),
    );
  }
}
