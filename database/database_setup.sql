
DROP DATABASE IF EXISTS momo_db;
CREATE DATABASE momo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE momo_db;

-- ------------------------------------------------
-- Users table
-- ------------------------------------------------
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL COMMENT 'Full name',
  phone_number VARCHAR(20) NOT NULL UNIQUE COMMENT 'E.164 phone number',
  email VARCHAR(100) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_phone (phone_number)
) ENGINE=InnoDB;

-- ------------------------------------------------
-- Transaction Categories
-- ------------------------------------------------
CREATE TABLE transaction_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  UNIQUE KEY uq_category_name (category_name)
) ENGINE=InnoDB;

-- ------------------------------------------------
-- Transactions
-- ------------------------------------------------
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

-- ------------------------------------------------
-- System Logs
-- ------------------------------------------------
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

-- ------------------------------------------------
-- Optional: audit table for deletes/edits (good for traceability)
-- ------------------------------------------------
CREATE TABLE audit_events (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(64) NOT NULL,
  record_id INT NOT NULL,
  operation VARCHAR(20) NOT NULL,
  changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(100),
  details JSON
) ENGINE=InnoDB;

-- Create momo_sms_db if it doesn’t exist
CREATE DATABASE IF NOT EXISTS momo_sms_db;
USE momo_sms_db;

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

-- Table to store categorized transactions
CREATE TABLE IF NOT EXISTS categorized_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sms_id INT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sms_id) REFERENCES sms_transactions(id)
);

-- Users (for login/dashboard later)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------
-- Sample Data: Users (5)
-- ------------------------------------------------
INSERT INTO users (name, phone_number, email) VALUES
('Alice', '+237612345678', 'alice@example.com'),
('Bob', '+237699876543', 'bob@example.com'),
('Charlie', '+237650987654', 'charlie@example.com'),
('Diana', '+237699123456', 'diana@example.com'),
('Eve', '+237677654321', 'eve@example.com');

-- ------------------------------------------------
-- Sample Data: Categories (5)
-- ------------------------------------------------
INSERT INTO transaction_categories (category_name, description) VALUES
('Transfer', 'Transfer between accounts'),
('Payment', 'Payment for goods or services'),
('Airtime', 'Mobile airtime top-up'),
('Donation', 'Charitable donation'),
('Utility', 'Bills / Utilities');

-- ------------------------------------------------
-- Sample Data: Transactions (5)
-- Note: make sure sender_id/receiver_id refer to the users inserted above
-- ------------------------------------------------
INSERT INTO transactions (external_ref, sender_id, receiver_id, category_id, amount, currency, transaction_date, status, message) VALUES
('SMS-0001', 1, 2, 1, 150.00, 'USD', '2025-09-17 10:00:00', 'Success', 'Payment for service A'),
('SMS-0002', 2, 3, 2, 75.50, 'USD', '2025-09-17 11:15:00', 'Success', 'Groceries'),
('SMS-0003', 3, 4, 3, 20.00, 'USD', '2025-09-17 12:30:00', 'Success', 'Airtime recharge'),
('SMS-0004', 4, 5, 4, 120.75, 'USD', '2025-09-17 13:45:00', 'Pending', 'Electricity bill'),
('SMS-0005', 5, 1, 5, 50.00, 'USD', '2025-09-17 14:00:00', 'Failed', 'Donation');

-- ------------------------------------------------
-- Sample Data: System Logs (5)
-- ------------------------------------------------
INSERT INTO system_logs (transaction_id, status, notes) VALUES
(1, 'Processed', 'Transaction completed successfully'),
(2, 'Processed', 'Payment verified and completed'),
(3, 'Processed', 'Airtime recharge successful'),
(4, 'Pending', 'Awaiting provider confirmation'),
(5, 'Failed', 'Insufficient funds');

-- ------------------------------------------------
-- Helpful sample queries for testing
-- ------------------------------------------------
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
