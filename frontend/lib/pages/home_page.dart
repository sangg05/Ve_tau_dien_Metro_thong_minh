import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menu chính
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.confirmation_number, "label": "Mua vé", "route": "/buy"},
      {"icon": Icons.receipt_long, "label": "Vé của tôi", "route": "/myticket"},
      {"icon": Icons.map, "label": "Hành trình", "route": "/journey"},
      {"icon": Icons.person, "label": "Tài khoản", "route": "/TK"},
      {"icon": Icons.login, "label": "Đăng nhập", "route": "/login"},
      {"icon": Icons.settings, "label": "Cài đặt", "route": "/settings"},
      {"icon": Icons.info, "label": "Giới thiệu", "route": "/about"},
    ];

    // Tin tức tạm
    final List<Map<String, String>> news = [
      {
        "title": "HCMC Metro miễn phí vé ngày 02/09",
        "time": "22 tiếng trước",
        "image": "https://picsum.photos/300/200?random=1"
      },
      {
        "title": "Đón tiếp Hội đồng Lý luận, Phê bình",
        "time": "2 ngày trước",
        "image": "https://picsum.photos/300/200?random=2"
      },
      {
        "title": "Khai trương tuyến Metro số 1",
        "time": "7 ngày trước",
        "image": "https://picsum.photos/id/237/300/200"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("HURC Metro"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/language');
            },
            icon: const Icon(Icons.language, color: Colors.white),
            label: const Text("Tiếng Việt", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Banner
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView(
                    children: [
                      Image.asset("assets/anh_nen.webp", fit: BoxFit.cover),
                      Image.network("https://picsum.photos/500/200?1", fit: BoxFit.cover),
                      Image.network("https://picsum.photos/500/200?2", fit: BoxFit.cover),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                const Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    "Chào mừng đến HURC Metro",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // 🔹 Menu
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(context, item['route']);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blue[100],
                          child: Icon(item['icon'], color: Colors.blue[800], size: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(item['label'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔹 Tin tức
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Text("Tin tức", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: news.length,
                itemBuilder: (context, index) {
                  final item = news[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/newsDetail', arguments: item);
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(item['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['title']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(item['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: const Text(
                "© 2025 HURC Metro - Nhanh chóng • An toàn • Hiện đại",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
