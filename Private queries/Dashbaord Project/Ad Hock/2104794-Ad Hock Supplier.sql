SELECT
supplier_id,
max(stg_suppliers.supplier_name),
DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) AS days_since_last_order,


sum (case when date_diff(cast(li.delivery_date as date), cast(current_date() as date ), MONTH) = 0 then li.quantity*li.unit_fob_price else 0 end) as MTD_order_value,
sum (case when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 1 and extract(day FROM cast(li.delivery_date as date)) <= extract(day FROM cast(current_date() as date)) then li.quantity*li.unit_fob_price else 0 end) as LMTD_order_value,
sum (case when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 1 then li.quantity*li.unit_fob_price else 0 end) as m_1, --last_month_total
sum (case when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 2 then li.quantity*li.unit_fob_price else 0 end) as m_2,
sum (case when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 3 then li.quantity*li.unit_fob_price else 0 end) as m_3,







FROM `floranow.erp_prod.line_items` AS li
left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = li.supplier_id

  GROUP BY
    supplier_id