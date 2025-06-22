-- Client Engagement 
-- Quantify how quickly clients perform their initial recorded action after their registration date.

SELECT account_id, client_id, registration_date, md.first_event, md.first_event-registration_date as first_event_interval
FROM dim_accounts acc
INNER JOIN(
SELECT ft.dim_account_id, MIN(event_date) as first_event
FROM fact_transactions ft
INNER JOIN dim_dates dd
ON ft.dim_date_id = dd.dim_date_id	
GROUP BY dim_account_id) as md
ON acc.dim_account_id = md.dim_account_id
ORDER BY first_event_interval 
;

-- Overall Fund Movement
-- What is the total monetary value of funds that have flowed into client accounts 
-- and the total monetary value that has flowed out of client accounts across the entire dataset? (Positive & Negative amounts).

SELECT 
SUM(CASE WHEN ft.available_balance_delta > 0 THEN ft.available_balance_delta ELSE 0 END) AS positive_flows,
SUM(CASE WHEN ft.available_balance_delta < 0 THEN ft.available_balance_delta ELSE 0 END) AS negative_flows
FROM fact_transactions ft
;