import 'package:flutter/material.dart';

import '../api/api_service.dart';
import 'TicketDetailPage.dart';
import 'my_ticket_page.dart';
import 'transaction_history_page.dart';
import 'home_page.dart';
import 'payment_page.dart';

class BuyTicketPage extends StatefulWidget {
  const BuyTicketPage({super.key});

  @override
  State<BuyTicketPage> createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  bool _loading = true;
  String? _error;

  /// Danh sách ga từ backend: mỗi phần tử gồm {station_id, station_name}
  List<Map<String, dynamic>> _stations = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final list = await ApiService.getStations();
      setState(() {
        _stations = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không tải được danh sách ga: $e';
        _loading = false;
      });
    }
  }

  // Điều hướng sang trang thanh toán cho vé thời gian (không cần ga)
  void _goToPayment({
    required BuildContext context,
    required int price,
    required String ticketType, // 'Day_All' | 'Month'
    required int passDays, // 1 | 3 | 30
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          // Time-pass: không gửi ga
          startStationId: null,
          destStationId: null,
          startStationName: '',
          destStationName: '',
          price: price,
          ticketType: ticketType,
          isTimePass: true,
          passDays: passDays,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[200],
          title: const Text('Mua vé'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _loadStations();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
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
        title: const Text(
          "Mua vé",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Nổi bật (vé thời gian) ---
              const Text(
                "Nổi bật",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),

              _ticketCard(
                title: "Vé 1 ngày",
                price: 40000,
                onTap: () => _goToPayment(
                  context: context,
                  price: 40000,
                  ticketType: 'Day_All',
                  passDays: 1,
                ),
              ),
              _ticketCard(
                title: "Vé 3 ngày",
                price: 90000,
                onTap: () => _goToPayment(
                  context: context,
                  price: 90000,
                  ticketType: 'Day_All',
                  passDays: 3,
                ),
              ),
              _ticketCard(
                title: "Vé tháng",
                price: 300000,
                onTap: () => _goToPayment(
                  context: context,
                  price: 300000,
                  ticketType: 'Month',
                  passDays: 30,
                ),
              ),

              const SizedBox(height: 20),

              // --- Ưu đãi ---
              const Text(
                "Ưu đãi Học sinh Sinh viên",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _ticketCard(
                title: "Vé tháng HSSV",
                price: 150000,
                onTap: () => _goToPayment(
                  context: context,
                  price: 150000,
                  ticketType: 'Month',
                  passDays: 30,
                ),
              ),

              const SizedBox(height: 20),

              // --- Danh sách ga (dùng cho vé lượt) ---
              const Text(
                "Danh sách ga",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _stations.length,
                itemBuilder: (context, index) {
                  final name = (_stations[index]['station_name'] ?? '')
                      .toString();
                  final names = _stations
                      .map((e) => (e['station_name'] ?? '').toString())
                      .toList();
                  return ListTile(
                    title: Text("Đi từ ga $name"),
                    trailing: const Text(
                      "Xem chi tiết",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailPage(
                            startIndex: index,
                            stations: names,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Navigation dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        iconSize: 22,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyTicketPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryPage(),
                ),
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
        ],
      ),
    );
  }

  // Card vé tái sử dụng
  Widget _ticketCard({
    required String title,
    required int price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.confirmation_number,
              size: 26,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            Text(
              "$price đ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
