import os
import django
from datetime import timedelta
from django.utils import timezone

# setup Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from passbook.models import Pass, Barcode  # lib bạn đã cài
from passbook.passes import StoreCard      # cần import riêng
from api.models import Ticket


def create_ticket_pass(ticket):
    # Lấy thời gian hiệu lực
    valid_from = ticket.valid_from or timezone.now()
    valid_to = ticket.valid_to or (valid_from + timedelta(days=30))

    # Tạo Pass
    passfile = Pass()
    passfile.serialNumber = str(ticket.ticket_id)
    passfile.description = f"Metro Ticket for {ticket.user.full_name}"
    passfile.organizationName = "Metro Demo"
    passfile.logoText = "Metro Demo"

    # Thông tin vé (StoreCard layout)
    boarding = StoreCard()
    boarding.primaryFields.append({
        "key": "start_station",
        "label": "From",
        "value": str(ticket.start_station) if ticket.start_station else "Any"
    })
    boarding.primaryFields.append({
        "key": "end_station",
        "label": "To",
        "value": str(ticket.end_station) if ticket.end_station else "Any"
    })
    boarding.secondaryFields.append({
        "key": "user",
        "label": "User",
        "value": ticket.user.full_name
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

    # Barcode QR
    barcode = Barcode()
    barcode.message = str(ticket.ticket_id)
    barcode.format = "PKBarcodeFormatQR"
    passfile.barcode = barcode

    # Lưu file pkpass
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "media", "pkpass")
    os.makedirs(output_dir, exist_ok=True)
    file_path = os.path.join(output_dir, f"{ticket.ticket_id}.pkpass")
    passfile.create(file_path)
    return file_path


if __name__ == "__main__":
    ticket = Ticket.objects.latest("valid_from")
    file_path = create_ticket_pass(ticket)
    print(f"✅ Đã tạo vé Apple Wallet: {file_path}")
