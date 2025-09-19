import xml.etree.ElementTree as ET
import re
import mysql.connector

# Load and parse my XML file
tree = ET.parse("../data/modified_sms_v2 (1).xml")
root = tree.getroot()

# Get all SMS elements
sms_list = root.findall("sms")

# Define a function to extract data using regex
def extract_fields(body):
    # Match both "TxId: ..." and "Financial Transaction Id: ..."
    tx_id_match = re.search(r"TxId[:]? ?(\d+)", body)
    if not tx_id_match:
        tx_id_match = re.search(r"Financial Transaction Id[:]? ?(\d+)", body, re.IGNORECASE)

    amount_match = re.search(r"([0-9,]+) RWF", body)
    date_match = re.search(r"at (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})", body)

    tx_id = tx_id_match.group(1) if tx_id_match else "N/A"
    amount = amount_match.group(1).replace(",", "") if amount_match else "N/A"
    date = date_match.group(1) if date_match else "N/A"

    return tx_id, amount, date

def categorize_sms(body):
    if "You have received" in body:
        return "Incoming Money"
    elif "Your payment of" in body and "to" in body:
        return "Payment"
    elif "transferred to" in body and "from" in body:
        return "Transfer to Mobile"
    elif "bank deposit" in body.lower():
        return "Bank Deposit"
    elif "Cash Power" in body or "token" in body:
        return "Utility Payment"
    elif "withdrawn" in body and "via agent" in body:
        return "Withdrawal"
    else:
        return "Unknown"
    # --- Connect to SQLite DB ---
conn = mysql.connector.connect(
    host="localhost",
    user="root",       # or your MySQL user
    password="",       # or your password
    database="momo_db"
)
cursor = conn.cursor()

# --- Create Table ---
cursor.execute("""
CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id TEXT,
    amount INTEGER,
    date TEXT,
    category TEXT,
    raw_body TEXT
)
""")

# --- Insert SMS Messages ---
inserted = 0
for sms in sms_list:
    body = sms.attrib.get("body", "")
    tx_id, amount, date = extract_fields(body)
    category = categorize_sms(body)

    # Skip if amount or date missing
    if not amount or not date:
        continue

    cursor.execute("""
    INSERT INTO transactions (transaction_id, amount, date, category, raw_body)
    VALUES (?, ?, ?, ?, ?)
    """, (tx_id, amount, date, category, body))
    inserted += 1

conn.commit()
conn.close()

print(f"\n✅ {inserted} transactions inserted into sms_data.db")