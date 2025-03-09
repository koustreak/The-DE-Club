/*
Problem Statement
A bank wants to detect fraudulent transactions based on these patterns:

Rapid consecutive transactions – If a customer makes multiple transactions within 1 minute totaling more than $10,000.
Self-loop transactions – If a customer sends money to themselves.
Transactions exceeding 10× the customer's average transaction amount for that day.
Your task is to write an SQL query that detects suspicious transactions using window functions with RANGE-based time intervals.
*/

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    transaction_type VARCHAR(10) CHECK (transaction_type IN ('debit', 'credit')),
    merchant_id INT,
    transaction_timestamp TIMESTAMP
);


INSERT INTO transactions (customer_id, amount, transaction_type, merchant_id, transaction_timestamp) VALUES
-- Normal transactions
(101, 200, 'debit', 201, '2025-03-08 09:00:00'),
(101, 300, 'debit', 202, '2025-03-08 09:30:00'),
(102, 500, 'debit', 203, '2025-03-08 10:00:00'),

-- Rapid transactions (Fraud: More than $10,000 in 1 min)
(103, 6000, 'debit', 204, '2025-03-08 11:59:00'),
(103, 5000, 'debit', 205, '2025-03-08 11:59:30'),

-- More rapid transactions (Fraud)
(104, 4000, 'debit', 206, '2025-03-08 12:00:00'),
(104, 7000, 'debit', 207, '2025-03-08 12:00:45'),

-- Rapid transactions (Not Fraud: Less than $10,000 in 1 min)
(103, 4500, 'debit', 204, '2025-03-08 12:48:00'),
(103, 5000, 'debit', 205, '2025-03-08 12:48:30'),

-- Self-loop transactions (Fraud)
(105, 8000, 'debit', 105, '2025-03-08 13:00:00'),
(105, 8000, 'credit', 105, '2025-03-08 13:00:10'),

-- Exceeding 10x daily avg (Fraud)
(106, 100, 'debit', 208, '2025-03-08 14:00:00'),
(106, 150, 'debit', 209, '2025-03-08 14:15:00'),
(106, 120000, 'debit', 210, '2025-03-08 14:30:00'),  -- 10x daily avg fraud

-- More Exceeding 10x daily avg (Fraud)
(107, 500, 'debit', 211, '2025-03-08 15:00:00'),
(107, 400, 'debit', 212, '2025-03-08 15:20:00'),
(107, 6000, 'debit', 213, '2025-03-08 15:40:00');  -- 10x daily avg fraud



WITH RapidTransactions AS (
    SELECT customer_id, transaction_id, amount, transaction_timestamp
    FROM (
        SELECT 
            customer_id, 
            transaction_id, 
            amount, 
            transaction_timestamp, 
            SUM(amount) OVER (
                PARTITION BY customer_id 
                ORDER BY transaction_timestamp 
                RANGE BETWEEN INTERVAL '1 minute' PRECEDING AND CURRENT ROW
            ) AS rolling_sum
        FROM transactions
    ) t
    WHERE rolling_sum > 10000
),
SelfLoopTransactions AS (
    SELECT customer_id, transaction_id, amount, transaction_timestamp
    FROM transactions
    WHERE customer_id = merchant_id
),
CustomerDailyAvg AS (
    SELECT 
        customer_id,
        DATE(transaction_timestamp) AS transaction_date,
        AVG(amount) AS avg_amount
    FROM transactions
    GROUP BY customer_id, DATE(transaction_timestamp)
),
ExceedingTransactions AS (
    SELECT t.transaction_id, t.customer_id, t.amount, t.transaction_timestamp
    FROM transactions t
    JOIN CustomerDailyAvg cda 
        ON t.customer_id = cda.customer_id 
        AND DATE(t.transaction_timestamp) = cda.transaction_date
    WHERE t.amount > 10 * cda.avg_amount
)
SELECT 'Rapid Transaction' AS fraud_type, * FROM RapidTransactions
UNION ALL
SELECT 'Self Loop Transaction' AS fraud_type, * FROM SelfLoopTransactions
UNION ALL
SELECT 'Exceeding 10x Customer Daily Avg' AS fraud_type, * FROM ExceedingTransactions;


---------------

WITH RapidTransactions AS (
    SELECT t1.customer_id, t1.transaction_id, t1.amount, t1.transaction_timestamp
    FROM transactions t1
    JOIN transactions t2 
        ON t1.customer_id = t2.customer_id 
        AND t1.transaction_id != t2.transaction_id 
        AND ABS(EXTRACT(EPOCH FROM (t1.transaction_timestamp - t2.transaction_timestamp))) <= 60
    GROUP BY t1.customer_id, t1.transaction_id, t1.amount, t1.transaction_timestamp
    HAVING SUM(t1.amount) + SUM(t2.amount) > 10000
),
SelfLoopTransactions AS (
    SELECT customer_id, transaction_id, amount, transaction_timestamp
    FROM transactions
    WHERE customer_id = merchant_id
),
CustomerDailyAvg AS (
    SELECT 
        customer_id,
        DATE(transaction_timestamp) AS transaction_date,
        AVG(amount) AS avg_amount
    FROM transactions
    GROUP BY customer_id, DATE(transaction_timestamp)
),
ExceedingTransactions AS (
    SELECT t.transaction_id, t.customer_id, t.amount, t.transaction_timestamp
    FROM transactions t
    JOIN CustomerDailyAvg cda 
        ON t.customer_id = cda.customer_id 
        AND DATE(t.transaction_timestamp) = cda.transaction_date
    WHERE t.amount > 10 * cda.avg_amount
)
SELECT 'Rapid Transaction' AS fraud_type, * FROM RapidTransactions
UNION ALL
SELECT 'Self Loop Transaction' AS fraud_type, * FROM SelfLoopTransactions
UNION ALL
SELECT 'Exceeding 10x Customer Daily Avg' AS fraud_type, * FROM ExceedingTransactions;
