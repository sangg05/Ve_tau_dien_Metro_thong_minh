#include <Wire.h>
#include <Adafruit_PN532.h>
#include <WiFi.h>
#include <HTTPClient.h>

// ==== WiFi & Backend ====
const char* ssid = "Nha Tro Sinh Vien";
const char* password = "0971471067";
const char* serverName = "http://192.168.1.9:8000/api/scan/"; // Đổi IP server của bạn

// ==== PN532 I2C ====
#define SDA_PIN 25
#define SCL_PIN 26
#define PN532_IRQ   (2)   // dummy pin
#define PN532_RESET (3)   // dummy pin
Adafruit_PN532 nfc(PN532_IRQ, PN532_RESET);

// ==== LED & Buzzer ====
#define LED_PIN 32
#define BUZZER_PIN 33

// ==== Station Name ====
String currentStation = "Ga Demo";

void connectWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Đang kết nối WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP ESP32: ");
  Serial.println(WiFi.localIP());
}

void sendScan(String card_uid, String station) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    String payload = "{\"card_uid\":\"" + card_uid + "\",\"station\":\"" + station + "\"}";
    int httpResponseCode = http.POST(payload);

    if (httpResponseCode > 0) {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      String response = http.getString();
      Serial.print("Response từ server: ");
      Serial.println(response);
    } else {
      Serial.print("Lỗi gửi: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  }
}

void successFeedback() {
  digitalWrite(LED_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  delay(300);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
}

void setup() {
  Serial.begin(115200);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  connectWiFi();

  // I2C init
  Wire.begin(SDA_PIN, SCL_PIN);

  // PN532 init
  nfc.begin();
  uint32_t versiondata = nfc.getFirmwareVersion();
  if (!versiondata) {
    Serial.println("Không tìm thấy PN532 :( kiểm tra dây nối!");
    while (1);
  }
  nfc.SAMConfig();
  Serial.println("Đang chờ quét thẻ...");
}

void loop() {
  uint8_t uid[7]; 
  uint8_t uidLength;

  if (nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength)) {
    Serial.print("UID thẻ: ");
    String uidString = "";
    for (uint8_t i = 0; i < uidLength; i++) {
      Serial.print(uid[i], HEX);
      uidString += String(uid[i], HEX);
    }
    Serial.println("");

    // Feedback: LED + Buzzer
    successFeedback();

    // Gửi về server
    sendScan(uidString, currentStation);

    delay(1000); // tránh quét trùng nhiều lần
  }
}
