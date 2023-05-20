--create or replace view `floranow.Floranow_ERP.invoices` as

with 
prep_manageable_accounts as (select manageable_id,account_manager_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User' ),
prep_country as (select distinct(country_iso_code),country_name from `floranow.erp_prod.country` )



select
i.total_amount - i.total_tax as total_amount_without_tax,
i.total_tax,
i.total_amount, --Invoice Total (Subtotal Amount + VAT)
i.currency,

i.paid_amount,
i.remaining_amount,

i.total_amount - i.paid_amount as pending_amount,


i.printed_at,


i.id ,
i.number as invoice_number,
concat(u.name,"-",u.debtor_number)  as Customer,
case
when u.customer_type = 0 then 'reseller'
when u.customer_type = 1 then 'retail'
when u.customer_type = 2 then 'fob'
when u.customer_type = 3 then 'cif'
else 'not-set'
end as customer_type,
uc.name as Customer_Category,
case
when u.financial_administration_id = 1 then 'KSA'
when u.financial_administration_id = 2 then 'UAE'
when u.financial_administration_id = 4 then 'kuwait'
when u.financial_administration_id = 5 then 'Qatar'
when u.financial_administration_id = 6 then 'Bulk'
when u.financial_administration_id = 7 then 'Internal'
else 'not-set'
end as financial_administration,
case
when u.payment_term_id = 12 then 'Without invoicing'
when u.payment_term_id = 4 then 'Cash on Delivery'
when u.payment_term_id = 6 then 'On the 25th of the next Month'
when u.payment_term_id = 7 then '7 Days After Delivery'
when u.payment_term_id = 2 then '10 Days After Delivery'
when u.payment_term_id = 2 then '14 Days After Delivery'
when u.payment_term_id = 10 then '15 Days After Delivery'
when u.payment_term_id = 5 then '30 Days After Delivery'
when u.payment_term_id = 9 then '45 Days After Delivery'
when u.payment_term_id = 10 then '60 Days After Delivery'
when u.payment_term_id = 3 then 'Pre Paid UAE'
when u.payment_term_id = 46 then 'Prepayment Bulk USD'
when u.payment_term_id = 47 then 'Prepayment Bulk EUR'
when u.payment_term_id = 48 then 'Due On the 7th of the Next Month'
else 'No_payment_term'
end as payment_term,

case
when i.payment_status = 0 then "Not_paid"
when i.payment_status = 1 then "Partially_paid"
when i.payment_status = 2 then "Totally_paid "
else "Null"
end as payment_status,

i.items_collection_method,

i.items_collection_date,
i.due_date,


case
when i.status = 0 then "Draft"
when i.status = 1 then "signed"
when i.status = 2 then "Open"
when i.status = 3 then "Printed"
when i.status = 6 then "Closed"
when i.status = 7 then "Canceled"
when i.status = 8 then "Rejected"
else "Null"
end as status,
i.generation_type,

case
--when i.invoice_type = 0 and i.total_amount = 0 then "zero-invoice"
when i.invoice_type = 0 then "invoice"
when i.invoice_type = 1 then "credit note"
else "Null"
end as invoice_type,

i.paid_by,
i.void_by,
i.deleted_by,
i.finalized_by,
u2.name as Created_by,
u3.name as Canceled_by,
i.cancellation_reason,
i.note,
u.debtor_number,


case
when i.source_type = 'EXTERNAL' then 'Florisoft'
when i.source_type = 'INTERNAL' then 'ERP'
else 'check_my_logic'
end as source_type,


u.country,
c.country_name,
u.city,
u4.name as account_manager,



case when i.items_collection_date > current_date() then "Future" else "Present" end as future_orders,


from `floranow.erp_prod.invoices` as i
left join `floranow.erp_prod.users` as u on i.customer_id = u.id
left join `floranow.erp_prod.users` as u2 on i.created_by = u2.id
left join `floranow.erp_prod.users` as u3 on i.customer_id = u3.id
left join `floranow.erp_prod.user_categories` as uc on u.user_category_id = uc.id
left join prep_manageable_accounts as ma on ma.manageable_id = u.id
left join `floranow.erp_prod.account_managers` as a on ma.account_manager_id = a.id
left join `floranow.erp_prod.users` as u4 on a.user_id = u4.id
left join prep_country as c on u.country = c.country_iso_code