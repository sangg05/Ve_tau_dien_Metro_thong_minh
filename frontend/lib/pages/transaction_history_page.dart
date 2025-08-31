import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Map<String, dynamic>> transactions = []; 
  // sau này sẽ load từ backend (API)

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
                          trailing: Text("${tx['amount']} đ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          onTap: () {
                            // TODO: mở chi tiết giao dịch
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Thanh bar xám ở dưới
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
