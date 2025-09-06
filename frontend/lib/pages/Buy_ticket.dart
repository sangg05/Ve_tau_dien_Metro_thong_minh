import 'package:flutter/material.dart';
import 'TicketDetailPage.dart';
import 'my_ticket_page.dart';
import 'transaction_history_page.dart';
import 'home_page.dart';
import 'payment_page.dart'; // import thêm PaymentPage

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
              _ticketCard(context, "Vé 1 ngày", 40000),
              _ticketCard(context, "Vé 3 ngày", 90000),
              _ticketCard(context, "Vé tháng", 300000),
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
              _ticketCard(context, "Vé tháng HSSV", 150000),
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

      // 👉 Thanh navigation nhỏ gọn ở dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        iconSize: 22,
        onTap: (index) {
          switch (index) {
            case 0:
              // Mua vé, hiện tại đang ở đây
              break;
            case 1:
              // Vé của tôi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyTicketPage()),
              );
              break;
            case 2:
              // Lịch sử
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionHistoryPage()),
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

  // Widget card vé (bấm được → sang PaymentPage)
  Widget _ticketCard(BuildContext context, String title, int price) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              startStation: "Bến Thành", // mặc định ga đầu
              destStation: "Bến xe Suối Tiên", // mặc định ga cuối
              price: price,
            ),
          ),
        );
      },
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
            const Icon(Icons.confirmation_number,
                size: 26, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            Text("$price đ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
