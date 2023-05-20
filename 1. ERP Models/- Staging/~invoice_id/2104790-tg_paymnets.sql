create or replace view `floranow.Floranow_ERP.stg_paymnets` as

select 
py.invoice_id,

sum(py.total_amount) as total_amount ,
sum(py.paid_amount) as paid_amount,
sum(py.credit_note_amount) as credit_note_amount_used,


from `floranow.erp_prod.payments` as py

group by invoice_id