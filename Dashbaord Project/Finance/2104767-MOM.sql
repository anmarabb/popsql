create or replace table `floranow.Floranow_ERP.monthly_views` as

WITH preb_budget AS (
    SELECT
        bud.financial_administration,
        EXTRACT(year FROM bud.date) AS year,
        EXTRACT(month FROM bud.date) AS month,
        SUM(bud.budget) AS budget
    FROM `floranow.erp_prod.budget` as bud
    GROUP BY 1,2,3
),
raw_data AS (
    SELECT
        stg_users.financial_administration,
        stg_users.client_category,
        DATE_TRUNC(i.printed_at,month) AS month_of_year,
        EXTRACT(year FROM i.printed_at) AS year,
        EXTRACT(month FROM i.printed_at) AS month,

        COUNT(DISTINCT stg_users.debtor_number) AS clients,
        SAFE_DIVIDE(COUNT(DISTINCT CONCAT(stg_users.debtor_number,i.printed_at)),COUNT(DISTINCT stg_users.debtor_number)) AS frequency,
        SAFE_DIVIDE(SUM(ii.price_without_tax),COUNT(DISTINCT CONCAT(stg_users.debtor_number,i.printed_at))) AS basket_size,
        COUNT(DISTINCT CONCAT(stg_users.debtor_number,i.printed_at)) AS deliveries,
        COUNT(ii.id) AS items,
        SUM(ii.quantity) AS quantity,
        SUM(ii.price_without_tax) AS monthly_revenue,
        SUM(CASE WHEN i.invoice_type = 1 THEN ii.price_without_tax ELSE 0 END) AS credit_note,
        SUM(CASE WHEN i.invoice_type = 0 THEN ii.price_without_tax ELSE 0 END) AS invoiced_revenue,
        ROUND(SAFE_DIVIDE(SUM(CASE WHEN i.invoice_type = 1 THEN ii.price_without_tax ELSE 0 END), SUM(CASE WHEN i.invoice_type = 0 THEN ii.price_without_tax ELSE 0 END)),4) AS creditNote_perc,
        MAX(budget.budget) AS budget,
        SAFE_DIVIDE(SUM (CASE WHEN ( i.printed_at IS NOT NULL AND i.generation_type !='AUTO' AND i.source_type = 'INTERNAL' AND li.order_type IS NULL) OR (i.printed_at IS NOT NULL AND i.source_type = 'INTERNAL' AND li.order_type NOT IN ('ONLINE') ) THEN ii.price_without_tax ELSE 0 END) , SUM( CASE WHEN i.source_type = 'INTERNAL' AND i.printed_at IS NOT NULL THEN ii.price_without_tax ELSE 0 END)) AS offline_perc
    FROM `floranow.erp_prod.invoice_items` as ii 
    LEFT JOIN `floranow.Floranow_ERP.users` as stg_users ON stg_users.id = ii.customer_id
    LEFT JOIN `floranow.erp_prod.line_items` as li ON ii.line_item_id = li.id
    LEFT JOIN `floranow.erp_prod.invoices` as i ON ii.invoice_id = i.id
    LEFT JOIN preb_budget as budget ON budget.month = EXTRACT(month FROM i.printed_at) AND budget.year = EXTRACT(year FROM i.printed_at) AND budget.financial_administration = stg_users.financial_administration
    WHERE ii.status = 'APPROVED' AND ii.deleted_at IS NULL
    GROUP BY 1,2,3,4,5
)
SELECT 
    raw_data.*,
    COALESCE(((monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY financial_administration, client_category ORDER BY year, month)) / NULLIF(LAG(monthly_revenue) OVER (PARTITION BY financial_administration, client_category ORDER BY year, month), 0)) * 100, 0) AS mom_growth,
    COALESCE(((monthly_revenue - LAG(monthly_revenue, 12) OVER (PARTITION BY financial_administration, client_category ORDER BY year, month)) / NULLIF(LAG(monthly_revenue, 12) OVER (PARTITION BY financial_administration, client_category ORDER BY year, month), 0)) * 100, 0) AS yoy_growth
FROM raw_data
ORDER BY financial_administration DESC, client_category DESC, year DESC, month DESC;