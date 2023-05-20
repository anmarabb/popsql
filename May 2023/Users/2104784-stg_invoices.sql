create or replace view `floranow.Floranow_ERP.stg_invoices` as

SELECT
max(i.financial_administration_id) as invoice_financial_administration_id ,

sum(case when i.printed_at is not null then i.remaining_amount else 0 end) as total_outstanding_balance, --total_remaining_amount
count(case when i.payment_status != 2  and i.printed_at is not null then 1 else null end) as outstanding_count,

sum(case when i.created_at is not null and  i.printed_at is null then i.remaining_amount else 0 end) as proforma_amount,
count(case when i.created_at is not null and  i.printed_at is null then i.remaining_amount else null end) as proforma_count,


sum(i.remaining_amount) as total_outstanding_with_proforma, 



sum(case when i.invoice_type=1 and i.status in (1, 3) then i.remaining_amount else 0 end) as credit_note_balance, --total_unused_credit_note


sum(case when i.printed_at is not null then i.total_amount else 0 end) as total_lifetime_value , --client_ltv Total Net Printed Invoice
sum(case when i.printed_at is not null then i.paid_amount else 0 end) as total_lifetime_value_collectd , 



sum(case when i.printed_at is not null then i.remaining_amount else 0 end) + sum(case when i.printed_at is not null then i.paid_amount else 0 end) = sum(case when i.printed_at is not null then i.total_amount else 0 end) as logic_qa_1,



--total_outstanding_with_proforma
-- proforma amount 

sum(case when i.created_at is not null then i.remaining_amount else 0 end) - sum(case when i.invoice_type=1 then i.remaining_amount else 0 end) as credit_balance,



customer_id,
--round(sum(i.total_amount),0) as client_ltv,
-- SUM(i.remaining_amount) AS total_remaining_amount,



--prep ageing reports models.
    sum(case when date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) <= 30 then i.remaining_amount else 0 end) as up_to_30_days,
    sum(case when date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) > 30 and date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) <= 60 then i.remaining_amount else 0 end) as between_31_to_60_days,
    sum(case when date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) > 60 and date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) <= 90 then i.remaining_amount else 0 end) as between_61_to_90_days,
    sum(case when date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) > 90 and date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) <= 120 then i.remaining_amount else 0 end) as between_91_to_120_days,
    sum(case when date_diff( cast(current_date() as date ),cast(i.printed_at as date), DAY) > 120 then i.remaining_amount else 0 end) as more_than_120_days,

sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 then i.remaining_amount else 0 end) as m_1_remaining,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 2 then i.remaining_amount else 0 end) as m_2_remaining,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 3 then i.remaining_amount else 0 end) as m_3_remaining,
sum (case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 then i.remaining_amount else 0 end) as MTD_remaining,



    round(SAFE_DIVIDE(sum(i.remaining_amount), sum(sum(i.total_amount)) over (partition by i.customer_id)*0.01),2) as collection_rate, 





count(i.id) as total_drops,
sum(case when i.invoice_type=1 then 1 else 0 end )as total_failed_drops,
1-round(sum(case when i.invoice_type=1 then 1 else 0 end)/count(i.id) ,2) as success_rate, 

sum (case when date_diff(cast(i.printed_at as date), cast(current_date() as date ), MONTH) = 0 then (case when i.invoice_type=1 then 1 else 0 end ) else 0 end) as MTD_failed_drops,
sum (case when date_diff(cast(i.printed_at as date), cast(current_date() as date ), Year) = 0 then (case when i.invoice_type=1 then 1 else 0 end ) else 0 end) as YTD_failed_drops,




case when sum(i.total_amount)!=0 then abs(round(SAFE_DIVIDE(sum(case when i.invoice_type=1 then i.total_amount else 0 end), sum(sum(case when i.invoice_type=0 then i.total_amount else 0 end)) over (partition by i.customer_id)*0.01) ,2)) else null end as creditNote_perc,

--do we need status??


/*
  sum(i.paid_amount) as total_paid_amount,

  sum(case when i.invoice_type=0 then i.total_amount else 0 end) as total_invoices,
  sum(case when i.invoice_type=1 then i.total_amount else 0 end) as total_credit_note,

  sum(case when i.invoice_type=1 then i.paid_amount else 0 end) as total_used_credit_note,

  sum(case when i.invoice_type=0 then i.paid_amount else 0 end) as total_paid_invoices,
  sum(case when i.invoice_type=0 then i.remaining_amount else 0 end) as total_pending_invoices,
*/




min(i.printed_at) as first_order_date,
MAX(i.printed_at) AS last_drop_date,



date_diff(cast(current_date() as date), cast(Min(i.printed_at) as date ), MONTH) as total_month,

date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH) as total_active_months,
 --need to make if in the month 1 order count this month, if not 0, --active month, sleep month, count of active month

round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) as avg_monthly_value,

case 
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >= 49999 then "1- Clients who pay +50K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >=25000 then "2- Clients who pay +24K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >=12000 then "3- Clients who pay +12K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >=6000 then "4- Clients who pay +6K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >=3000 then "5- Clients who pay +3K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) >=1000 then "6- Clients who pay +1K per month"
when round(SAFE_DIVIDE(sum(i.total_amount), date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH)),0) <1000 then "7- Clients who pay less than 999 per month"

when date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH) = 0 then 'One order clinets'
when date_diff(cast(Max(i.printed_at) as date), cast(Min(i.printed_at) as date ), MONTH) is null then 'Zero order clinets'

else 'One order clinets'

end as client_value_segments,



DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) AS days_since_last_drop,


FROM
  `floranow.erp_prod.invoices` AS i

GROUP BY
  customer_id