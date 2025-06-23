CREATE MATERIALIZED VIEW mv_daily_balances AS

-- Optional: initial balances per client (can be 0 or another table)
WITH initial_balances AS (
  SELECT dim_account_id, 0::NUMERIC AS initial_balance
  FROM (SELECT DISTINCT dim_account_id FROM fact_transactions) ft
),

-- Generate all dates per client
date_series AS (
  SELECT
    ft.dim_account_id,
    generate_series(MIN(DATE(dd.event_date)), MAX(DATE(dd.event_date)), INTERVAL '1 day')::date AS balance_date
  FROM fact_transactions ft
  INNER JOIN dim_dates dd
  	ON ft.dim_date_id = dd.dim_date_id
  GROUP BY ft.dim_account_id
),

-- Aggregate daily transactions
daily_transactions AS (
  SELECT
    dim_account_id,
    DATE(dd.event_date) as event_date,
    SUM(ft.available_balance_delta) AS balance_delta
  FROM fact_transactions ft
  INNER JOIN dim_dates dd
  	ON ft.dim_date_id = dd.dim_date_id
  GROUP BY dim_account_id, DATE(dd.event_date)
),

-- Join with date series and fill missing dates with 0 transaction
combined AS (
  SELECT
    ds.dim_account_id,
    ds.balance_date,
    COALESCE(dt.balance_delta, 0) AS balance_delta
  FROM date_series ds
  LEFT JOIN daily_transactions dt
    ON ds.dim_account_id = dt.dim_account_id AND ds.balance_date = dt.event_date
),

-- Compute running total for closing balance
running_balance AS (
  SELECT
    c.dim_account_id,
    c.balance_date,
    c.balance_delta,
    ib.initial_balance +
      SUM(c.balance_delta) OVER (
        PARTITION BY c.dim_account_id
        ORDER BY c.balance_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
      ) AS closing_balance
  FROM combined c
  JOIN initial_balances ib ON c.dim_account_id = ib.dim_account_id
),

-- Compute starting balance by subtracting today's delta
final_daily_balance AS (
  SELECT
    dim_account_id,
    balance_date,
    closing_balance - balance_delta AS starting_balance,
    balance_delta,
    closing_balance
  FROM running_balance
)

-- Final result
SELECT *
FROM final_daily_balance
ORDER BY dim_account_id, balance_date;