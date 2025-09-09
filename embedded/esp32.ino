#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "302/36";
const char* password = "Bo@302/36;
const char* server = "http://127.0.0.1:8000/api/device/ESP32_1/"; // Django API

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void loop() {
  if(WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(server);
    int httpCode = http.GET();

    if (httpCode == 200) {
      String payload = http.getString();
      Serial.println(payload);

      // Parse JSON
      StaticJsonDocument<256> doc;
      deserializeJson(doc, payload);
      String stationName = doc["station_name"];
      Serial.print("ESP32 đang ở ga: ");
      Serial.println(stationName);
    }
    http.end();
  }
  delay(5000); // 5s check lại
}
