import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                // TODO: mở danh sách chọn phương thức
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Phương thức thanh toán"),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
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
                  Text("Địa điểm: $startStation → $destStation"),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thanh toán thành công!")),
                  );
                },
                child: Text("Thanh toán: $price đ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
