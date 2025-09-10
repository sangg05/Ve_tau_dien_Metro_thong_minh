import 'package:flutter/material.dart';
import 'Buy_ticket.dart';
import 'my_ticket_page.dart';
import 'home_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  int selectedBottomIndex = 2; // 0 = Mua vé, 1 = Vé của tôi, 2 = Lịch sử

  List<Map<String, dynamic>> transactions = [
    {"id": 1, "date": "2025-09-01", "amount": 40000},
    {"id": 2, "date": "2025-09-02", "amount": 90000},
  ]; // sample data, sau này load từ backend

  void onBottomNavTap(int index) {
    if (index == selectedBottomIndex) return;
    setState(() => selectedBottomIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyTicketPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyTicketPage()),
        );
        break;
      case 2:
        // Lịch sử, đang ở đây → không làm gì
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
        title: const Text(
          "Lịch sử giao dịch",
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
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                "Chưa có giao dịch nào",
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text("Giao dịch #${tx['id']}"),
                    subtitle: Text("Ngày: ${tx['date']}"),
                    trailing: Text("${tx['amount']} đ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    onTap: () {
                      // TODO: mở chi tiết giao dịch
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        iconSize: 22,
        onTap: onBottomNavTap,
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
