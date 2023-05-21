WITH daily_budget AS (
    SELECT 
        b.financial_administration,
        b.account_manager,
        b.city,
        b.date,
        b.client_category,
        FORMAT_TIMESTAMP('%Y-%m', b.date) as year_month,
        b.budget,
        b.budget / CAST(DATETIME_DIFF(DATETIME_ADD(DATETIME_TRUNC(b.date, MONTH), INTERVAL 1 MONTH), DATETIME_TRUNC(b.date, MONTH), DAY) AS FLOAT64) AS daily_budget,

        GENERATE_DATE_ARRAY(DATE(DATETIME_TRUNC(b.date, MONTH)), DATE(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(b.date, MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY))) AS date_range


    FROM `floranow.erp_prod.budget` as b
)
SELECT 
    db.year_month,
    d AS date,  
    db.daily_budget,
    db.financial_administration,
    db.account_manager,
    db.city,
    db.client_category,
FROM daily_budget db
JOIN UNNEST(db.date_range) AS d