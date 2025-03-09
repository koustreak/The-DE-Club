/*

Best Batsman – The player who scored the highest runs in the tournament.
Best Bowler – The bowler with the most wickets in the tournament.
Impact Player – The player with the highest Impact Score, calculated as:
Impact Score=(Runs Scored×2)+(Wickets Taken×20)+(Catches Taken×10)
Fastest Chase – The team that successfully chased a target in the fewest overs.
Biggest Chase – The highest target successfully chased in the tournament.
Top Bowler per Match – The best bowler in each match based on wickets taken.
Exceptional Batsman per Match – A player who scored more than twice the match’s average runs.

*/

CREATE TABLE match_details (
    match_id SERIAL PRIMARY KEY,
    team1 VARCHAR(50),
    team2 VARCHAR(50),
    venue VARCHAR(100),
    match_date DATE,
    target_runs INT,  
    chasing_team VARCHAR(50), 
    winning_team VARCHAR(50)
);

CREATE TABLE player_performance (
    match_id INT REFERENCES match_details(match_id),
    player_id INT,
    player_name VARCHAR(100),
    team VARCHAR(50),
    runs_scored INT DEFAULT 0,
    balls_faced INT DEFAULT 0,
    wickets_taken INT DEFAULT 0,
    overs_bowled DECIMAL(4,1) DEFAULT 0,
    runs_conceded INT DEFAULT 0,
    catches_taken INT DEFAULT 0
);

INSERT INTO match_details (match_id, team1, team2, venue, match_date, target_runs, chasing_team, winning_team) VALUES
(1, 'India', 'Australia', 'Mumbai', '2025-11-10', 320, 'India', 'India'),
(2, 'England', 'South Africa', 'Lords', '2025-11-11', 275, 'South Africa', 'South Africa'),
(3, 'New Zealand', 'England', 'Auckland', '2025-11-12', 340, 'New Zealand', 'New Zealand'),
(4, 'India', 'South Africa', 'Delhi', '2025-11-13', 290, 'India', 'India'),
(5, 'Australia', 'New Zealand', 'Melbourne', '2025-11-14', 315, 'New Zealand', 'New Zealand');

INSERT INTO player_performance (match_id, player_id, player_name, team, runs_scored, balls_faced, wickets_taken, overs_bowled, runs_conceded, catches_taken) VALUES
-- Match 1: India vs Australia
(1, 101, 'Virat Kohli', 'India', 140, 100, 0, 0, 0, 1),  -- Best Batsman
(1, 102, 'Shubman Gill', 'India', 85, 75, 0, 0, 0, 0),
(1, 103, 'Varun Chakravarthy', 'India', 15, 10, 4, 10, 30, 0),  -- Best Bowler
(1, 104, 'Adam Zampa', 'Australia', 35, 25, 3, 10, 42, 1), 
(1, 105, 'Steve Smith', 'Australia', 120, 95, 0, 0, 0, 0), -- Impact Player

-- Match 2: England vs South Africa
(2, 106, 'Joe Root', 'England', 100, 80, 0, 0, 0, 1),
(2, 107, 'Ben Duckett', 'England', 90, 70, 0, 0, 0, 1), -- Exceptional Batsman
(2, 108, 'Kagiso Rabada', 'South Africa', 10, 5, 3, 10, 32, 0), -- Top Bowler
(2, 109, 'David Miller', 'South Africa', 85, 65, 0, 0, 0, 0),

-- Match 3: New Zealand vs England (Fastest Chase)
(3, 110, 'Kane Williamson', 'New Zealand', 130, 85, 0, 0, 0, 1), -- Match-winning knock
(3, 111, 'Rachin Ravindra', 'New Zealand', 90, 60, 0, 0, 0, 0),
(3, 112, 'Phil Salt', 'England', 20, 15, 3, 10, 35, 0),
(3, 113, 'Matt Henry', 'New Zealand', 8, 5, 4, 10, 29, 0), -- Best Bowler

-- Match 4: India vs South Africa (Biggest Chase)
(4, 114, 'Rohit Sharma', 'India', 125, 90, 0, 0, 0, 1), -- Impact Player
(4, 115, 'Virat Kohli', 'India', 95, 75, 0, 0, 0, 0),
(4, 116, 'Marco Jansen', 'South Africa', 25, 20, 3, 10, 33, 0),
(4, 117, 'Varun Chakravarthy', 'India', 5, 4, 4, 10, 28, 0), -- Best Bowler

-- Match 5: Australia vs New Zealand
(5, 118, 'Marnus Labuschagne', 'Australia', 115, 88, 0, 0, 0, 1), -- Exceptional Batsman
(5, 119, 'Steve Smith', 'Australia', 80, 65, 0, 0, 0, 0),
(5, 120, 'Kagiso Rabada', 'New Zealand', 10, 8, 3, 10, 31, 0), -- Top Bowler
(5, 121, 'Glenn Phillips', 'New Zealand', 100, 78, 0, 0, 0, 0); -- Match Finisher



WITH MatchAverages AS (
    -- Calculate the average runs per match for exceptional batsman detection
    SELECT 
        match_id, 
        AVG(runs_scored) AS avg_match_runs 
    FROM player_performance 
    GROUP BY match_id
),
ImpactScores AS (
    -- Compute the impact score for each player
    SELECT 
        player_id, 
        player_name, 
        team,
        SUM(runs_scored * 2 + wickets_taken * 20 + catches_taken * 10) AS impact_score
    FROM player_performance
    GROUP BY player_id, player_name, team
),
BestBatsman AS (
    -- Find the player with the highest total runs
    SELECT player_id, player_name, team, SUM(runs_scored) AS total_runs
    FROM player_performance
    GROUP BY player_id, player_name, team
    ORDER BY total_runs DESC
    LIMIT 1
),
BestBowler AS (
    -- Find the player with the most wickets
    SELECT player_id, player_name, team, SUM(wickets_taken) AS total_wickets
    FROM player_performance
    GROUP BY player_id, player_name, team
    ORDER BY total_wickets DESC
    LIMIT 1
),
TopImpactPlayer AS (
    -- Find the player with the highest impact score
    SELECT player_id, player_name, team, impact_score
    FROM ImpactScores
    ORDER BY impact_score DESC
    LIMIT 1
),
FastestChase AS (
    -- Find the team that chased a target in the fewest overs
    SELECT md.match_id, md.chasing_team, MIN(bp.overs_bowled) AS overs_used
    FROM player_performance bp
    JOIN match_details md ON bp.match_id = md.match_id
    WHERE md.chasing_team = md.winning_team
    GROUP BY md.match_id, md.chasing_team
    ORDER BY overs_used ASC
    LIMIT 1
),
BiggestChase AS (
    -- Find the highest target successfully chased
    SELECT match_id, chasing_team, target_runs
    FROM match_details
    WHERE chasing_team = winning_team
    ORDER BY target_runs DESC
    LIMIT 1
),
TopBowlerPerMatch AS (
    -- Rank bowlers per match based on wickets taken
    SELECT match_id, player_id, player_name, team, wickets_taken,
           RANK() OVER (PARTITION BY match_id ORDER BY wickets_taken DESC) AS rank
    FROM player_performance
),
ExceptionalBatsman AS (
    -- Find batsmen who scored more than twice the match’s average runs
    SELECT p.match_id, p.player_id, p.player_name, p.team, p.runs_scored 
    FROM player_performance p
    JOIN MatchAverages ma ON p.match_id = ma.match_id
    WHERE p.runs_scored > 2 * ma.avg_match_runs
)
SELECT 'Best Batsman' AS category, player_id, player_name, team, total_runs AS stat_value 
FROM BestBatsman
UNION ALL
SELECT 'Best Bowler', player_id, player_name, team, total_wickets 
FROM BestBowler
UNION ALL
SELECT 'Impact Player', player_id, player_name, team, impact_score 
FROM TopImpactPlayer
UNION ALL
SELECT 'Fastest Chase', NULL, NULL, chasing_team, overs_used 
FROM FastestChase
UNION ALL
SELECT 'Biggest Chase', NULL, NULL, chasing_team, target_runs 
FROM BiggestChase
UNION ALL
SELECT 'Top Bowler Per Match', player_id, player_name, team, wickets_taken 
FROM TopBowlerPerMatch WHERE rank = 1
UNION ALL
SELECT 'Exceptional Batsman', player_id, player_name, team, runs_scored 
FROM ExceptionalBatsman;


SELECT
        player_id,
        player_name,
        team,
        NTILE(4) Over(ORDER BY
            (SUM(runs_scored) * 100.0 / SUM(balls_faced)) DESC) AS strike_rate
    FROM player_performance
    WHERE runs_scored>=100
    GROUP BY player_id, player_name, team