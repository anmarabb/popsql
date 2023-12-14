create or replace table `floranow.Floranow_ERP.payments` as 

    
    select 
    case when pt.payment_received_at is not null then pt.payment_received_at else cmi.date end as master_date,
    date(cmi.date) as cridet_date, -- date of paymnet_transaction
     warehouse.name as warehouse,

           customer.warehouse_id as customer_warehouse_id,
           date(pt.payment_received_at)                                    payment_received_at,
           customer.name                                                   customer,
           customer.debtor_number                                          debtor_number,
           category.name as category_name,
           pt.payment_method,
           amu.name account_manager,
           customer.city,
           case when inv.id is null and dmi.source_system = 'ODOO'   then 'ODOO' else inv.number end as invoice_number,
           inv.id                                                       as invoice_id,
           pt.id as pt_id,
           pt.trx_reference,
           case when cmi.documentable_type = 'PaymentTransaction' and cmi.documentable_id is not null then  'Payment' when ( cmi.documentable_type = 'Invoice' and cmi.documentable_id is not null ) then 'CreditNote' end as document_type,
           case when (pt.id is null and cn.id is null and cmi.source_system = 'ODOO')   then 'ODOO' else pt.number end as payment_transaction_number,
           case when (pt.id is null and cn.id is null and cmi.source_system = 'ODOO')   then 'ODOO' else cn.number end as credit_note_number,
           payments.source_system reconcile_source_system,
           payments.external_source_id odoo_id,
           pt.approval_code,
           payments.total_amount reconciled_anount,
           null as unreconciled_anount,
           payments.total_amount as amount,
          -- fad.name financial_administration,
                 case --financial ID
        when fad.id = 1 then 'KSA'
        when fad.id = 2 then 'UAE'
        when fad.id = 3 then 'Jordan'
        when fad.id = 4 then 'kuwait'
        when fad.id = 5 then 'Qatar'
        when fad.id = 6 then 'Bulk'
        when fad.id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,
           fad.id financial_administration_id,
           

        





                case 
                when customer.company_id = 3 then 'Bloomax Flowers LTD'
                when customer.company_id = 2 then 'Global Floral Arabia tr'
                when customer.company_id = 1 then 'Flora Express Flower Trading LLC'
                else  'cheack'
                end as company_name,
pt.transaction_type,
inv.printed_at,
case when pt.payment_gateway=0 then 'telr' else null end as payment_gateway,

case when cmi.documentable_type = 'Invoice' then payments.total_amount else 0 end  as  CN_amount,
case when cmi.documentable_type = 'PaymentTransaction' then payments.total_amount else 0 end  as  PT_amount,

from `floranow.erp_prod.payments` payments
join `floranow.erp_prod.users`  customer on payments.user_id = customer.id
join `floranow.erp_prod.move_items`  dmi on payments.debit_move_item_id = dmi.id
join `floranow.erp_prod.move_items`  cmi on payments.credit_move_item_id = cmi.id
left join  `floranow.erp_prod.invoices`  inv on dmi.documentable_id = inv.id and dmi.documentable_type = 'Invoice' and dmi.entry_type = 'DEBIT'
left join `floranow.erp_prod.payment_transactions`  pt on cmi.documentable_id = pt.id and cmi.documentable_type = 'PaymentTransaction' and cmi.entry_type = 'CREDIT'
left join `floranow.erp_prod.invoices`  cn on cmi.documentable_id = cn.id and cmi.documentable_type = 'Invoice' and cmi.entry_type = 'CREDIT'
left join `floranow.erp_prod.user_categories`  category on customer.user_category_id = category.id
left join `floranow.erp_prod.manageable_accounts` manageable_accounts on customer.id = manageable_accounts.manageable_id and manageable_accounts.manageable_type = 'User'
left join `floranow.erp_prod.account_managers`  am on manageable_accounts.account_manager_id = am.id
left join `floranow.erp_prod.users`  as amu on am.user_id = amu.id
left join `floranow.erp_prod.financial_administrations`  fad on dmi.financial_administration_id = fad.id
left join `floranow.erp_prod.warehouses`  warehouse  on customer.warehouse_id = warehouse.id


    ---- filters----
UNION ALL ------------------------------------query for unreconciled payment transactions amount------------------------------------------------------------



select 
case when cmi.date is not null then cmi.date else cmi.date end as master_date,

date(cmi.date)  as cridet_date,
warehouse.name as warehouse,
customer.warehouse_id as customer_warehouse_id,
date(pt.payment_received_at) as payment_received_at,
customer.name as customer,
customer.debtor_number as debtor_number,
category.name as category_name,

pt.payment_method,
amu.name account_manager,
customer.city,
null as invoice_number,
null as invoice_id,
pt.id as pt_id,
pt.trx_reference,
case when cmi.documentable_type = 'PaymentTransaction' and cmi.documentable_id is not null then  'Payment' when ( cmi.documentable_type = 'Invoice' and cmi.documentable_id is not null ) then 'CreditNote' end as document_type,
case when (pt.id is null and cn.id is null and cmi.source_system = 'ODOO')   then 'ODOO' else pt.number end as payment_transaction_number,
case when (pt.id is null and cn.id is null and cmi.source_system = 'ODOO')   then 'ODOO' else cn.number end as credit_note_number,
null as reconcile_source_system,
null as odoo_id,
pt.approval_code,
null as reconciled_anount,
abs(cmi.residual) unreconciled_anount,
abs(cmi.residual) amount,
--fad.name financial_administration,
case --financial ID
when fad.id = 1 then 'KSA'
when fad.id = 2 then 'UAE'
when fad.id = 3 then 'Jordan'
when fad.id = 4 then 'kuwait'
when fad.id = 5 then 'Qatar'
when fad.id = 6 then 'Bulk'
when fad.id = 7 then 'Internal'
else 'check_my_logic'
end as financial_administration,
fad.id financial_administration_id,

case 
when customer.company_id = 3 then 'Bloomax Flowers LTD'
when customer.company_id = 2 then 'Global Floral Arabia tr'
when customer.company_id = 1 then 'Flora Express Flower Trading LLC'
else  'cheack'
end as company_name,

pt.transaction_type,
inv.printed_at,

case when pt.payment_gateway=0 then 'telr' else null end as payment_gateway,

abs(CNmi.residual) as CN_amount,
abs(PTmi.residual) as PT_amount,

from `floranow.erp_prod.move_items`  cmi
join `floranow.erp_prod.users`  customer on cmi.user_id = customer.id
left join `floranow.erp_prod.payment_transactions`  pt on cmi.documentable_id = pt.id and cmi.documentable_type = 'PaymentTransaction' and cmi.entry_type = 'CREDIT'
left join  `floranow.erp_prod.invoices` cn on cmi.documentable_id = cn.id and cmi.documentable_type = 'Invoice' and cmi.entry_type = 'CREDIT'
left join `floranow.erp_prod.user_categories`  category on customer.user_category_id = category.id
left join `floranow.erp_prod.manageable_accounts`  manageable_accounts on customer.id = manageable_accounts.manageable_id and manageable_accounts.manageable_type = 'User'
left join `floranow.erp_prod.account_managers`  am on manageable_accounts.account_manager_id = am.id
left join `floranow.erp_prod.users`  as amu on am.user_id = amu.id
left join `floranow.erp_prod.financial_administrations`  fad on cmi.financial_administration_id = fad.id
left join `floranow.erp_prod.warehouses`  warehouse on customer.warehouse_id = warehouse.id
left join `floranow.erp_prod.invoices` as inv on cmi.documentable_id = inv.id and cmi.documentable_type = 'Invoice' and cmi.entry_type = 'DEBIT'


left join `floranow.erp_prod.move_items`  CNmi on  CNmi.id = cmi.id and CNmi.documentable_type = 'Invoice' 
left join `floranow.erp_prod.move_items`  PTmi on  PTmi.id = cmi.id and PTmi.documentable_type = 'PaymentTransaction' 

where round(cmi.residual, 2) != 0 and cmi.entry_type='CREDIT'

and cmi.deleted_at is null
and cmi.documentable_id is not null
and cmi.__hevo__marked_deleted is not true




      ---- more filters----


order by reconciled_anount, payment_transaction_number