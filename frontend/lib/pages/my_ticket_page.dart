import 'package:flutter/material.dart';

import '../api/api_service.dart'; // gọi API lấy vé
import 'Buy_ticket.dart';
import 'transaction_history_page.dart';
import 'home_page.dart';

class MyTicketPage extends StatefulWidget {
  const MyTicketPage({super.key});

  @override
  State<MyTicketPage> createState() => _MyTicketPageState();
}

class _MyTicketPageState extends State<MyTicketPage> {
  String selectedTab = "using"; // using = Đang sử dụng, unused = Chưa sử dụng
  int selectedBottomIndex = 1; // 0 = Mua vé, 1 = Vé của tôi, 2 = Lịch sử

  // Trạng thái tải dữ liệu
  bool _loading = true;
  String? _error;

  // Danh sách vé từ backend (đã chia nhóm)
  List<Map<String, dynamic>> _usingTickets = [];
  List<Map<String, dynamic>> _unusedTickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // Lấy vé từ API và phân loại
  Future<void> _loadTickets() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Trả về List<Map<String, dynamic>>
      final list = await ApiService.getMyTickets();
      final now = DateTime.now().toUtc();

      final using = <Map<String, dynamic>>[];
      final unused = <Map<String, dynamic>>[];

      for (final raw in list) {
        final t = Map<String, dynamic>.from(raw);

        // Phân loại đơn giản:
        // - "Đang sử dụng": ticket_status = Active và (nếu có valid_to) chưa hết hạn
        // - Còn lại cho vào "Chưa sử dụng"/khác
        final status = (t['ticket_status'] ?? '').toString().toLowerCase();
        final isActive = status == 'active';

        bool isExpired = false;
        final vt = (t['valid_to'] ?? '').toString();
        if (vt.isNotEmpty) {
          try {
            isExpired = DateTime.parse(vt).isBefore(now);
          } catch (_) {}
        }

        if (isActive && !isExpired) {
          using.add(t);
        } else {
          unused.add(t);
        }
      }

      setState(() {
        _usingTickets = using;
        _unusedTickets = unused;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải vé: $e';
        _loading = false;
      });
    }
  }

  // Lấy mã vé ngắn để hiển thị
  String _displayCode(Map<String, dynamic> t) {
    return (t['ticket_code'] ?? t['short_code'] ?? t['ticket_id'] ?? '')
        .toString();
  }

  // Item UI cho 1 vé
  Widget _ticketTile(Map<String, dynamic> t) {
    final code = _displayCode(t);
    final type = (t['ticket_type'] ?? '').toString();
    final price = (t['price'] ?? '').toString();
    final validTo = (t['valid_to'] ?? '').toString();
    final status = (t['ticket_status'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text('Mã: $code'),
        subtitle: Text(
          'Loại: $type\nGiá: $price\nHSD: ${validTo.isEmpty ? "(vé ngày)" : validTo}',
        ),
        trailing: Text(
          status,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // TODO: mở chi tiết vé (nếu có màn chi tiết)
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = selectedTab == "using" ? _usingTickets : _unusedTickets;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        elevation: 0,
        title: const Text("Vé của tôi", style: TextStyle(color: Colors.black)),
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

      body: _loading
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
                      onPressed: _loadTickets,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tải lại'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 12),
                // Tabbar custom
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Đang sử dụng"),
                      selected: selectedTab == "using",
                      selectedColor: Colors.blue[200],
                      onSelected: (_) => setState(() => selectedTab = "using"),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("Chưa sử dụng"),
                      selected: selectedTab == "unused",
                      selectedColor: Colors.blue[200],
                      onSelected: (_) => setState(() => selectedTab = "unused"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Danh sách vé hoặc thông báo rỗng
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: tickets.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  "Bạn không có vé nào",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: tickets.length,
                            itemBuilder: (context, index) =>
                                _ticketTile(tickets[index]),
                          ),
                  ),
                ),
              ],
            ),

      // Thanh điều hướng dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedBottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        iconSize: 22,
        onTap: (index) {
          if (index == selectedBottomIndex)
            return; // nếu bấm lại tab hiện tại thì bỏ qua
          setState(() => selectedBottomIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BuyTicketPage()),
              );
              break;
            case 1:
              // Vé của tôi, đang ở đây → không làm gì
              break;
            case 2:
              Navigator.pushReplacement(
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
}
