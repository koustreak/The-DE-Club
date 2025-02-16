/*
A movie theater gave you two tables: seats that are available for an upcoming screening and neighboring seats for each seat listed. 
You are asked to find all pairs of seats that are both adjacent and available.
Output only distinct pairs of seats in two columns such that the seat with the lower number is always in the 
first column and the one with the higher number is in the second column.
*/

CREATE TABLE theater_availability (
    seat_number BIGINT PRIMARY KEY,
    is_available BOOLEAN
);

CREATE TABLE theater_seatmap (
    seat_number BIGINT PRIMARY KEY,
    seat_left BIGINT NULL,  -- Left neighboring seat (NULL means no left neighbor)
    seat_right BIGINT NULL  -- Right neighboring seat (NULL means no right neighbor)
);

-- Insert availability data
INSERT INTO theater_availability (seat_number, is_available) VALUES
(1, TRUE),
(2, TRUE),
(3, FALSE),
(4, TRUE),
(5, TRUE),
(6, TRUE),
(7, FALSE),
(8, TRUE),
(9, TRUE),
(10, TRUE),
(11, FALSE),
(12, TRUE),
(13, TRUE),
(14, TRUE),
(15, FALSE),
(16, TRUE),
(17, TRUE),
(18, FALSE),
(19, TRUE),
(20, TRUE);

-- Insert seat adjacency data with more NULL values
INSERT INTO theater_seatmap (seat_number, seat_left, seat_right) VALUES
(1, NULL, 2),
(2, 1, NULL),    -- No right neighbor
(3, NULL, 4),    -- No left neighbor
(4, 3, 5),
(5, 4, NULL),    -- No right neighbor
(6, NULL, 7),    -- No left neighbor
(7, 6, NULL),    -- No right neighbor
(8, NULL, 9),
(9, 8, 10),
(10, 9, NULL),   -- No right neighbor
(11, NULL, 12),  -- No left neighbor
(12, 11, 13),
(13, 12, 14),
(14, 13, NULL),  -- No right neighbor
(15, NULL, 16),  -- No left neighbor
(16, 15, 17),
(17, 16, 18),
(18, 17, NULL),  -- No right neighbor
(19, NULL, 20),  -- No left neighbor
(20, 19, NULL);  -- No right neighbor


SELECT DISTINCT 
    t1.seat_number AS seat1, 
    t2.seat_number AS seat2
FROM theater_availability t1
JOIN theater_seatmap ts ON t1.seat_number = ts.seat_number
JOIN theater_availability t2 ON t2.is_available = TRUE
WHERE t1.is_available = TRUE 
AND (t2.seat_number = ts.seat_left OR t2.seat_number = ts.seat_right)
AND t1.seat_number < t2.seat_number;

/*

How This Works Step-by-Step
First JOIN (theater_availability t1 + theater_seatmap ts)

Connects available seats (t1) to their adjacency info (ts).
Second JOIN (theater_availability t2)

Ensures the adjacent seat (t2) is also available.
WHERE Conditions

t1.is_available = TRUE → Ensures the first seat is available.
t2.is_available = TRUE → Ensures the second seat is available.
(t2.seat_number = ts.seat_left OR t2.seat_number = ts.seat_right) → Ensures t2 is an adjacent seat.
t1.seat_number < t2.seat_number → Ensures we don’t duplicate pairs (e.g., (1,2) instead of both (1,2) and (2,1)).

*/


