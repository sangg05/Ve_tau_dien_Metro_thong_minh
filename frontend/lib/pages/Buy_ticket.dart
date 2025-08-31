import 'package:flutter/material.dart';
import 'TicketDetailpage.dart';

class BuyTicketPage extends StatelessWidget {
  const BuyTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> stations = [
      "Bến Thành", 
      "Nhà hát Thành phố",
      "Ba Son",
      "Văn Thánh",
      "Tân Cảng",
      "Thảo Điền",
      "An Phú",
      "Rạch Chiếc",
      "Phước Long",
      "Bình Thái",
      "Thủ Đức",
      "Khu Công nghệ cao",
      "Đại học Quốc gia",
      "Bến xe Suối Tiên",
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
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
              // --- Nổi bật ---
              const Text(
                "Nổi bật",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              _ticketCard("Vé 1 ngày", "40.000 đ"),
              _ticketCard("Vé 3 ngày", "90.000 đ"),
              _ticketCard("Vé tháng", "300.000 đ"),
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
              _ticketCard("Vé tháng HSSV", "150.000 đ"),
              const SizedBox(height: 20),

              // --- Danh sách ga ---
              const Text(
                "Danh sách ga",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Đi từ ga ${stations[index]}"),
                    trailing: const Text(
                      "Xem chi tiết",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      // 👉 Chuyển sang TicketDetailPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailPage(
                            startIndex: index,
                            stations: stations,
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
    );
  }

  // Widget card vé
  Widget _ticketCard(String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_num_outlined, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
