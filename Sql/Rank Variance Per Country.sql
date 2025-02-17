/*
Which countries have risen in the rankings based on the number of comments between Dec 2019 vs Jan 2020? 
Hint: Avoid gaps between ranks when ranking countries.
*/

-- Create user_lists table
CREATE TABLE user_lists (
    user_id BIGINT PRIMARY KEY,
    name TEXT,
    country TEXT,
    status TEXT CHECK (status IN ('active', 'inactive'))
);

-- Create comment_counts table
CREATE TABLE comment_counts (
    comment_id SERIAL PRIMARY KEY,
    created_at DATE,
    number_of_comments BIGINT,
    user_id BIGINT REFERENCES user_lists(user_id)
);

-- Insert users (Mix of active & inactive users from various countries)
INSERT INTO user_lists (user_id, name, country, status) VALUES
(1, 'Alice', 'USA', 'active'),
(2, 'Bob', 'Canada', 'active'),
(3, 'Charlie', 'China', 'inactive'),
(4, 'David', 'Brazil', 'active'),
(5, 'Eve', 'Mali', 'active'),
(6, 'Frank', 'Australia', 'inactive'),
(7, 'Grace', 'Germany', 'active'),
(8, 'Hank', 'France', 'inactive'),
(9, 'Ivy', 'Luxembourg', 'active'),
(10, 'Jack', 'India', 'inactive'),
(11, 'Lily', 'Japan', 'active'),
(12, 'Mike', 'UK', 'active'),
(13, 'Nina', 'South Africa', 'inactive'),
(14, 'Oscar', 'Russia', 'active'),
(15, 'Paul', 'Mexico', 'inactive');


-- Inactive users (Comments before Dec 2019 + Some in Dec & Jan)
INSERT INTO comment_counts (created_at, number_of_comments, user_id) VALUES
('2019-10-10', 10, 3), -- China (Inactive, before Dec)
('2019-11-05', 20, 6), -- Australia (Inactive, before Dec)
('2019-11-15', 25, 8), -- France (Inactive, before Dec)
('2019-12-05', 18, 10), -- India (Inactive, Dec)
('2019-12-20', 22, 13), -- South Africa (Inactive, Dec)
('2020-01-10', 30, 15), -- Mexico (Inactive, Jan)
('2020-01-25', 35, 3), -- China (Inactive, Jan)
('2020-01-30', 40, 6), -- Australia (Inactive, Jan)

-- Active users (Oct, Nov, Dec 2019)
('2019-10-15', 30, 1), -- USA
('2019-11-10', 35, 2), -- Canada
('2019-11-25', 40, 4), -- Brazil
('2019-12-05', 50, 5), -- Mali
('2019-12-15', 60, 7), -- Germany
('2019-12-20', 45, 9), -- Luxembourg
('2019-12-25', 38, 11), -- Japan
('2019-12-30', 42, 12), -- UK

-- Active users (Jan & Feb 2020)
('2020-01-05', 55, 1), -- USA
('2020-01-10', 60, 2), -- Canada
('2020-01-15', 65, 4), -- Brazil
('2020-01-20', 70, 5), -- Mali
('2020-01-25', 50, 7), -- Germany
('2020-02-05', 45, 9), -- Luxembourg
('2020-02-10', 50, 11), -- Japan
('2020-02-15', 55, 12), -- UK
('2020-02-20', 60, 14); -- Russia

-- Inactive users (Comments before Dec 2019 + Added some in Dec 2019 & Jan 2020)
INSERT INTO comment_counts (created_at, number_of_comments, user_id) VALUES
('2019-10-10', 10, 3),  -- China (Inactive, before Dec)
('2019-11-05', 20, 6),  -- Australia (Inactive, before Dec)
('2019-11-15', 25, 8),  -- France (Inactive, before Dec)

-- Inactive users now have comments in Dec 2019
('2019-12-05', 18, 10),  -- India (Inactive, Dec)
('2019-12-10', 22, 3),   -- China (Inactive, Dec)
('2019-12-15', 30, 8),   -- France (Inactive, Dec)
('2019-12-20', 35, 13),  -- South Africa (Inactive, Dec)
('2019-12-25', 40, 15),  -- Mexico (Inactive, Dec)

-- Inactive users now have comments in Jan 2020
('2020-01-05', 20, 6),   -- Australia (Inactive, Jan)
('2020-01-10', 25, 3),   -- China (Inactive, Jan)
('2020-01-15', 30, 8),   -- France (Inactive, Jan)
('2020-01-20', 35, 13),  -- South Africa (Inactive, Jan)
('2020-01-25', 40, 15);  -- Mexico (Inactive, Jan)

-- 
WITH comments_per_country AS (
    -- Aggregate total comments per country per month
    SELECT 
        f.country, 
        DATE_TRUNC('month', b.created_at) AS comment_month, 
        SUM(b.number_of_comments) AS total_comments
    FROM fb_comments_count b
    JOIN fb_active_users f ON b.user_id = f.user_id
    WHERE b.created_at BETWEEN '2019-12-01' AND '2020-01-31'
    GROUP BY f.country, DATE_TRUNC('month', b.created_at)
),
ranked_comments AS (
    -- Rank countries per month using DENSE_RANK()
    SELECT 
        country, 
        comment_month, 
        total_comments,
        DENSE_RANK() OVER (PARTITION BY comment_month ORDER BY total_comments DESC) AS rank
    FROM comments_per_country
),
rank_changes AS (
    -- Get all countries from both months
    SELECT 
        COALESCE(d.country, j.country) AS country, 
        d.rank AS dec_rank, 
        j.rank AS jan_rank
    FROM 
        (SELECT country, rank FROM ranked_comments WHERE comment_month = '2019-12-01') d
    FULL OUTER JOIN 
        (SELECT country, rank FROM ranked_comments WHERE comment_month = '2020-01-01') j
    ON d.country = j.country
)
-- Show "NA" for missing ranks
SELECT 
    country, 
    COALESCE(CAST(dec_rank AS TEXT), 'NA') AS dec_rank, 
    COALESCE(CAST(jan_rank AS TEXT), 'NA') AS jan_rank
FROM rank_changes
WHERE dec_rank IS NOT NULL AND jan_rank IS NOT NULL  -- Ignore cases where a country newly appeared
AND jan_rank < dec_rank  -- Rank improved (lower rank number means higher rank)
ORDER BY dec_rank - jan_rank DESC;  -- Sort by the most improved rank
