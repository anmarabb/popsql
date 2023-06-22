create or replace view `floranow.Floranow_ERP.Payments_transactions` as 


select 

pt.id, 
pt.number, 
pt.status,

pt.invoice_numbers,
pt.paid_amount,
pt.credit_note_amount,
pt.total_amount,
pt.currency,
pt.transaction_type, -- EXTERNAL, MANUAL, ONLINE
pt.payment_method,
pt.collected,
pt.trx_reference,
pt.payment_gateway,
pt.approved,

concat("invoice_number : ",pt.response.invoice_number,'\n' , "payment_method : ",pt.response.payment_method , '\n' , "invoice_date : ",pt.response.invoice_date ,'\n',"note : ",pt.response.note , '\n' , "debtor_number : " , pt.response.debtor_number , '\n' , "User_id : " , pt.response.user_id ,
'\n',"paid_amount : ",pt.response.paid_amount,'\n',"online : ",pt.response.online,'\n',"Created_at : ",pt.response.created_at,'\n'
,"Currency : " , pt.response.currency , '\n',"unique_id : ",pt.response.unique_id) as Response,
pt.approved_by,
pt.added_by,
pt.created_at,
pt.updated_at,
pt.canceled_by,
pt.cancellation_reason,
pt.canceled_at,

    stg_users.city,
    stg_users.customer,
    stg_users.client_category,
    stg_users.customer_type,
    stg_users.payment_term,
    stg_users.account_manager,
    stg_users.country,
    stg_users.financial_administration as financial_administration,
    stg_users.debtor_number,


from `floranow.erp_prod.payment_transactions` as pt 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = pt.user_id