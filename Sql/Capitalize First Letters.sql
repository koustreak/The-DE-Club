'''
Convert the first letter of each word found in content_text to uppercase, 
while keeping the rest of the letters lowercase.

Your output should include the original text in one column 
and the modified text in another column.
'''

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
(10, 'PL/pgSQL BASICS', 'Tutorial', 110);


-- using initcap 

select 
    content_id, 
    content_text as original_text,
    initcap(content_text) as modified_text
from user_content

-- without using initcap function 

SELECT 
    content_id, 
    STRING_AGG(UPPER(LEFT(word, 1)) || LOWER(SUBSTRING(word FROM 2)), ' ') AS formatted_text
FROM (
    SELECT 
        content_id, 
        unnest(string_to_array(content_text, ' ')) AS word
    FROM user_content
) sub
GROUP BY content_id;
