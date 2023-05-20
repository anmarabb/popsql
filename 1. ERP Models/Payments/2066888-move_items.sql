--create or replace view `floranow.Floranow_ERP.payments` as 

with prep_payments as

(
select
credit_move_item_id,
max(py.created_at) as payment_date,
sum(paid_amount) as paid_amount
from `floranow.erp_prod.payments` as py
group by 1
)



select

case when moi.date is not null then moi.date else moi.created_at end as created_at, 
case when pt.payment_received_at is not null then pt.payment_received_at else moi.created_at end as received_at, 

--pt.payment_received_at,


--caseh paM '' then payment_received_at


-moi.balance as paid_amount,
-(moi.balance - moi.residual) as reconciled_amount,
-moi.residual as un_reconciled_amount,

case when moi.reconciled is true then 'reconciled' else null end as reconciled,
 
pt.created_by,
pt.payment_method,

stg_users.customer,
stg_users.account_manager,
stg_users.debtor_number,
stg_users.company_name,
stg_users.city,
stg_users.client_category,


--fn.name as financial_administration,

case --financial ID
        when fn.id = 1 then 'KSA'
        when fn.id = 2 then 'UAE'
        when fn.id = 3 then 'Jordan'
        when fn.id = 4 then 'kuwait'
        when fn.id = 5 then 'Qatar'
        when fn.id = 6 then 'Bulk'
        when fn.id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,




--py.payment_type,


from `floranow.erp_prod.move_items` as moi
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = moi.user_id
left join `floranow.erp_prod.payment_transactions` as pt on pt.id = moi.documentable_id and documentable_type = 'PaymentTransaction'

left join `floranow.erp_prod.financial_administrations` as fn on fn.id=pt.financial_administration_id

left join `floranow.erp_prod.bank_accounts` as ba on pt.bank_account_id = ba.id

left join prep_payments as prep_payments on prep_payments.credit_move_item_id = moi.id

where documentable_type = 'PaymentTransaction' and entry_type = 'CREDIT'


--1 row per 1 transaction per day