#Dùng passbook để add vé vô Apple Wallet
from passbook.models import Pass, Barcode, StoreCard
from datetime import datetime, timedelta
from api.models import Ticket  # giả sử model tên Ticket
import os

# Hàm tạo pkpass từ ticket object
def create_ticket_pass(ticket):
    # Thời gian hiệu lực: 1 tháng từ ngày bắt đầu
    valid_from = ticket.start_date
    valid_to = valid_from + timedelta(days=30)

    # Tạo Pass
    passfile = Pass()
    passfile.serialNumber = str(ticket.ticket_id)
    passfile.description = f"Metro Ticket for {ticket.user_name}"
    passfile.organizationName = "Metro Demo"
    passfile.logoText = "Metro Demo"

    # Thông tin vé
    boarding = StoreCard()
    boarding.primaryFields.append({
        "key": "start_station",
        "label": "From",
        "value": ticket.start_station
    })
    boarding.primaryFields.append({
        "key": "end_station",
        "label": "To",
        "value": ticket.end_station
    })
    boarding.secondaryFields.append({
        "key": "user",
        "label": "User",
        "value": ticket.user_name
    })
    boarding.auxiliaryFields.append({
        "key": "valid_from",
        "label": "Valid From",
        "value": valid_from.strftime("%Y-%m-%d")
    })
    boarding.auxiliaryFields.append({
        "key": "valid_to",
        "label": "Valid To",
        "value": valid_to.strftime("%Y-%m-%d")
    })

    passfile.addPassInformation(boarding)

    # Barcode QR code
    barcode = Barcode()
    barcode.message = str(ticket.ticket_id)
    barcode.format = "PKBarcodeFormatQR"
    passfile.barcode = barcode

    # Lưu file vào media/pkpass/
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../media/pkpass")
    os.makedirs(output_dir, exist_ok=True)
    file_path = os.path.join(output_dir, f"{ticket.ticket_id}.pkpass")
    passfile.create(file_path)
    return file_path

# Demo: lấy 1 ticket gần nhất trong DB
if __name__ == "__main__":
    ticket = Ticket.objects.latest('id')
    file_path = create_ticket_pass(ticket)
    print(f"Đã tạo vé Apple Wallet: {file_path}")
