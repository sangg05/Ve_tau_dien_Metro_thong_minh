import 'package:flutter/material.dart';
import 'TicketDetailPage.dart';
import 'payment_page.dart';
import 'my_ticket_page.dart';
import 'history_page.dart';

class BuyTicketPage extends StatefulWidget {
  const BuyTicketPage({super.key});

  @override
  State<BuyTicketPage> createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBuyTicket(context),
      const MyTicketPage(),
      const TransactionHistoryPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black54,
        iconSize: 22,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Mua vé",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Vé của tôi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Lịch sử",
          ),
        ],
      ),
    );
  }

  // Giao diện mua vé
  Widget _buildBuyTicket(BuildContext context) {
      return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.green[200],
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Mua vé",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

     body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const Text(
              "Ưu đãi Học sinh Sinh viên",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            _ticketCard(context, "Vé tháng HSSV", 150000),
            const SizedBox(height: 20),

            const Text(
              "Danh sách ga",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
  );
}

  Widget _ticketCard(BuildContext context, String title, int price) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              startStation: "Gói $title",
              destStation: "Không áp dụng ga",
              price: price,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
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
            const Icon(Icons.confirmation_num_outlined, size: 26),
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
