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
