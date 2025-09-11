# ESP32 - NFC Metro System

Firmware cho **ESP32** kết hợp **PN532 NFC**, **LED**, và **Buzzer** trong hệ thống vé điện tử Metro.  
ESP32 đọc thẻ NFC và gửi UID về **Django Backend** để kiểm tra tính hợp lệ.  

---

## 📦 Phần cứng sử dụng
- ESP32 DevKit v1
- PN532 (giao tiếp I2C)
- LED ngoài (có điện trở hạn dòng 220–330Ω)
- Buzzer (loại active, TMB12A03)
- Dây cắm breadboard

---

## 🔌 Sơ đồ nối dây

| Thiết bị   | ESP32 GPIO |
|------------|------------|
| PN532 SDA  | 25         |
| PN532 SCL  | 26         |
| PN532 VCC  | 3V3        |
| PN532 GND  | GND        |
| LED +      | 32 (qua điện trở) |
| LED –      | GND        |
| Buzzer +   | 33         |
| Buzzer –   | GND        |

Ngoài ra ESP32 có LED on-board ở chân GPIO 2 (cũng sẽ nháy khi quét thành công).

---

## ⚙️ Cấu hình WiFi & Backend
Trong file `esp32_nfc.ino`, chỉnh lại:

```cpp
const char* ssid = "YOUR_WIFI_NAME";        // tên WiFi 2.4GHz tại sài nhiều mạng nên tụi em để vậy
const char* password = "YOUR_WIFI_PASS";    // mật khẩu WiFi
const char* serverURL = "http://127.0.0.1:8000/api/nfc/";
