DROP DATABASE IF EXISTS momo_db;
CREATE DATABASE momo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE momo_db;

--create the tables and you can create all other tables in tehhe same format
CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL COMMENT 'User phone number',
    name VARCHAR(100) COMMENT 'User name',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS sms_Transactions (
    sms_id INT AUTO_INCREMENT PRIMARY KEY,
    protocol VARCHAR(10),
    address VARCHAR(20),
    date_attr DATETIME,
    type_attr VARCHAR(5),
    contact_name VARCHAR(100),
    body TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

--creates the transaction table
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id VARCHAR(50) PRIMARY KEY COMMENT 'Unique Transaction ID',
    amount DECIMAL(15,2) NOT NULL CHECK (amount >= 0),
    transaction_date DATETIME,
    category ENUM(
        'Incoming Money',
        'Payment',
        'Transfer to Mobile',
        'Bank Deposit',
        'Utility Payment',
        'Withdrawal',
        'Unknown'
    ) DEFAULT 'Unknown',
    raw_body TEXT,
    sms_id INT,
    CONSTRAINT fk_sms FOREIGN KEY (sms_id) REFERENCES sms_Transactions(sms_id)
);


CREATE TABLE IF NOT EXISTS Categorized_Transactions LIKE Transactions;


CREATE TABLE IF NOT EXISTS System_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    message TEXT
);


-- Loads the XML into sms_Transactions
LOAD XML LOCAL INFILE 'C:/Users/HP/Downloads/momo_dashboard-main/momo_dashboard-main/data/modified_sms_v2.xml'
INTO TABLE sms_Transactions
ROWS IDENTIFIED BY '<sms>';

-- Populates the Users from  unique phone numbers
INSERT IGNORE INTO Users (phone_number, name)
SELECT DISTINCT address, contact_name
FROM sms_Transactions
WHERE address IS NOT NULL AND TRIM(address) <> '';

-- Populates the  Transactions table safely (fixed)
INSERT INTO Transactions (transaction_id, amount, transaction_date, category, raw_body, sms_id)
SELECT
  --this is going to Generate the unique transaction_id so we dont run into primary key errors
  CASE
    WHEN body LIKE '%TxId%' AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(body, 'TxId:', -1), ' ', 1)) <> '' 
      THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(body, 'TxId:', -1), ' ', 1))
    WHEN body LIKE '%Financial Transaction Id%' AND TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(body, 'Financial Transaction Id:', -1), ' ', 1)) <> ''
      THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(body, 'Financial Transaction Id:', -1), ' ', 1))
    ELSE CONCAT('AUTO-', sms_id)  -- fallback ensures uniqueness
  END AS transaction_id,

  --does  Amount parsing
  CAST(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(body, 'RWF', 1), ' ', -1), ',', ''), ' ', '') AS DECIMAL(15,2)) AS amount,

  -- does the ransaction date parsing
  STR_TO_DATE(SUBSTRING(body, LOCATE('2025-', body), 19), '%Y-%m-%d %H:%i:%s') AS transaction_date,

  -- does the Category parsing
  (CASE
     WHEN body LIKE '%You have received%' THEN 'Incoming Money'
     WHEN LOWER(body) LIKE '%your payment of%' AND LOWER(body) LIKE '%to%' THEN 'Payment'
     WHEN LOWER(body) LIKE '%transferred to%' AND LOWER(body) LIKE '%from%' THEN 'Transfer to Mobile'
     WHEN LOWER(body) LIKE '%bank deposit%' THEN 'Bank Deposit'
     WHEN LOWER(body) LIKE '%cash power%' OR LOWER(body) LIKE '%token%' THEN 'Utility Payment'
     WHEN LOWER(body) LIKE '%withdrawn%' AND LOWER(body) LIKE '%via agent%' THEN 'Withdrawal'
     ELSE 'Unknown'
   END) AS category,

  body AS raw_body,
  sms_id
FROM sms_Transactions
WHERE TRIM(body) <> '';

--copies the transactions into categorized transactions
INSERT INTO Categorized_Transactions SELECT * FROM Transactions;

-- Log system import

INSERT INTO System_Logs(message) VALUES('XML import and transaction processing completed.');
