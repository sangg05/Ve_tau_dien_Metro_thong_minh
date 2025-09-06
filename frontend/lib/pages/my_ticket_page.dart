import 'package:flutter/material.dart';
import 'Buy_ticket.dart'; 
import 'transaction_history_page.dart'; 
import 'home_page.dart';

class MyTicketPage extends StatefulWidget {
  const MyTicketPage({super.key});

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
  String selectedTab = "using";
  int selectedBottomIndex = 1; // 0 = Mua vé, 1 = Vé của tôi, 2 = Lịch sử

  List<String> usingTickets = ["Vé 1 ngày", "Vé tháng HSSV"];
  List<String> unusedTickets = ["Vé 3 ngày"];

  @override
  Widget build(BuildContext context) {
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
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
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: mở chi tiết vé
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        iconSize: 22,
        onTap: (index) {
          if (index == selectedBottomIndex) return; // nếu bấm lại tab hiện tại thì bỏ qua
          setState(() => selectedBottomIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BuyTicketPage()),
              );
              break;
            case 1:
              // Vé của tôi, đang ở đây → không làm gì
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const TransactionHistoryPage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Mua vé",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Vé của tôi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Lịch sử",
          ),
        ],
      ),
    );
  }
}
