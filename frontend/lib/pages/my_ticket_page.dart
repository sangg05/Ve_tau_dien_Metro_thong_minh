import 'package:flutter/material.dart';

class MyTicketPage extends StatefulWidget {
  const MyTicketPage({super.key});

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
  String selectedTab = "using"; // "using" = Đang sử dụng, "unused" = Chưa sử dụng
  List<String> usingTickets = []; // sau này sẽ load từ backend
  List<String> unusedTickets = []; // sau này sẽ load từ backend

  @override
  Widget build(BuildContext context) {
    // Danh sách vé theo tab
    List<String> tickets =
        selectedTab == "using" ? usingTickets : unusedTickets;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
        title: const Text(
          "Vé của tôi",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                "Hết hạn",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Tabbar custom
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text("Đang sử dụng"),
                selected: selectedTab == "using",
                selectedColor: Colors.blue[200],
                onSelected: (_) {
                  setState(() => selectedTab = "using");
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text("Chưa sử dụng"),
                selected: selectedTab == "unused",
                selectedColor: Colors.blue[200],
                onSelected: (_) {
                  setState(() => selectedTab = "unused");
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Danh sách vé hoặc thông báo rỗng
          Expanded(
            child: tickets.isEmpty
                ? const Center(
                    child: Text(
                      "Bạn không có vé nào",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      String ticket = tickets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text("Vé: $ticket"),
                          subtitle: const Text("Chi tiết vé..."),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: mở chi tiết vé
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Placeholder thanh menu dưới (giống ảnh có khung xám)
          Container(
            height: 60,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
          )
        ],
      ),
    );
  }
}
