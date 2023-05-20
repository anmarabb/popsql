create or replace view `floranow.Floranow_ERP.stg_orders` as

SELECT
customer_id,
MAX(li.created_at) AS last_order_date,
max(case when li.supplier_id IN (109,71) then li.created_at  end) as last_express_order_date,


DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) AS days_since_last_order,


sum (case when date_diff(cast(li.created_at as date), cast(current_date() as date ), MONTH) = 0 then total_price_without_tax else 0 end) as MTD_order_value,
sum (case when date_diff(cast(current_date() as date ),cast(li.created_at as date), MONTH) = 1 and extract(day FROM cast(li.created_at as date)) <= extract(day FROM cast(current_date() as date)) then total_price_without_tax else 0 end) as LMTD_order_value,
sum (case when date_diff(cast(current_date() as date ),cast(li.created_at as date), MONTH) = 1 then total_price_without_tax else 0 end) as m_1, --last_month_total
sum (case when date_diff(cast(current_date() as date ),cast(li.created_at as date), MONTH) = 2 then total_price_without_tax else 0 end) as m_2,
sum (case when date_diff(cast(current_date() as date ),cast(li.created_at as date), MONTH) = 3 then total_price_without_tax else 0 end) as m_3,


case 
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 7 then 'active'
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) > 7 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 30 then 'inactive'
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) > 30 then 'churned'
    else 'churned'
    end as Account_Status,

--case when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 7 then li.customer_id else null end as churned_customers,







case 
    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <3 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 7 then 'new_active'  
    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <3 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) is not null then 'new_inactive'  

    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <3 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) is null then'new_not_activated_yet'   
    else 'old_client'
    end as acquisition_status,


  FROM
    `floranow.erp_prod.line_items` AS li
    left join `floranow.erp_prod.users` as u on li.customer_id = u.id


  GROUP BY
    customer_id