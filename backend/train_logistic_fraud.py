import os
import django
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib

import os
import sys
import django

# Thêm thư mục backend vào path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Chỉ định đúng settings module
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

django.setup()


from api.models import ScanRecord, Ticket

# --- Load dữ liệu ScanRecord từ DB ---
scans = ScanRecord.objects.select_related('station').all()

data = []
for scan in scans:
    ticket = Ticket.objects.filter(card_uid=scan.card_uid).first()
    if ticket:
        # các feature cơ bản
        last_station_count = getattr(ticket, 'last_station_count', 0)
        daily_scan_count = ScanRecord.objects.filter(
            card_uid=scan.card_uid, timestamp__date=scan.timestamp.date()
        ).count()
        recent_devices = ScanRecord.objects.filter(
            card_uid=scan.card_uid,
            timestamp__gte=scan.timestamp - pd.Timedelta(seconds=30)
        ).exclude(device_id=scan.device_id).count()

        # target: 1 nếu là fraud, 0 nếu bình thường
        # dựa vào FraudLog hiện tại
        is_fraud = 1 if hasattr(ticket, 'fraudlog_set') and ticket.fraudlog_set.exists() else 0

        data.append({
            'last_station_count': last_station_count,
            'daily_scan_count': daily_scan_count,
            'recent_devices': recent_devices,
            'is_fraud': is_fraud
        })

df = pd.DataFrame(data)

# --- Chia feature / target ---
X = df[['last_station_count', 'daily_scan_count', 'recent_devices']]
y = df['is_fraud']

# --- Chuẩn hóa dữ liệu ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# --- Chia train/test ---
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# --- Train Logistic Regression ---
clf = LogisticRegression()
clf.fit(X_train, y_train)

# --- Kiểm tra accuracy ---
score = clf.score(X_test, y_test)
print(f"Model accuracy: {score*100:.2f}%")

# --- Lưu model + scaler ---
model_dir = os.path.join(os.path.dirname(__file__), 'ml_models')
os.makedirs(model_dir, exist_ok=True)

joblib.dump(clf, os.path.join(model_dir, 'logistic_fraud_model.pkl'))
joblib.dump(scaler, os.path.join(model_dir, 'scaler.pkl'))

print("Mô hình Logistic Regression đã lưu xong!")
