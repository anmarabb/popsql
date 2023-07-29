WITH 
date_spine AS (
  SELECT
    date_in_range,
    day_number,
    week_number,
    min(date_in_range) over (partition by week_number) week_start,
    max(date_in_range) over (partition by week_number) week_end
  FROM (
    SELECT 
      date_in_range,
      date_diff(date_in_range, cast('2019-07-01' as date), DAY)+1 as day_number,
      cast(trunc(date_diff(date_in_range, cast('2019-07-01' as date), DAY)/7)+1 as int64) as week_number
    FROM UNNEST(
      GENERATE_DATE_ARRAY(DATE('2019-07-01'), CURRENT_DATE(), INTERVAL 1 DAY)
    ) AS date_in_range
  )
),
transactions AS (
  SELECT 
    'user_' || CAST(FLOOR(RAND() * 100) AS STRING) AS user_id,
    CURRENT_DATE() - INTERVAL CAST(FLOOR(RAND() * 500) AS INT64) DAY AS date,
    'site_' || CAST(FLOOR(RAND() * 5) AS STRING) AS site,
    CAST(FLOOR(RAND() * 10) AS INT64) AS transactions_created
  FROM 
    UNNEST(GENERATE_ARRAY(1, 10000)) AS id
),
transaction_summary AS (
  SELECT
    user_id,
    week_start,
    week_end,
    week_number,
    sum(CASE WHEN date >= week_start AND date <= week_end THEN transactions_created ELSE 0 END) as transactions_created
  FROM date_spine
  JOIN transactions
  ON date_spine.date_in_range = transactions.date
  GROUP BY user_id, week_start, week_end, week_number
),
transaction_weekly_summary AS (
  SELECT
    user_id,
    week_start,
    week_end,
    week_number,
    transactions_created,
    sum(transactions_created) over weekly as transactions_created_lifetime,
    lag(transactions_created) over weekly as transactions_created_prev
  FROM transaction_summary
  WINDOW weekly as (PARTITION BY user_id ORDER BY week_start asc)
)
SELECT
  user_id,
  week_start,
  week_end,
  week_number,
  CASE WHEN transactions_created = transactions_created_lifetime and transactions_created > 0 THEN 1 ELSE 0 END as new_flag,
  CASE WHEN transactions_created_prev > 0 AND transactions_created = 0 THEN 1 ELSE 0 END as churns_flag,
  CASE WHEN transactions_created > 0 AND transactions_created_prev = 0 and transactions_created != transactions_created_lifetime THEN 1 ELSE 0 END as reactivations_flag,
  CASE WHEN transactions_created > 0 AND transactions_created_prev > 0 THEN 1 ELSE 0 END as retentions_flag
FROM transaction_weekly_summary;