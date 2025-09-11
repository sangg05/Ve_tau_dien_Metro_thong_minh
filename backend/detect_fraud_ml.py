import os
import django
import pandas as pd
from sklearn.ensemble import IsolationForest
from datetime import timedelta
from django.utils import timezone

# --- Setup Django environment ---
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import ScanRecord, Ticket, FraudLog

# --- 1. Lấy dữ liệu ScanRecord ---
records = ScanRecord.objects.all().order_by('timestamp')
data = pd.DataFrame.from_records(records.values(
    'scan_id', 'card_uid', 'station_id', 'device_type', 'timestamp', 'ticket_found'
))

if data.empty:
    print("Chưa có dữ liệu ScanRecord!")
    exit()

# Chuyển timestamp sang datetime
data['timestamp'] = pd.to_datetime(data['timestamp'])

# --- 2. Rule-based detection ---
fraud_rule_ids = []

# Rule 1: Quẹt nhiều lần cùng ga trong 10 phút
time_window = timedelta(minutes=10)
for card_uid, group in data.groupby('card_uid'):
    group = group.sort_values('timestamp')
    for i in range(len(group)):
        window_start = group.iloc[i]['timestamp']
        window_end = window_start + time_window
        count = group[(group['timestamp'] >= window_start) & 
                      (group['timestamp'] <= window_end) &
                      (group['station_id'] == group.iloc[i]['station_id'])].shape[0]

        # Kiểm tra số lần check-in/out cùng ga theo số lẻ
        if count >= 5:
            # Lấy chuỗi device_type
            seq = group[(group['timestamp'] >= window_start) & 
                        (group['timestamp'] <= window_end) &
                        (group['station_id'] == group.iloc[i]['station_id'])]['device_type'].tolist()
            checkin_count = seq.count('CheckIn')
            checkout_count = seq.count('CheckOut')
            # Nếu tổng số lẻ (checkin/out chẵn) thì bỏ qua
            if (checkin_count % 2 == 0 and checkout_count % 2 == 0):
                fraud_rule_ids.extend(group[(group['timestamp'] >= window_start) & 
                                            (group['timestamp'] <= window_end) &
                                            (group['station_id'] == group.iloc[i]['station_id'])]['scan_id'].tolist())

fraud_rule_ids = list(set(fraud_rule_ids))
print(f"Rule-based detected {len(fraud_rule_ids)} suspicious scans")

# --- 3. ML-based detection (Isolation Forest) ---
features = data[['card_uid', 'station_id', 'device_type', 'timestamp']].copy()

# Feature engineering
features['card_uid'] = features['card_uid'].apply(lambda x: int(x[:8], 16))
features['station_code'] = features['station_id'].astype('category').cat.codes
features['device_code'] = features['device_type'].map({'CheckIn':0, 'CheckOut':1}).fillna(-1)
features['timestamp_seconds'] = features['timestamp'].astype('int64') // 1e9

X = features[['card_uid', 'station_code', 'device_code', 'timestamp_seconds']]

clf = IsolationForest(n_estimators=100, contamination=0.01, random_state=42)
clf.fit(X)
data['anomaly_ml'] = clf.predict(X)  # -1 = bất thường

fraud_ml_ids = data[data['anomaly_ml']==-1]['scan_id'].tolist()
print(f"ML-based detected {len(fraud_ml_ids)} suspicious scans")

# --- 4. Kết hợp Rule + ML ---
combined_fraud_ids = set(fraud_rule_ids) | set(fraud_ml_ids)
print(f"Total detected frauds: {len(combined_fraud_ids)}")

# --- 5. Lưu vào FraudLog ---
for scan_id in combined_fraud_ids:
    scan = ScanRecord.objects.get(scan_id=scan_id)
    ticket = Ticket.objects.filter(card_uid=scan.card_uid).first()
    if ticket:
        FraudLog.objects.create(
            ticket=ticket,
            description=f"Fraud detected by combined Rule+ML. Station: {scan.station_id}, Device: {scan.device_type}"
        )

print("✅ FraudLog updated with combined detections")
