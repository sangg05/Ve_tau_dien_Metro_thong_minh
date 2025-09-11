import 'dart:convert';
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import 'my_ticket_page.dart'; // điều hướng tới "Vé của tôi"

class PaymentPage extends StatefulWidget {
  final String startStationId; // UUID ga đi
  final String destStationId; // UUID ga đến
  final String startStationName; // Tên ga đi (hiển thị)
  final String destStationName; // Tên ga đến (hiển thị)
  final int price; // Giá
  final String ticketType; // 'Day_All' | 'Month' | 'Day_Point_To_Point'

  const PaymentPage({
    super.key,
    required this.startStationId,
    required this.destStationId,
    required this.startStationName,
    required this.destStationName,
    required this.price,
    required this.ticketType,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod; // MoMo / Ngân hàng
  bool _submitting = false;

  Future<void> _choosePaymentMethod() async {
    final method = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Chọn phương thức thanh toán",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android, color: Colors.purple),
            title: const Text("MoMo"),
            onTap: () => Navigator.pop(context, "MoMo"),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance, color: Colors.blue),
            title: const Text("Ngân hàng"),
            onTap: () => Navigator.pop(context, "Ngân hàng"),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    if (method != null) {
      setState(() => _selectedMethod = method);
    }
  }

  // Nếu là vé ngày thì set days (vd: 1 ngày, 3 ngày). Vé tháng thì không gửi days.
  ({String ticketType, int? days}) _resolveTypeAndDays() {
    if (widget.ticketType == 'Month') {
      return (ticketType: 'Month', days: null);
    }
    // ticketType là vé ngày → xác định theo price (tuỳ rule của bạn)
    if (widget.price == 90000) {
      return (ticketType: 'Day_All', days: 3);
    }
    // mặc định 1 ngày
    return (ticketType: 'Day_All', days: 1);
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán!")),
      );
      return;
    }

    // Kiểm tra ID ga
    if (widget.startStationId.isEmpty || widget.destStationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thiếu UUID ga. Vui lòng chọn lại hành trình."),
        ),
      );
      return;
    }
    if (widget.startStationId == widget.destStationId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ga đi và Ga đến không được trùng.")),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final resolved = _resolveTypeAndDays();
      final res = await ApiService.purchaseTicket(
        ticketType: resolved.ticketType,
        price: widget.price.toString(),
        startStationId: widget.startStationId,
        endStationId: widget.destStationId,
        days: resolved.days, // chỉ gửi khi là vé ngày
      );

      setState(() => _submitting = false);

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final t = (data['ticket'] ?? {}) as Map<String, dynamic>;

        // Ưu tiên: ticket_code -> short_code -> ticket_id
        final code =
            (t['ticket_code'] ?? t['short_code'] ?? t['ticket_id'] ?? '')
                .toString();

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Mua vé thành công'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã vé: $code'),
                Text('Loại: ${t['ticket_type'] ?? ''}'),
                Text('Giá: ${t['price'] ?? ''}'),
                Text('Hạn dùng: ${t['valid_to'] ?? '(vé ngày)'}'),
                Text('Trạng thái: ${t['ticket_status'] ?? ''}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // đóng dialog
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Điều hướng sang "Vé của tôi" để thấy vé vừa mua
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyTicketPage()),
        );
      } else {
        // cố gắng bóc tách message lỗi từ backend
        String msg = 'Lỗi: ${res.statusCode}';
        try {
          final err = jsonDecode(res.body);
          if (err is Map && err['error'] != null) {
            msg = err['error'].toString();
          } else if (err is Map && err['detail'] != null) {
            msg = err['detail'].toString();
          }
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  Widget _buildPaymentMethodTile() {
    if (_selectedMethod == null) {
      return ListTile(
        leading: const Icon(Icons.payment, color: Colors.grey),
        title: const Text("Chọn phương thức thanh toán"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _choosePaymentMethod,
      );
    }
    return ListTile(
      leading: Icon(
        _selectedMethod == "MoMo" ? Icons.phone_android : Icons.account_balance,
        color: _selectedMethod == "MoMo" ? Colors.purple : Colors.blue,
      ),
      title: Text(
        _selectedMethod!,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _choosePaymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.price;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: const Text("Thanh Toán"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Phương thức thanh toán",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: _buildPaymentMethodTile(),
            ),

            const SizedBox(height: 20),

            const Text("Thông tin thanh toán", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Địa điểm: ${widget.startStationName} → ${widget.destStationName}",
                  ),
                  Text("Đơn giá: $price đ"),
                  const Text("Số lượng: 1"),
                  Text("Thành tiền: $price đ"),
                  const SizedBox(height: 6),
                  Text(
                    "Tổng giá tiền: $price đ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Thông tin Vé", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Nếu muốn hiển thị chi tiết hơn thì truyền thêm từ widget.*
                  Text("Loại vé: Tự động theo lựa chọn"),
                  Text("HSD: tự động tính theo loại vé"),
                  Text("Lưu ý: Không hoàn tiền sau khi thanh toán"),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitting ? null : _processPayment,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text("Thanh toán: $price đ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}