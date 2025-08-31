import 'package:flutter/material.dart';
import 'payment_page.dart';
class TicketDetailPage extends StatelessWidget {
  final int startIndex;
  final List<String> stations;

  const TicketDetailPage({
    super.key,
    required this.startIndex,
    required this.stations,
  });

  // Tính giá vé: 6000đ cơ bản + 1000đ mỗi ga
  int calculatePrice(int distance) {
    return 6000 + distance * 1000;
  }

  @override
  Widget build(BuildContext context) {
    String startStation = stations[startIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text("Vé lượt - Từ ga $startStation"),
      ),
      body: ListView.builder(
        itemCount: stations.length - (startIndex + 1),
        itemBuilder: (context, i) {
          String destStation = stations[startIndex + i + 1];
          int price = calculatePrice(i + 1);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
  leading: const Icon(Icons.train, size: 32, color: Colors.blue),
  title: Text("Đến ga $destStation"),
  subtitle: Text("Giá: $price đ"),
  onTap: () {
    // Khi bấm vào sẽ chuyển sang trang thanh toán
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          startStation: startStation,
          destStation: destStation,
          price: price,
        ),
      ),
    );
  },
),
          );
        },
        
      ),
    );
  }
}
