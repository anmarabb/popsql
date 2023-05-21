create or replace view `floranow.Floranow_ERP.budget` as

WITH daily_budget AS (
    SELECT 
        b.financial_administration,
        b.account_manager,
        b.city,
        b.date,
        b.client_category,
        PARSE_DATE('%Y-%m-%d', CONCAT(FORMAT_TIMESTAMP('%Y-%m', b.date), '-01')) as year_month,
        b.budget,
        b.budget / CAST(DATETIME_DIFF(DATETIME_ADD(DATETIME_TRUNC(b.date, MONTH), INTERVAL 1 MONTH), DATETIME_TRUNC(b.date, MONTH), DAY) AS FLOAT64) AS daily_budget,

        GENERATE_DATE_ARRAY(DATE(DATETIME_TRUNC(b.date, MONTH)), DATE(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(b.date, MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY))) AS date_range
DATETIME_DIFF(date(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY)),DATE_TRUNC( current_date(),month),DAY)+1 as days_total_current_month,
DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),CURRENT_DATE(),DAY) as days_remaining_current_month,
DATETIME_DIFF(CURRENT_DATE(),DATE_TRUNC( current_date(),month),day) as days_left_current_month,  --days_passed_current_month


    FROM `floranow.erp_prod.budget` as b
)
SELECT 
    db.year_month,
    d AS date,  
    db.daily_budget, -- daily_budget
    db.budget,
    db.financial_administration,
    db.account_manager,
    db.city,
    db.client_category,
    days_total_current_month,
    days_remaining_current_month,

FROM daily_budget db
JOIN UNNEST(db.date_range) AS d