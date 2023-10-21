
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
