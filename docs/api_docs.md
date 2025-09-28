# 📄 MoMo SMS API Documentation

This API provides access to mobile money SMS transaction records via standard RESTful endpoints.

---

## 🔐 Authentication

All endpoints are protected using **Basic Authentication**.

- **Username:** `user`
- **Password:** `momo123`

If you send a request without correct credentials, you will get a response like:

```json
{
  "error": "Unauthorized "
}
📡 API Endpoints
Method	Endpoint	Description
GET	/transactions	Get a list of all transactions
GET	/transactions/{id}	Get a single transaction by ID
POST	/transactions	Add a new transaction
PUT	/transactions/{id}	Update an existing transaction
DELETE	/transactions/{id}	Delete a transaction

⚠️ All endpoints require valid Basic Auth credentials (user:momo123)

🧪 Example Requests (using curl)
✅ Get all transactions
bash
Copy code
curl -u user:momo123 http://localhost:8000/transactions
✅ Get one transaction
bash
Copy code
curl -u user:momo123 http://localhost:8000/transactions/T0001
✅ Add a new transaction
bash
Copy code
curl -u user:momo123 -X POST http://localhost:8000/transactions \
-H "Content-Type: application/json" \
-d '{
  "id": "T0005",
  "protocol": "0",
  "address": "M-Money",
  "date": "1715351670000",
  "type": "1",
  "subject": "null",
  "body": "You sent 500 RWF to John Doe (*********456).",
  "toa": "null",
  "sc_toa": "null",
  "service_center": "+250788110381",
  "read": "1",
  "status": "-1",
  "locked": "0",
  "date_sent": "1715351670000",
  "sub_id": "6",
  "readable_date": "10 May 2024 4:35:00 PM",
  "contact_name": "(Unknown)",
  "amount": 500
}'
✅ Update an existing transaction
bash
Copy code
curl -u user:momo123 -X PUT http://localhost:8000/transactions/T0001 \
-H "Content-Type: application/json" \
-d '{
  "id": "T0001",
  "protocol": "0",
  "address": "M-Money",
  "date": "1715351458724",
  "type": "1",
  "subject": "null",
  "body": "You have received 2500 RWF from Jane Smith (*********013).",
  "toa": "null",
  "sc_toa": "null",
  "service_center": "+250788110381",
  "read": "1",
  "status": "-1",
  "locked": "0",
  "date_sent": "1715351451000",
  "sub_id": "6",
  "readable_date": "10 May 2024 4:30:58 PM",
  "contact_name": "(Unknown)",
  "amount": 2500
}'
✅ Delete a transaction
bash
Copy code
curl -u user:momo123 -X DELETE http://localhost:8000/transactions/T0001
⚠️ Error Responses
Status Code	Meaning	Example Response
401	Unauthorized	{ "error": "Unauthorized access" }
404	Not Found	{ "error": "Transaction not found" }
400	Bad Request / Invalid	{ "error": "Invalid ID" }

✅ Sample Transaction Structure
json
Copy code
{
  "id": "T0001",
  "protocol": "0",
  "address": "M-Money",
  "date": "1715351458724",
  "type": "1",
  "subject": "null",
  "body": "You have received 2000 RWF from Jane Smith...",
  "toa": "null",
  "sc_toa": "null",
  "service_center": "+250788110381",
  "read": "1",
  "status": "-1",
  "locked": "0",
  "date_sent": "1715351451000",
  "sub_id": "6",
  "readable_date": "10 May 2024 4:30:58 PM",
  "contact_name": "(Unknown)",
  "amount": 2000
}
✅ Notes
All request/response data is in JSON.

You must include id in every POST or PUT request.

id must be unique. If it already exists during POST, you’ll get an error.