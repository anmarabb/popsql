create or replace view `floranow.Floranow_ERP.statement_of_account` as 

select 

soa.id,
u.name as customer,
u.debtor_number,
soa.currency,
soa.total_amount,
soa.total_credit_amount,

soa.invoices_ids,


soa.sent_by_id,
u2.name as Printed_by,
soa.printed_at,
soa.sent_at,

soa.total_amount + soa.total_credit_amount as balance,

concat( "https://erp.floranow.com/statement_of_accounts/", soa.id) as statement_link,

case when soa.sent_at is null then 'Sent' else 'Not Sent' end as sent_status,

from `floranow.erp_prod.statement_of_accounts` as soa
left join `floranow.erp_prod.users` as u on soa.user_id = u.id
left join `floranow.erp_prod.users` as u2 on soa.printed_by_id = u2.id

--where soa.sent_at is not null