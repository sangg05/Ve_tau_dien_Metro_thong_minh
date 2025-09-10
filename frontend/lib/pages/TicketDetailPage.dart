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

  // Giá vé = 6000đ cơ bản + 1000đ mỗi ga (theo khoảng cách tuyệt đối)
  int calculatePrice(int distance) {
    return 6000 + distance * 1000;
  }

  @override
  Widget build(BuildContext context) {
    String startStation = stations[startIndex];

    // Lấy danh sách ga trừ ga xuất phát
    List<String> destStations = [
      for (int i = 0; i < stations.length; i++)
        if (i != startIndex) stations[i]
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text("Vé lượt - Từ ga $startStation"),
      ),
      body: ListView.builder(
        itemCount: destStations.length,
        itemBuilder: (context, i) {
          String destStation = destStations[i];
          int distance = (stations.indexOf(destStation) - startIndex).abs();
          int price = calculatePrice(distance);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.train, size: 32, color: Colors.blue),
              title: Text("Đến ga $destStation"),
              subtitle: Text("Giá: $price đ"),
              onTap: () {
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
