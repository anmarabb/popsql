create or replace view `floranow.Floranow_ERP.invoices` as
with 
prep_registered_clients as (select financial_administration,count(*) as registered_clients from `floranow.Floranow_ERP.users` where account_type in ('External') group by financial_administration)   



SELECT

case 
    when i.currency in ('SAR') then (i.total_amount - i.total_tax) * 0.26666667
    when i.currency in ('AED') then (i.total_amount - i.total_tax) * 0.27229408
    when i.currency in ('KWD') then (i.total_amount - i.total_tax) * 3.256648 
    when i.currency in ('USD') then (i.total_amount - i.total_tax)
    when i.currency in ('EUR') then (i.total_amount - i.total_tax) * 1.0500713
    when i.currency in ('QAR', 'QR') then (i.total_amount - i.total_tax) * 0.27472527
    when i.currency is null then (i.total_amount - i.total_tax) * 0.27229408
end as usd_price_without_tax,


concat( "https://erp.floranow.com/invoices/", i.id) as invoice_link,

case when date(i.printed_at) is not null then 'Printed' when i.deleted_at is not null then 'deleted_invoice' else 'Not-Printed' end as is_printed,

sum(case when date(i.printed_at) is not null then i.remaining_amount else 0 end) over() as total_outstanding_balance,
sum(i.remaining_amount) over() as total_outstanding_with_proforma,


date(i.deleted_at) as deleted_at,


-- date

--date(i.meta_data.printed_at) as meta_printed_at,
--date(i.meta_data.delivery_date) as meta_delivery_date,
--date(i.meta_data.invoice_date) as meta_invoice_date,
--date(i.meta_data.created_at) as meta_created_at,

i.due_date,
i.items_collection_date,
i.created_at,
date(i.printed_at) as printed_at,

i.updated_at,





concat(stg_users.debtor_number,date(i.printed_at)) as drop_id, 



i.number as invoice_number,


i.id,

i.total_amount - i.total_tax as total_amount_without_tax,
i.total_tax,
i.total_amount, --Invoice Total (Subtotal Amount + VAT)
i.currency,
i.paid_amount,
i.remaining_amount, --i.total_amount - i.paid_amount as pending_amount,



i.items_collection_method,

i.generation_type,
i.cancellation_reason,
i.note,



case
when i.payment_status = 0 then "Not paid"
when i.payment_status = 1 then "Partially paid"
when i.payment_status = 2 then "Totally paid "
else "check_my_logic"
end as payment_status,


case
when i.status = 0 then "Draft"
when i.status = 1 then "signed"
when i.status = 2 then "Open"
when i.status = 3 then "Printed"
when i.status = 6 then "Closed"
when i.status = 7 then "Canceled"
when i.status = 8 then "Rejected"
when i.status = 9 then "voided"

else "check_my_logic"
end as status,

case
--when i.invoice_type = 0 and i.total_amount = 0 then "zero-invoice"
when i.invoice_type = 0 then "invoice"
when i.invoice_type = 1 then "credit note"
else "Null"
end as invoice_type,

case
when i.source_type = 'EXTERNAL' then 'Florisoft'
when i.source_type = 'INTERNAL' then 'ERP'
else 'check_my_logic'
end as source_type,

case when date(i.items_collection_date) > current_date() then "Future" else "Present" end as future_orders,


round(SAFE_DIVIDE(stg_paymnets.credit_note_amount_used, i.total_amount),2) creditNote_perc,

case when i.invoice_type = 1 then (i.total_amount - i.total_tax) else 0 end as credit_note_total,
case when i.invoice_type != 1 then (i.total_amount - i.total_tax) else 0 end as invoice_revenue,


--stg_users
    stg_users.city,
    stg_users.email,
    stg_users.customer,
    stg_users.client_category,
    stg_users.customer_type,
    stg_users.payment_term,
    stg_users.account_manager,
    stg_users.country,
    --stg_users.financial_administration,
    stg_users.reseller,
    stg_users.debtor_number,
    stg_users.last_drop_date,
    stg_users.days_since_last_drop,
    stg_users.id as user_id,
    stg_users.master_account,

--stg_invoice_items
    stg_invoice_items.items_count,
    stg_invoice_items.otd_check ,
    stg_invoice_items.price_without_tax as ii_price_without_tax ,
    stg_invoice_items.express_revenue ,
    stg_invoice_items.manual_revenue ,
    stg_invoice_items.NonExpress_revenue ,
    stg_invoice_items.total_cost,
    stg_invoice_items.profit,
    stg_invoice_items.quantity,
    stg_invoice_items.delivery_date,
    

    
case --financial ID
        when i.financial_administration_id = 1 then 'KSA'
        when i.financial_administration_id = 2 then 'UAE'
        when i.financial_administration_id = 3 then 'Jordan'
        when i.financial_administration_id = 4 then 'kuwait'
        when i.financial_administration_id = 5 then 'Qatar'
        when i.financial_administration_id = 6 then 'Bulk'
        when i.financial_administration_id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,

prep_registered_clients.registered_clients,
i.total_amount - i.total_tax = stg_invoice_items.price_without_tax as match_check,

stg_users.company_name,
stg_users.warehouses,
case when stg_users.email  like '%fake.com%' then 'fake.com' else 'normal' end as fake_email,


from `floranow.erp_prod.invoices` as i
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = i.customer_id
left join prep_registered_clients as prep_registered_clients on prep_registered_clients.financial_administration = stg_users.financial_administration

left join `floranow.Floranow_ERP.stg_paymnets` as stg_paymnets on stg_paymnets.invoice_id = i.id
left join `floranow.Floranow_ERP.stg_invoice_items` as stg_invoice_items on stg_invoice_items.invoice_id = i.id;



select count(*) from `floranow.erp_prod.invoices` as i;