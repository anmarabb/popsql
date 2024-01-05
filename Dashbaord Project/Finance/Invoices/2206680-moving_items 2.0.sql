create or replace table `floranow.Floranow_ERP.move_items` as


select

mi.balance,  
mi.residual, --
mi.id as move_item_id,

case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) <= 30 then mi.residual else 0 end as up_to_30_days,
case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) > 30 and date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) <= 60 then mi.residual else 0 end as between_31_to_60_days,
case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) > 60 and date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) <= 90 then mi.residual else 0 end as between_61_to_90_days,
case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) > 90 and date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) <= 120 then mi.residual else 0 end as between_91_to_120_days,
case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) > 120 then mi.residual else 0 end as more_than_120_days,




customer.name as Customer,
customer.debtor_number,
customer.id as customer_id,
customer.financial_administration_id,
customer.city,
customer.country,
user_categories.name as category_name,


w.name as warehouses,

case --financial ID
when mi.financial_administration_id = 1 then 'KSA'
when mi.financial_administration_id = 2 then 'UAE'
when mi.financial_administration_id = 3 then 'Jordan'
when mi.financial_administration_id = 4 then 'kuwait'
when mi.financial_administration_id = 5 then 'Qatar'
when mi.financial_administration_id = 6 then 'Bulk'
when mi.financial_administration_id = 7 then 'Internal'
else 'check_my_logic'
end as financial_administration,


mi.currency,

/*
case 
    when mi.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when mi.currency in ('AED') then ii.price_without_tax * 0.27229408
    when mi.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when mi.currency in ('USD') then ii.price_without_tax
    when mi.currency in ('EUR') then ii.price_without_tax * 1.0500713
    when mi.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when mi.currency is null then ii.price_without_tax * 0.27229408
end as usd_price_without_tax,
*/


case 
when customer.company_id = 3 then 'Bloomax Flowers LTD'
when customer.company_id = 2 then 'Global Floral Arabia tr'
when customer.company_id = 1 then 'Flora Express Flower Trading LLC'
else  'cheack'
end as company_name,


case
when mi.documentable_id is not null and mi.documentable_type is not null then
(case when mi.documentable_type = 'PaymentTransaction' then pt.number else
(case when mi.entry_type = 'DEBIT' then i.number else cn.number end) 
 end )
 else null end as doc_number,





case when entry_type = 'DEBIT' then mi.balance else 0 end as total_debits,
case when entry_type = 'CREDIT' then mi.balance else 0 end as total_credits,

--total_credits = 
    case when entry_type = 'CREDIT' and mi.documentable_type = 'PaymentTransaction' then mi.balance else 0 end as payments,
    case when entry_type = 'CREDIT' and mi.documentable_type = 'Invoice' then mi.balance else 0 end as credit_nots,
     case when entry_type = 'CREDIT' and (mi.documentable_id is null or mi.documentable_type is null) then mi.balance end  as other_credit,

case when entry_type = 'DEBIT' then balance else 0 end as gross_sales,



    CASE
        WHEN mi.documentable_id IS NOT NULL AND mi.documentable_type IS NOT NULL THEN
            CASE 
                WHEN mi.documentable_type = 'PaymentTransaction' THEN 'PT' 
                WHEN mi.entry_type = 'DEBIT' THEN 'INV' 
                ELSE 'CN' 
            END
    END AS doc_type,

mi.date,
mi.source_system,
mi.reconciled,




mi.documentable_type,

mi.entry_type,




mi.company_id as reporting_company_id,


payment_terms.name as payment_term,
customer.credit_limit,


amu.name account_manager,

from `erp_prod.move_items` mi
left join `erp_prod.users` customer on mi.user_id = customer.id and customer.deleted_at is null
left join `erp_prod.invoices` as i on mi.documentable_id = i.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'DEBIT'
left join `erp_prod.invoices` as cn on mi.documentable_id = cn.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'CREDIT'
left join `erp_prod.payment_transactions` pt on mi.documentable_id = pt.id and mi.documentable_type = 'PaymentTransaction' and  mi.entry_type = 'CREDIT'
left join `floranow.erp_prod.warehouses`  w on customer.warehouse_id = w.id

left join `floranow.erp_prod.payment_terms` as payment_terms on payment_terms.id = customer.payment_term_id


left join `floranow.erp_prod.manageable_accounts`  manageable_accounts on customer.id = manageable_accounts.manageable_id and manageable_accounts.manageable_type = 'User'
left join `floranow.erp_prod.account_managers`  am on manageable_accounts.account_manager_id = am.id
left join `floranow.erp_prod.users`  as amu on am.user_id = amu.id

left join floranow.erp_prod.user_categories AS user_categories ON customer.user_category_id = user_categories.id


where 
mi.deleted_at is null
and mi.balance != 0
--and mi.documentable_id is not null
and mi.__hevo__marked_deleted is not true