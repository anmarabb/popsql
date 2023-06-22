WITH user_monthly_activity AS (
SELECT DISTINCT
DATE_TRUNC(i.printed_at,month) as delivr_month,
i.customer_id ,
from `floranow.erp_prod.invoices` as i
left join `floranow.erp_prod.users` as u on i.customer_id = u.id

where u.financial_administration_id=2)

SELECT
previous.delivr_month,
  ROUND(COUNT(DISTINCT currentt.customer_id) /GREATEST(COUNT(DISTINCT previous.customer_id), 1),2) AS retention_rate
 
 

FROM user_monthly_activity AS previous
LEFT JOIN user_monthly_activity AS currentt ON previous.customer_id = currentt.customer_id
and date_diff(date(previous.delivr_month) ,date(currentt.delivr_month), MONTH) = 1 
GROUP BY previous.delivr_month
ORDER BY previous.delivr_month ASC;