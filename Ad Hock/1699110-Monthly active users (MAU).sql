---Monthly active users (MAU)
select
DATE_TRUNC(i.printed_at,month) as delivr_month,
COUNT(DISTINCT i.customer_id) AS mau,

from `floranow.erp_prod.invoices` as i
    left join `floranow.erp_prod.users` as u on i.customer_id = u.id

where u.financial_administration_id=2
GROUP BY delivr_month
ORDER BY delivr_month