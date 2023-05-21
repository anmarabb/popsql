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
    FROM `floranow.erp_prod.budget` as b
)
SELECT 
    db.year_month,
    d AS date,  
    db.daily_budget,
    db.budget,
    max(db.budget) over
    db.financial_administration,
    db.account_manager,
    db.city,
    db.client_category,
    DATETIME_DIFF(DATE(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(d,MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY)),DATE_TRUNC(d,MONTH),DAY)+1 as days_total,
    DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(d,MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),d,DAY) as days_remaining,
    DATETIME_DIFF(d,DATE_TRUNC(d,MONTH),DAY) as days_passed

FROM daily_budget db
JOIN UNNEST(db.date_range) AS d