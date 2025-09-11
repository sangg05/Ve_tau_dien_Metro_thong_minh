import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'payment_page.dart';

class TicketDetailPage extends StatefulWidget {
  final int startIndex;
  final List<String> stations; // danh sách TÊN ga dùng để hiển thị

  const TicketDetailPage({
    super.key,
    required this.startIndex,
    required this.stations,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  bool _loading = true;
  String? _error;

  /// map tên ga -> UUID ga
  final Map<String, String> _nameToId = {};

  // Giá vé = 6000đ cơ bản + 1000đ mỗi ga (khoảng cách tuyệt đối)
  int _calculatePrice(int distance) => 6000 + distance * 1000;

  @override
  void initState() {
    super.initState();
    _loadStationIds();
  }

  Future<void> _loadStationIds() async {
    try {
      final list = await ApiService.getStations();
      for (final s in list) {
        final name = (s['station_name'] ?? '').toString().trim();
        final id = (s['station_id'] ?? '').toString();
        if (name.isNotEmpty && id.isNotEmpty) {
          _nameToId[name] = id;
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Không tải được danh sách ga: $e';
        _loading = false;
      });
    }
  }

  void _goToPayment({
    required String startName,
    required String destName,
    required int price,
  }) {
    final startId = _nameToId[startName];
    final destId = _nameToId[destName];

    if (startId == null || destId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy UUID ga. Vui lòng thử lại.'),
        ),
      );
      return;
    }
    if (startId == destId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ga đi và Ga đến không được trùng')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          startStationId: startId,
          destStationId: destId,
          startStationName: startName,
          destStationName: destName,
          price: price,
          ticketType: 'Day_All', // vé lượt/1–n ngày → backend tính hạn
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // tên ga xuất phát
    final String startStation = widget.stations[widget.startIndex];

    // danh sách ga đích (loại bỏ ga xuất phát)
    final List<String> destStations = [
      for (int i = 0; i < widget.stations.length; i++)
        if (i != widget.startIndex) widget.stations[i],
    ];

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[200],
          title: const Text('Chi tiết vé'),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text("Vé lượt - Từ ga $startStation"),
      ),
      body: ListView.builder(
        itemCount: destStations.length,
        itemBuilder: (context, i) {
          final String destStation = destStations[i];
          final int distance =
              (widget.stations.indexOf(destStation) - widget.startIndex).abs();
          final int price = _calculatePrice(distance);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.train, size: 32, color: Colors.blue),
              title: Text("Đến ga $destStation"),
              subtitle: Text("Giá: $price đ"),
              onTap: () => _goToPayment(
                startName: startStation,
                destName: destStation,
                price: price,
              ),
            ),
          );
        },
      ),
    );
  }
}
