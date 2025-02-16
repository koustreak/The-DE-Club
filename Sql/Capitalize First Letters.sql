/*
Convert the first letter of each word found in content_text to uppercase, 
while keeping the rest of the letters lowercase.

Your output should include the original text in one column 
and the modified text in another column.
*/

CREATE TABLE user_content (
    content_id BIGINT PRIMARY KEY,
    content_text TEXT,
    content_type TEXT,
    customer_id BIGINT
);

INSERT INTO user_content (content_id, content_text, content_type, customer_id) VALUES
(1, 'iNTroduction to PostgreSQL', 'Article', 101),
(2, 'UNDErsTANDING INDEXES', 'Article', 102),
(3, 'pOstgreSQL vs MySQL', 'Comparison', 103),
(4, 'DATABase OPTIMIZATION TIPS', 'Guide', 104),
(5, 'using JSON in PostgreSQL', 'Tutorial', 105),
(6, 'baCKUP AND RESTORE STRATEGIES', 'Guide', 106),
(7, 'UnderstandING Foreign Keys', 'Article', 107),
(8, 'POSTGRESQL PERFORMANCE TUNING', 'Tutorial', 108),
(9, 'Common Table Expressions', 'Guide', 109),
(10, 'THIs Is FiRST senTENce. THIs Is Second senTENce', 'Guide', 109),
(11, 'tHIS IS A simple book', 'Tutorial', 110);


-- using initcap 

select 
    content_id, 
    content_text as original_text,
    initcap(content_text) as modified_text
from user_content

-- without using initcap function 
WITH cte AS NOT MATERIALIZED (
    SELECT 
        content_id, 
        unnest(string_to_array(content_text, ' ')) AS word
    FROM user_content
)
SELECT 
    cte.content_id, 
    STRING_AGG(UPPER(LEFT(word, 1)) || LOWER(SUBSTRING(word FROM 2)), ' ') AS formatted_text,
    uc.content_text AS original_text
FROM cte 
LEFT JOIN user_content uc 
    ON cte.content_id = uc.content_id
GROUP BY cte.content_id, uc.content_text

-- Lowercase those word , which have 1 letter only 

WITH cte AS NOT MATERIALIZED (
    SELECT 
        content_id, 
        unnest(string_to_array(content_text, ' ')) AS word
    FROM user_content
)
SELECT
    cte.content_id,
    STRING_AGG(
        CASE 
            WHEN LENGTH(word) = 1 THEN LOWER(word)
            ELSE UPPER(LEFT(word, 1)) || LOWER(SUBSTRING(word FROM 2))
        END, ' '
    ) AS formatted_text,
    uc.content_text AS original_text
FROM cte
LEFT JOIN user_content uc
    ON cte.content_id = uc.content_id
GROUP BY cte.content_id, uc.content_text

-- Multiple Sentences in Same Row seperated by .

WITH cte AS NOT MATERIALIZED (
    select 
	    content_id, 
	    regexp_split_to_table(content_text, '(?<=[.!?])\s+') as sentence
    from
        user_content
)
SELECT 
    cte.content_id, 
    STRING_AGG(
        UPPER(LEFT(sentence, 1)) || LOWER(SUBSTRING(sentence FROM 2)), ' '
    ) AS formatted_text,
    uc.content_text 
FROM cte
LEFT JOIN user_content uc 
    ON cte.content_id = uc.content_id 
GROUP BY cte.content_id, uc.content_text;