--create or replace view `floranow.Floranow_ERP.new_budget` as

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
        GENERATE_DATE_ARRAY(DATE(DATETIME_TRUNC(b.date, MONTH)), DATE(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(b.date, MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY))) AS date_range,

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

    CASE
        WHEN ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC(date, MONTH),financial_administration,account_manager,city) = 1 THEN 
            SUM(db.daily_budget) OVER (PARTITION BY DATE_TRUNC(date, MONTH),financial_administration,account_manager,city)
        ELSE 
            NULL 
    END AS monthly_budget,


    CASE
        WHEN ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC(date, MONTH),financial_administration) = 1 THEN 
            max(DATETIME_DIFF(date(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(date,MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY)),DATE_TRUNC( date,month),DAY)+1) OVER (PARTITION BY DATE_TRUNC(date, MONTH),financial_administration)
        ELSE 
            NULL 
    END AS days_total,





CASE
    WHEN ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC(d, DAY)) = 1 THEN
        CASE WHEN DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(d,MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),d,DAY) >=0 
            THEN DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(d,MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),d,DAY) 
            ELSE 0 
        END
    ELSE 0 
END AS days_remaining,

    DATETIME_DIFF(d,DATE_TRUNC(d,MONTH),DAY)+1 as days_passed,
    
FROM daily_budget db
JOIN UNNEST(db.date_range) AS d

where financial_administration = 'UAE' and year_month = '2023-05-01'