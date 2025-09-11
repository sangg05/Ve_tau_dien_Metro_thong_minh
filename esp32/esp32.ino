#include <Wire.h>
#include <Adafruit_PN532.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// ==== WiFi & Backend ====
const char* ssid = "Nha Tro Sinh Vien";
const char* password = "0971471067";
const char* serverScanURL = "http://192.168.1.9:8000/api/scan/";
const char* serverStationURL = "http://192.168.1.9:8000/api/get_station/";

// ==== PN532 I2C ====
#define SDA_PIN 25
#define SCL_PIN 26
TwoWire I2Cone = TwoWire(0);
#define PN532_IRQ   4
#define PN532_RESET 5
Adafruit_PN532 nfc(PN532_IRQ, PN532_RESET, &I2Cone);

// ==== LED & Buzzer ====
#define LED_PIN 32      // LED xanh báo đúng
#define BUZZER_PIN 33   // Buzzer báo đúng
#define LED_RED_PIN 27  // LED đỏ báo sai

// ==== Device Config ====
String deviceID = "";
String stationID = "";
String stationName = "";
String deviceType = ""; // CheckIn / CheckOut

// ==== WiFi Connect ====
void connectWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Đang kết nối WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP ESP32: ");
  Serial.println(WiFi.localIP());
}

// ==== Fetch station info từ backend ====
bool fetchCurrentStation() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠️ WiFi chưa kết nối!");
    return false;
  }

  HTTPClient http;
  String url = String(serverStationURL) + "?device_id=" + deviceID;
  http.begin(url);
  int httpResponseCode = http.GET();

  if (httpResponseCode > 0) {
    String payload = http.getString();
    Serial.println("Stations JSON: " + payload);

    DynamicJsonDocument doc(512);
    DeserializationError error = deserializeJson(doc, payload);
    if (error) {
      Serial.println("⚠️ JSON parse station failed");
      http.end();
      return false;
    }

    if (String(doc["status"]) == "success") {
      stationID = doc["station_id"].as<String>();
      stationName = doc["station_name"].as<String>();
      deviceType = doc["device_type"].as<String>();
      Serial.println("✅ Station hiện tại: " + stationName + " (" + stationID + ")");
      Serial.println("Device type: " + deviceType);
      http.end();
      return true;
    } else {
      Serial.println("⚠️ Backend error: " + String(doc["message"].as<String>()));
      http.end();
      return false;
    }
  } else {
    Serial.println("⚠️ HTTP GET lỗi: " + String(httpResponseCode));
    http.end();
    return false;
  }
}

// ==== Gửi scan card ====
void sendScan(String card_uid) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("⚠️ WiFi chưa kết nối!");
    return;
  }

  HTTPClient http;
  http.begin(serverScanURL);
  http.addHeader("Content-Type", "application/json");

  String payload = "{\"card_uid\":\"" + card_uid + "\",\"station_id\":\"" + stationID + "\",\"device_type\":\"" + deviceType + "\",\"device_id\":\"" + deviceID + "\"}";
  int httpResponseCode = http.POST(payload);

  if (httpResponseCode > 0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    String response = http.getString();
    Serial.println("Response từ server: " + response);

    DynamicJsonDocument doc(512);
    DeserializationError error = deserializeJson(doc, response);
    if (error) {
      Serial.println("⚠️ JSON parse scan failed");
      return;
    }

    bool ticketFound = doc["ticket_found"] | false;
    String errorReason = doc["error_reason"] | "None";
    String startStation = doc["start_station"] | "";
    String endStation = doc["end_station"] | "";

    Serial.println("Ga bắt đầu: " + startStation + " | Ga kết thúc: " + endStation);
    Serial.println("Ticket status: " + String(ticketFound) + " | Error: " + errorReason);

    if (ticketFound) successFeedback();
    else errorFeedback();
  } else {
    Serial.println("⚠️ Lỗi gửi scan: " + String(httpResponseCode));
  }
  http.end();
}

// ==== Feedback LED/Buzzer ====
void successFeedback() {
  digitalWrite(LED_PIN, HIGH);
  digitalWrite(BUZZER_PIN, HIGH);
  delay(300);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
}

void errorFeedback() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_RED_PIN, HIGH);
    delay(200);
    digitalWrite(LED_RED_PIN, LOW);
    delay(200);
  }
}

// ==== Setup ====
void setup() {
  Serial.begin(115200);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);

  // Nhập deviceID lần đầu
  Serial.println("Nhập deviceID cho ESP32 này và nhấn Enter:");
  while (deviceID == "") {
    if (Serial.available()) {
      deviceID = Serial.readStringUntil('\n');
      deviceID.trim();
      Serial.println("Bạn đã nhập deviceID: " + deviceID);
    }
  }

  connectWiFi();

  // I2C init
  I2Cone.begin(SDA_PIN, SCL_PIN, 400000);

  // PN532 init
  nfc.begin();
  uint32_t versiondata = nfc.getFirmwareVersion();
  if (!versiondata) {
    Serial.println("⚠️ Không tìm thấy PN532, kiểm tra dây nối!");
    while (1);
  }
  nfc.SAMConfig();

  // Lấy station từ backend
  if (!fetchCurrentStation()) {
    Serial.println("⚠️ Không lấy được station, dừng chương trình!");
    while (1);
  }

  Serial.println("✅ Ready to scan cards...");
}

// ==== Loop ====
void loop() {
  // 1. Live update deviceID / stationID từ Serial Monitor
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim();

    if (input.startsWith("device:")) {
      String newDevice = input.substring(7);
      newDevice.trim();
      if (newDevice.length() > 0 && newDevice != deviceID) {
        deviceID = newDevice;
        Serial.println("🔄 Đã đổi deviceID sang: " + deviceID);
        if (fetchCurrentStation()) {
          Serial.println("✅ Ga hiện tại: " + stationName + " (" + stationID + ")");
        } else {
          Serial.println("⚠️ Không lấy được station mới từ backend!");
        }
      }
    } else if (input.startsWith("station:")) {
      String newStation = input.substring(8);
      newStation.trim();
      if (newStation.length() > 0) {
        stationID = newStation;
        Serial.println("🔄 Đã đổi ga trực tiếp sang: " + stationID);
      }
    }
  }

  // 2. Quét thẻ NFC
  uint8_t uid[7];
  uint8_t uidLength;
  if (nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength)) {
    String uidString = "";
    for (uint8_t i = 0; i < uidLength; i++) {
      if (uid[i] < 0x10) uidString += "0";
      uidString += String(uid[i], HEX);
    }
    uidString.toUpperCase();
    Serial.println("UID thẻ: " + uidString);

    sendScan(uidString);

    delay(2000); // tránh quét trùng
  }
}