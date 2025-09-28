 📌 Project Overview
This project is part of our Week 2 assignment for the MoMo SMS Data Processing System.  
The goal is to design and implement a robust relational database that parses raw SMS data from XML files, processes transactions, and categorizes them for further analysis.  

The database supports:  
- Secure storage of transaction and user data  
- Categorization of financial transactions  
- System logging for transparency and auditing  
- JSON data modeling for API serialization  


Database Schema

 Tables
1. Users
   - Stores unique users identified by phone numbers  
   - Attributes: user_id, phone_number, name, created_at  

2. sms_Transactions
   - Stores raw SMS messages imported from XML  
   - Attributes: sms_id, protocol, address, date_attr, type_attr, contact_name, body  

3. Transactions
   - Stores parsed transaction details linked to SMS messages  
   - Attributes: transaction_id (PK), amount, transaction_date, category, raw_body, sms_id (FK)  

4. Categorized_Transactions
   - Copy of Transactions used for analytics and category-based queries  

5. System_Logs
   - Stores logs for system activities and imports  

how to test it 
1) import databaseusing MarisDB
   **mysql -u root -p**

2) Enter password (just press enter dont enter anything cause there is no password)
   
3) run: **show tables to see tables**



4)  run:  USE momo_db;
   **then run these remaining 4 to see the tdata**
SELECT COUNT(*) FROM sms_Transactions;
SELECT COUNT(*) FROM Transactions;
SELECT COUNT(*) FROM Users;
SELECT COUNT(*) FROM Categorized_Transactions;
SELECT COUNT(*) FROM System_Logs;












Team Members:
1. Peter Michael Angelo Rucakibungo
2. Esther Shimwa
3. Cassie Keza Kivuye 
4. Nformi girbong

Link to our scrum Board:
https://github.com/users/cassie-k01/projects/1/views/1

Link to our architectural diagram: https://drive.google.com/file/d/1WHxQuUXBqoq7RmPP3MfBzX6NskXR6vUH/view?usp=sharing


# 💸 MoMo SMS API

This is a simple REST API built in Python to manage mobile money SMS transactions.  
It reads transaction data from a JSON file and lets you view, add, update, and delete transactions using HTTP requests.

---

## 📁 What This Project Does

- Parses SMS messages about money transfers
- Saves them as JSON data
- Builds a Python API to access and manage them
- Protects the data with login (Basic Authentication)

---

##  How to Run It

### 🔧 1. Make sure you have Python installed

If you don’t have Python, download it here:  
 https://www.python.org/downloads/

###  2. Install dependencies

From the root folder of this project:

```bash
pip install -r requirements.txt
(If there’s no requirements.txt, the project uses only built-in Python libraries.)

 3. Run the server
bash
Copy code
cd api
python server.py
This will start the API at:
 http://localhost:8000

 Login Info (Authentication)
All endpoints are protected. You need to log in with:

Username: user

Password: momo123

If you try to use the API without logging in, it will say:

json
Copy code
{
  "error": "Unauthorized"
}
 API Endpoints
Method	URL	What It Does
GET	/transactions	Get all transactions
GET	/transactions/{id}	Get one transaction by ID
POST	/transactions	Add a new transaction
PUT	/transactions/{id}	Update a transaction
DELETE	/transactions/{id}	Delete a transaction

Example ID: T0001

 How to Test the API
You can use tools like curl or Postman.

 Example curl request:
bash
Copy code
curl -u user:momo123 http://localhost:8000/transactions
This gets the full list of transactions.

 Screenshots
All test screenshots are in the screenshots/ folder:

Test	Image File
GET all transactions	get_all_success.png
GET one transaction	get_single_success.png
POST new transaction	post_success.png
PUT update transaction	put_success.png
DELETE transaction	delete_success.png
Unauthorized login attempt	get_unauthorized.png

 Who Built What
Person	Task
NFORMI GIRBON	Parsed SMS data into JSON
Peter MICHEAL	Built the API with Python
Cassie Kivuye	Added login security + search code
Esther Shimwa	Wrote docs, tested everything, final report

 Project Structure
bash
Copy code
momo_dashboard/
├── api/              # API code (server.py)
├── data/             # transactions.json (SMS data)
├── dsa/              # Search methods (linear vs dict)
├── docs/             # api_docs.md + final_report.pdf
├── screenshots/      # Postman or curl test images
├── README.md         # This file
├── requirements.txt  # Python dependencies
 What We Learned
How to build an API using Python

How to protect it with Basic Authentication

How to test APIs with Postman and curl

How to make API docs that others can follow