/*
Given the users\' sessions logs on a particular day, calculate how many hours each user was active that day.

Note: The session starts when state=1 and ends when state=0.
*/

drop table user_sessions;

CREATE TABLE user_sessions (
    cust_id TEXT NOT NULL,
    state INT NOT NULL CHECK (state IN (0,1)), -- 1: Session Start, 0: Session End
    session_time TIMESTAMP NOT NULL
);

INSERT INTO user_sessions (cust_id, state, session_time) VALUES
-- Customer 001 (Two different days)
('c001', 1, '2024-11-26 07:00:00'),
('c001', 0, '2024-11-26 09:30:00'),
('c001', 1, '2024-11-26 12:00:00'),
('c001', 0, '2024-11-26 14:30:00'),
('c001', 1, '2024-11-27 08:30:00'),
('c001', 0, '2024-11-27 10:00:00'),
-- Customer 002 (Three different days)
('c002', 1, '2024-11-26 08:00:00'),
('c002', 0, '2024-11-26 09:30:00'),
('c002', 1, '2024-11-26 11:00:00'),
('c002', 0, '2024-11-26 12:30:00'),
('c002', 1, '2024-11-27 10:00:00'),
('c002', 0, '2024-11-27 11:30:00'),
('c002', 1, '2024-11-28 09:00:00'),
('c002', 0, '2024-11-28 10:15:00'),
-- Customer 003 (One day)
('c003', 1, '2024-11-26 09:00:00'),
('c003', 0, '2024-11-26 10:30:00'),
-- Customer 004 (Two different days)
('c004', 1, '2024-11-26 10:00:00'),
('c004', 0, '2024-11-26 10:30:00'),
('c004', 1, '2024-11-27 14:00:00'),
('c004', 0, '2024-11-27 15:30:00'),
-- Customer 005 (Two different days)
('c005', 1, '2024-11-26 10:00:00'),
('c005', 0, '2024-11-26 14:30:00'),
('c005', 1, '2024-11-27 15:30:00'),
('c005', 0, '2024-11-27 18:30:00');



WITH session_pairs AS (
    SELECT 
        cust_id,
        DATE(session_time) AS session_date,
        session_time AS start_time,
        LEAD(session_time) OVER (PARTITION BY cust_id, DATE(session_time) ORDER BY session_time) AS end_time,
        state
    FROM user_sessions
)
SELECT 
    cust_id, 
    session_date, 
    ROUND(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600), 2) AS total_active_hours
FROM session_pairs
WHERE state = 1  -- Only consider session start times
GROUP BY cust_id, session_date
ORDER BY cust_id, session_date;


