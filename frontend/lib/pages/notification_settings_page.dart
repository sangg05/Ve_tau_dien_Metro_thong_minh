import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt Thông báo")),
      body: const Center(
        child: Text("Trang cài đặt thông báo"),
      ),
    );
  }
}
