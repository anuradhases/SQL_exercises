
-- ********************** -- 
-- Done in PostgreSQL

-- MEDIUM
-- Facebook: Share of Active Users:
-- check that there is no duplicates in user id & remove duplicates if so
SELECT user_id, COUNT(*)
FROM fb_active_users
WHERE country = 'USA'
GROUP BY user_id
ORDER BY COUNT (*) DESC
-- no duplicate user_id

--Denominator: total count of users in USA
SELECT COUNT(user_id) as total_users
FROM fb_active_users
WHERE country = 'USA';

--Numerator: count of status = 'open' users in USA
SELECT COUNT(user_id) as active_users
FROM fb_active_users
WHERE country = 'USA'
AND status = 'open';

-- Ratio
SELECT COUNT(CASE WHEN status = 'open' THEN user_id ELSE NULL END):: FLOAT/ COUNT(user_id)
FROM fb_active_users
WHERE country = 'USA';


-- ********************** -- 
-- MEDIUM
-- Deloitte: Election Results
-- Winning candidate: Christine

WITH votes_by_voter AS
(SELECT voter, candidate, 1.00/ COUNT(candidate) OVER (PARTITION BY voter) as number_of_votes
FROM voting_results
WHERE candidate IS NOT NULL),
candidates_ranked_by_votes AS (
SELECT candidate, ROUND(SUM(number_of_votes),3) AS total_votes,
DENSE_RANK() OVER (ORDER BY ROUND(SUM(number_of_votes),3) DESC) rn
FROM votes_by_voter
GROUP BY candidate)
SELECT candidate
FROM candidates_ranked_by_votes
WHERE rn = 1;


-- ********************** -- 
-- MEDIUM:
-- Google/Netflix: Flags per Video
SELECT video_id, COUNT(DISTINCT(CONCAT(user_firstname, user_lastname)))
FROM user_flags
WHERE flag_id IS NOT NULL
GROUP BY video_id;

-- ********************** -- 
-- MEDIUM:
-- Google: User with Most Approved Flags

WITH user_and_flag_id AS(
    SELECT CONCAT(user_firstname, ' ', user_lastname) as full_name,
    DENSE_RANK () OVER(ORDER BY COUNT(DISTINCT(video_id)) DESC) rank
    FROM user_flags
    JOIN flag_review ON
    user_flags.flag_id = flag_review.flag_id
    WHERE reviewed_outcome = 'APPROVED'
    GROUP BY full_name
)
SELECT full_name
FROM user_and_flag_id
WHERE rank = 1;

-- ********************** -- 
-- MEDIUM:
-- Google: Find students with a median writing score
SELECT student_id
FROM sat_scores
WHERE sat_writing = (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sat_writing) FROM sat_scores);

-- ********************** -- 
-- MEDIUM:
-- Spotify: Find the top 10 ranked songs in 2010
SELECT DISTINCT(song_name), group_name, year_rank
FROM billboard_top_100_year_end
WHERE year = 2010
ORDER BY year_rank
LIMIT 10;

-- ********************** -- 
-- MEDIUM
-- City of SF: Classify Business Type
SELECT DISTINCT business_name, 
CASE 
    WHEN LOWER(business_name) LIKE '%restaurant%' THEN 'Restaurant'
    WHEN LOWER(business_name) LIKE '%cafe%' 
    OR LOWER(business_name) LIKE '%café%' 
    OR LOWER(business_name) LIKE '%coffee%' THEN 'cafe'
    WHEN LOWER(business_name) LIKE '%school%' THEN 'school'
    ELSE 'other'
    END AS classification
FROM sf_restaurant_health_violations;

-- ********************** --
-- MEDIUM
-- Meta: Find rate of processed tickets for each type

SELECT complaint_id, type, COUNT(complaint_id)
FROM facebook_complaints
GROUP BY type, complaint_id
HAVING (COUNT(complaint_id) >1);

SELECT type, COUNT(CASE WHEN processed = TRUE THEN processed ELSE NULL END):: FLOAT / 
COUNT(processed) as rate_of_processed_tickets
FROM facebook_complaints
GROUP BY type;

-- ********************** --
-- MEDIUM:
-- Amazon: Customer Revenue in March
WITH customers_in_mar_2019 AS 
(SELECT cust_id, total_order_cost
FROM orders
WHERE EXTRACT(MONTH FROM order_date) = 03
AND EXTRACT (YEAR FROM order_date) = 2019)
SELECT DISTINCT(cust_id), SUM(total_order_cost) as revenue
FROM customers_in_mar_2019
GROUP BY DISTINCT(cust_id)
ORDER BY revenue DESC; 

-- ********************** --
-- MEDIUM:
-- Google: Find number of times each word appears in drafts
SELECT word, nentry
FROM ts_stat('SELECT to_tsvector(contents) FROM google_file_store WHERE filename LIKE ''draft%'' ');