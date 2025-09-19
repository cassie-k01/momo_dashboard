-- ===============================================
-- 1️Drop and create database so i will not neccessarily have to chooses the data base all the time as it will automatically do it
-- ===============================================
DROP DATABASE IF EXISTS momo_db;
CREATE DATABASE momo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE momo_db;

--create tables
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE sms_Transactions (
    sms_id INT AUTO_INCREMENT PRIMARY KEY,
    protocol VARCHAR(10),
    address VARCHAR(20),
    date_attr DATETIME,
    type_attr INT,
    contact_name VARCHAR(100),
    body TEXT NOT NULL
);


CREATE TABLE Transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE NULL,
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
    ) NOT NULL DEFAULT 'Unknown',
    raw_body TEXT NOT NULL,
    sms_id INT,
    CONSTRAINT fk_sms FOREIGN KEY (sms_id) REFERENCES sms_Transactions(sms_id)
);

CREATE INDEX idx_transactions_date ON Transactions(transaction_date);
CREATE INDEX idx_transactions_category ON Transactions(category);


CREATE TABLE Categorized_Transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE NULL,
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
    ) NOT NULL DEFAULT 'Unknown',
    raw_body TEXT NOT NULL,
    sms_id INT,
    CONSTRAINT fk_sms_cat FOREIGN KEY (sms_id) REFERENCES sms_Transactions(sms_id)
);


CREATE TABLE System_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(255),
    description TEXT
);

--load xml file ready to insert the datas into the sms_transactins table so it parses it to the other tables
LOAD XML LOCAL INFILE 'C:/Users/HP/Downloads/momo_dashboard-main/momo_dashboard-main/data/modified_sms_v2.xml'
INTO TABLE sms_Transactions
ROWS IDENTIFIED BY '<sms>'
(@protocol, @address, @date_attr, @type_attr, @contact_name, @body)
SET
protocol = @protocol,
address = @address,
date_attr = STR_TO_DATE(@date_attr, '%Y-%m-%d %H:%i:%s'),
type_attr = @type_attr,
contact_name = @contact_name,
body = @body;


INSERT INTO Transactions (transaction_id, amount, transaction_date, category, raw_body, sms_id)
SELECT
    NULLIF(
        TRIM(
            REPLACE(
                SUBSTRING(body,
                    CASE
                        WHEN LOCATE('TxId:', body) > 0 THEN LOCATE('TxId:', body) + 5
                        WHEN LOCATE('Financial Transaction Id:', body) > 0 THEN LOCATE('Financial Transaction Id:', body) + 24
                        ELSE 0
                    END,
                    50
                ),
                ' ', ''
            )
        ), ''
    ) AS transaction_id,
    CAST(
        REPLACE(
            REPLACE(
                SUBSTRING(body, 1, LOCATE('RWF', body)-1),
                ',', ''
            ),
            ' ', ''
        ) AS DECIMAL(15,2)
    ) AS amount,
    STR_TO_DATE(
        SUBSTRING(body, LOCATE('2025-', body), 19),
        '%Y-%m-%d %H:%i:%s'
    ) AS transaction_date,
    CASE
        WHEN body LIKE '%You have received%' THEN 'Incoming Money'
        WHEN LOWER(body) LIKE '%your payment of%' AND LOWER(body) LIKE '%to%' THEN 'Payment'
        WHEN LOWER(body) LIKE '%transferred to%' AND LOWER(body) LIKE '%from%' THEN 'Transfer to Mobile'
        WHEN LOWER(body) LIKE '%bank deposit%' THEN 'Bank Deposit'
        WHEN LOWER(body) LIKE '%cash power%' OR LOWER(body) LIKE '%token%' THEN 'Utility Payment'
        WHEN LOWER(body) LIKE '%withdrawn%' AND LOWER(body) LIKE '%via agent%' THEN 'Withdrawal'
        ELSE 'Unknown'
    END AS category,
    body AS raw_body,
    sms_id
FROM sms_Transactions;


INSERT INTO Categorized_Transactions (transaction_id, amount, transaction_date, category, raw_body, sms_id)
SELECT transaction_id, amount, transaction_date, category, raw_body, sms_id
FROM Transactions;


INSERT INTO System_Logs (action, description)
VALUES ('Import XML SMS', 'Imported all raw SMS and processed into Transactions and Categorized_Transactions');



