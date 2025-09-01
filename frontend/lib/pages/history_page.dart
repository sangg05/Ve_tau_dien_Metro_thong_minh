import 'package:flutter/material.dart';
import 'Buy_ticket.dart';
import 'my_ticket_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = []; // sau này load từ backend

  int _selectedIndex = 2; // index 2 = "Lịch sử giao dịch"

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuyTicketPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyTicketPage()),
      );
    }
    // index 2 = đang ở Lịch sử giao dịch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
        title: const Text(
          "Lịch sử giao dịch",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: transactions.isEmpty
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
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text("Giao dịch #${tx['id']}"),
                          subtitle: Text("Ngày: ${tx['date']}"),
                          trailing: Text(
                            "${tx['amount']} đ",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          onTap: () {
                            // TODO: mở chi tiết giao dịch
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Thanh bar ở dưới
     
    );
  }
}
