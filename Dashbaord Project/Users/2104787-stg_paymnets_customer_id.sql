create or replace view `floranow.Floranow_ERP.stg_paymnets_customer_id` as

SELECT

i.customer_id,

sum(py.total_amount) as total_amount ,
sum(py.paid_amount) as paid_amount,
sum(py.credit_note_amount) as credit_note_amount_used,

sum (case when date_diff(cast(py.created_at as date), cast(current_date() as date ), MONTH) = 0 then py.paid_amount else 0 end) as MTD_paymnets,
sum (case when date_diff(cast(current_date() as date ),cast(py.created_at as date), MONTH) = 1 and extract(day FROM cast(py.created_at as date)) <= extract(day FROM cast(current_date() as date)) then py.paid_amount else 0 end) as LMTD_paymnets,
sum (case when date_diff(cast(current_date() as date ),cast(py.created_at as date), MONTH) = 1 then py.paid_amount else 0 end) as m_1_paymnets, --last_month_total
sum (case when date_diff(cast(current_date() as date ),cast(py.created_at as date), MONTH) = 2 then py.paid_amount else 0 end) as m_2_paymnets,
sum (case when date_diff(cast(current_date() as date ),cast(py.created_at as date), MONTH) = 3 then py.paid_amount else 0 end) as m_3_paymnets,


FROM
  `floranow.erp_prod.payments` AS py
  left join `floranow.erp_prod.invoices` as i on py.invoice_id = i.id

GROUP BY
  i.customer_id