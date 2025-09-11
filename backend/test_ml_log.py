import os
import sys
import django
import joblib
import numpy as np

# --- Thêm thư mục backend vào path ---
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# --- Chỉ định settings ---
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from api.models import Ticket, FraudLog

# --- Chọn ticket để test ---
TEST_CARD_UID = "93CC210F"  # thay card UID khác nếu cần

ticket = Ticket.objects.filter(card_uid=TEST_CARD_UID).first()
if not ticket:
    print(f"Ticket {TEST_CARD_UID} không tồn tại trong DB.")
    sys.exit(1)

# --- Load model + scaler ---
MODEL_PATH = os.path.join(os.path.dirname(__file__), 'ml_models/logistic_fraud_model.pkl')
SCALER_PATH = os.path.join(os.path.dirname(__file__), 'ml_models/scaler.pkl')

ml_model = joblib.load(MODEL_PATH)
ml_scaler = joblib.load(SCALER_PATH)

# --- Tạo feature giả lập đủ cao để ML dự đoán fraud ---
# Bạn có thể tùy chỉnh giá trị để xác suất cao hơn
last_station_count = 6       # >5 lần liên tiếp cùng ga
daily_scan_count = 8         # tần suất cao
recent_devices = 2           # giả lập số thiết bị gần đây

features = np.array([[last_station_count, daily_scan_count, recent_devices]])
features_scaled = ml_scaler.transform(features)

# --- Dự đoán xác suất fraud ---
fraud_prob = ml_model.predict_proba(features_scaled)[0][1]
print(f"ML predicted fraud probability: {fraud_prob:.2f}")

# --- Nếu xác suất > 0.5, tạo FraudLog ---
if fraud_prob > 0.5:
    log = FraudLog.objects.create(
        ticket=ticket,
        description=f"ML predicted fraud: {fraud_prob:.2f}"
    )
    print(f"FraudLog đã tạo: {log.description}, detected_time: {log.detected_time}")
else:
    print("Xác suất fraud thấp, không tạo log.")
