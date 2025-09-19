<<<<<<< HEAD




CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL COMMENT 'Full name',
  phone_number VARCHAR(20) NOT NULL UNIQUE COMMENT 'E.164 phone number',
  email VARCHAR(100) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_phone (phone_number)
) ENGINE=InnoDB;


CREATE TABLE transaction_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  UNIQUE KEY uq_category_name (category_name)
) ENGINE=InnoDB;


CREATE TABLE transactions (
  transaction_id INT AUTO_INCREMENT PRIMARY KEY,
  external_ref VARCHAR(100) DEFAULT NULL COMMENT 'External reference / SMS id',
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  category_id INT NOT NULL,
  amount DECIMAL(14,2) NOT NULL COMMENT 'Transaction amount',
  currency VARCHAR(5) NOT NULL DEFAULT 'USD',
  transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending','Success','Failed','Reversed') NOT NULL DEFAULT 'Pending',
  message TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  -- Foreign keys
  CONSTRAINT fk_tx_sender FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tx_receiver FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tx_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_transactions_sender (sender_id),
  INDEX idx_transactions_receiver (receiver_id),
  INDEX idx_transactions_category (category_id),
  INDEX idx_transactions_date (transaction_date)
) ENGINE=InnoDB;
CREATE TABLE sms_transactions (
    sms_id INT AUTO_INCREMENT PRIMARY KEY,      
    sender VARCHAR(50) NOT NULL,               
    receiver VARCHAR(50) NOT NULL,              
    amount DECIMAL(10,2) DEFAULT 0.00,          
    currency VARCHAR(10) DEFAULT 'XAF',         
    transaction_type VARCHAR(50),               
    transaction_date DATETIME,                  
    raw_message TEXT NOT NULL,                 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE system_logs (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT NOT NULL,
  processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(50),
  notes TEXT,
  CONSTRAINT fk_log_tx FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_logs_tx (transaction_id),
  INDEX idx_logs_status (status)
) ENGINE=InnoDB;


CREATE TABLE audit_events (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(64) NOT NULL,
  record_id INT NOT NULL,
  operation VARCHAR(20) NOT NULL,
  changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(100),
  details JSON
) ENGINE=InnoDB;



-- Table to store raw SMS transactions
CREATE TABLE IF NOT EXISTS sms_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender VARCHAR(50),
    receiver VARCHAR(50),
    amount DECIMAL(10,2),
    currency VARCHAR(10),
    transaction_type VARCHAR(50),
    transaction_date DATETIME,
    raw_message TEXT
);

CREATE TABLE categorized_transactions (
    categorized_id INT AUTO_INCREMENT PRIMARY KEY,
    sms_id INT NOT NULL,              
    transaction_id INT NULL,          
    category_id INT NOT NULL,         
    confidence DECIMAL(5,2) DEFAULT 1.00 COMMENT 'Confidence score for classification',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cat_sms
        FOREIGN KEY (sms_id) REFERENCES sms_transactions(sms_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_cat_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT fk_cat_category
        FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);



--testing only
-- 1. Transactions with sender & receiver names
SELECT t.transaction_id, t.external_ref, s.name AS sender, r.name AS receiver,
       tc.category_name, t.amount, t.currency, t.status, t.transaction_date
FROM transactions t
JOIN users s ON t.sender_id = s.user_id
JOIN users r ON t.receiver_id = r.user_id
JOIN transaction_categories tc ON t.category_id = tc.category_id
ORDER BY t.transaction_date DESC;

-- 2. Logs per transaction
SELECT l.log_id, l.transaction_id, l.status AS log_status, l.notes, l.processed_at
FROM system_logs l
ORDER BY l.processed_at DESC;
=======
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
>>>>>>> a5e39eb01ef6c4dab16fc7e94926a6c5372380b2
