import 'package:flutter/material.dart';

import '../api/api_service.dart'; // gọi API lịch sử giao dịch
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

  // Trạng thái tải dữ liệu
  bool _loading = true;
  String? _error;

  // Danh sách giao dịch từ backend
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Tải lịch sử giao dịch từ API
  Future<void> _loadTransactions() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Trả về List<Map<String, dynamic>>
      final list = await ApiService.getMyTransactions();
      setState(() {
        _transactions = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải lịch sử giao dịch: $e';
        _loading = false;
      });
    }
  }

  // Format thời gian ISO → dd/MM/yyyy HH:mm (nếu parse được), ngược lại trả string gốc
  String _fmtTime(dynamic value) {
    final s = (value ?? '').toString();
    if (s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s).toLocal();
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$dd/$mm/$yyyy $hh:$min';
    } catch (_) {
      return s;
    }
  }

  // 1 item giao dịch
  Widget _txTile(Map<String, dynamic> tx) {
    final amount = (tx['amount'] ?? '').toString();
    final method = (tx['method'] ?? '').toString();
    final status = (tx['transaction_status'] ?? '').toString();
    final created = _fmtTime(
      tx['created_at'] ?? tx['created'] ?? tx['timestamp'],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text('Số tiền: $amount đ'),
        subtitle: Text(
          'Phương thức: ${method.isEmpty ? "-" : method}\nThời gian: $created',
        ),
        trailing: Text(
          status.isEmpty ? '-' : status,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // TODO: mở chi tiết giao dịch (nếu cần)
        },
      ),
    );
  }

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
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadTransactions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại'),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadTransactions,
            child: _transactions.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          "Chưa có giao dịch nào",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) =>
                        _txTile(_transactions[index]),
                  ),
          );

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
      body: body,
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
        ],
      ),
    );
  }
}
