import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String startStation;
  final String destStation;
  final int price;

  const PaymentPage({
    super.key,
    required this.startStation,
    required this.destStation,
    required this.price,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedMethod;

  void _choosePaymentMethod() async {
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
      setState(() {
        _selectedMethod = method;
      });
    }
  }

  void _processPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán!")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thanh toán thành công qua $_selectedMethod!")),
    );
    Navigator.pop(context);
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
            // Phương thức thanh toán
            const Text("Phương thức thanh toán", style: TextStyle(fontSize: 16)),
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

            // Thông tin thanh toán
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
                  Text("Địa điểm: ${widget.startStation} → ${widget.destStation}"),
                  Text("Đơn giá: $price đ"),
                  const Text("Số lượng: 1"),
                  Text("Thành tiền: $price đ"),
                  Text("Tổng giá tiền: $price đ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin vé lượt
            const Text("Thông tin Vé lượt", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loại vé: Vé 1 ngày/ Vé lượt/..."),
                  Text("HSD: "),
                  Text("Lưu ý: "),
                  Text("Mô tả: "),
                ],
              ),
            ),

            const Spacer(),

            // Nút thanh toán
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
                onPressed: _processPayment,
                child: Text("Thanh toán: $price đ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
