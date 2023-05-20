--create or replace view `floranow.Floranow_ERP.payments` as 

select 
py.created_at as payment_date,
py.paid_amount,



pt.created_by,
pt.payment_method,

ba.name as bank_name,

i.number as invoice_number,
i2.number as Credit_note ,
concat( "https://erp.floranow.com/payment_transactions/", py.payment_transaction_id) as Payment_transaction,


py.total_amount,

py.credit_note_amount,
py.updated_at,
py.id,
py.invoice_id,
py.credit_note_id,
py.payment_type, ----over_payed, credit, write_off, cheque, payment_by_credit, bank_transfer, visa_card, cash, null
py.currency,
py.added_by,
py.approved_by,
pt.collected_by,
pt.number,
pt.approval_code,


py.payment_transaction_id,
py.deleted_at,
py.netsuite_ref_id,
py.netsuite_failure_reason,



stg_users.city,
stg_users.customer,
stg_users.client_category,
stg_users.customer_type,
stg_users.payment_term,
stg_users.account_manager,
stg_users.country,
stg_users.company_name,
--stg_users.financial_administration,
stg_users.debtor_number,
i.printed_at,

pt.payment_received_at,



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


--case when invoice_id is null then documentable_id else invoice_id as new_invoice_id,


from `floranow.erp_prod.payments` as py
left join `floranow.erp_prod.invoices` as i on py.invoice_id = i.id
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = i.customer_id


--left join `floranow.erp_prod.move_items` as mi on mi.id = py.debit_move_item_id 
--left join `floranow.erp_prod.invoices` as i3 on i3.id = mi.documentable_id and documentable_type = 'Invoice'



left join `floranow.erp_prod.payment_transactions` as pt on py.payment_transaction_id = pt.id

left join `floranow.erp_prod.invoices` as i2 on py.credit_note_id = i2.id
left join `floranow.erp_prod.bank_accounts` as ba on stg_users.bank_account_id = ba.id



--where i.number = 'F10122712'