import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = ["Tiếng Việt", "English", "日本語", "한국어"];

    return Scaffold(
      appBar: AppBar(title: const Text("Chọn ngôn ngữ")),
      body: ListView.separated(
        itemCount: languages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(languages[index]),
            onTap: () {
              Navigator.pop(context, languages[index]);
            },
          );
        },
      ),
    );
  }
}
