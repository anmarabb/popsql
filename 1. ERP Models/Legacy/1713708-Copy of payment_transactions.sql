create or replace view `floranow.Floranow_ERP.Payments_transactions` as 

with

prep_manageable_accounts as (select * from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User')


select 

pt.id, 
pt.number, 
pt.status,
u.name as Customer,
u.debtor_number,
uc.name as User_category,
u2.name as Account_manager,
pt.invoice_numbers,
pt.paid_amount,
pt.credit_note_amount,
pt.total_amount,
pt.currency,
pt.transaction_type,
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
pt.canceled_at


from `floranow.erp_prod.payment_transactions` as pt 
left join `floranow.erp_prod.users` as u on pt.user_id = u.id 
left join `floranow.erp_prod.user_categories` as uc on u.user_category_id = uc.id
left join prep_manageable_accounts as ma on u.id = ma.manageable_id
left join `floranow.erp_prod.account_managers` as am on ma.account_manager_id = am.id
left join `floranow.erp_prod.users` as u2 on am.user_id = u2.id