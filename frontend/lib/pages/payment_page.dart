import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // để copy vào clipboard

import '../api/api_service.dart';

class PaymentPage extends StatefulWidget {
  final String? startStationId; // UUID ga đi (có thể null nếu là vé thời gian)
  final String? destStationId; // UUID ga đến (có thể null nếu là vé thời gian)
  final String startStationName; // Tên ga đi (hiển thị)
  final String destStationName; // Tên ga đến (hiển thị)
  final int price; // Giá
  final String ticketType; // 'Day_All' | 'Month' | 'Day_Point_To_Point'

  // -------------------- (MỚI) HỖ TRỢ VÉ THỜI GIAN --------------------
  final bool isTimePass; // true nếu là vé thời gian (Day_All/Month)
  final int? passDays; // số ngày sử dụng: 1 | 3 | 30
  // -------------------------------------------------------------------

  const PaymentPage({
    super.key,
    this.startStationId,
    this.destStationId,
    this.startStationName = "",
    this.destStationName = "",
    required this.price,
    required this.ticketType,
    this.isTimePass = false,
    this.passDays,
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

  ({String ticketType, int? days}) _resolveTypeAndDays() {
    if (widget.ticketType == 'Month') {
      return (ticketType: 'Month', days: 30);
    }
    if (widget.ticketType == 'Day_All') {
      final d = widget.passDays ?? (widget.price == 90000 ? 3 : 1);
      return (ticketType: 'Day_All', days: d);
    }
    return (ticketType: 'Day_Point_To_Point', days: 1);
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán!")),
      );
      return;
    }

    if (!widget.isTimePass) {
      if ((widget.startStationId ?? '').isEmpty ||
          (widget.destStationId ?? '').isEmpty) {
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
    }

    setState(() => _submitting = true);

    try {
      final resolved = _resolveTypeAndDays();
      final res = await ApiService.purchaseTicket(
        ticketType: resolved.ticketType,
        price: widget.price.toString(),
        startStationId: widget.isTimePass ? null : widget.startStationId,
        endStationId: widget.isTimePass ? null : widget.destStationId,
        days: resolved.days,
      );

      setState(() => _submitting = false);

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final t = (data['ticket'] ?? {}) as Map<String, dynamic>;
        final records = (t['records'] ?? []) as List;

        // Bỏ field "Route" nếu có
        final filtered = records.where((r) {
          final v = (r['value'] ?? '').toString();
          return !v.startsWith('Route:');
        }).toList();

        final jsonRecords = {"records": filtered};

        final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonRecords);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Mua vé thành công'),
            content: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã copy JSON vào clipboard")),
                  );
                },
                child: const Text('Copy JSON'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
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

    final routeDesc = widget.isTimePass
        ? (widget.ticketType == 'Month'
              ? 'Vé tháng (30 ngày)'
              : 'Vé ${widget.passDays ?? (widget.price == 90000 ? 3 : 1)} ngày')
        : "${widget.startStationName} → ${widget.destStationName}";

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
                  Text("Mô tả: $routeDesc"),
                  Text("Đơn giá: $price đ"),
                  const Text("Số lượng: 1"),
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
