with stg_move_items as (

select 
mi.id as move_item_id,
case when mi.entry_type = 'DEBIT' then (case when  mi.residual<0 then 0 else mi.residual end) else (case when mi.residual >0 then 0 else mi.residual  end) end as residual,


mi.date as aging_date,

--case when i.id is not null then date(i.due_date) else date(mi.date) end as aging_date,
from `erp_prod.move_items` mi
left join `erp_prod.invoices` as i on mi.documentable_id = i.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'DEBIT'
left join `erp_prod.users` customer on mi.user_id = customer.id

where customer.deleted_at is null
and  mi.deleted_at is null
and mi.balance != 0

)

select
mi.balance, 
mi.residual as raw_residual, --dont use.
stg_move_items.residual,
stg_move_items.aging_date,


    case when date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) <= 30 then stg_move_items.residual else 0 end as up_to_30_days,
    case when date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) > 30 and date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) <= 60 then stg_move_items.residual else 0 end as between_31_to_60_days,
    case when date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) > 60 and date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) <= 90 then stg_move_items.residual else 0 end as between_61_to_90_days,
    case when date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) > 90 and date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) <= 120 then stg_move_items.residual else 0 end as between_91_to_120_days,
    case when date_diff( cast(current_date() as date ),cast(stg_move_items.aging_date as date), DAY) > 120 then stg_move_items.residual else 0 end as more_than_120_days,


--case when entry_type = 'CREDIT' then mi.residual else 0 end as unreconciled_credits,
--case when entry_type = 'DEBIT' then mi.residual else 0 end as unreconciled_debits,



customer.name as Customer,
customer.debtor_number,
customer.id as customer_id,
customer.financial_administration_id,
w.name as warehouses,

                 case --financial ID
        when customer.financial_administration_id = 1 then 'KSA'
        when customer.financial_administration_id = 2 then 'UAE'
        when customer.financial_administration_id = 3 then 'Jordan'
        when customer.financial_administration_id = 4 then 'kuwait'
        when customer.financial_administration_id = 5 then 'Qatar'
        when customer.financial_administration_id = 6 then 'Bulk'
        when customer.financial_administration_id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,


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
mi.currency,
mi.entry_type,


mi.company_id as reporting_company_id,

/**
CASE
	WHEN customer.warehouse_id IN (10, 79, 76, 43) THEN
	CASE
		WHEN mi.date >= '2023-07-10' THEN customer.company_id

		WHEN mi.date < '2023-07-10' THEN 
		CASE 
			WHEN REGEXP_CONTAINS(customer.debtor_number, '(?i)^B') THEN 3
            WHEN customer.debtor_number IN ( 'shopqassim', 'shopcustomer', 'cashqassim', 'cashhail', 'SCJOUF', 'SCHAFAR', 'CCJOUF', 'CCHAFAR' ) THEN 3
            --WHEN customer.debtor_number IN ('LNDQAS', 'LNDJOU', 'LNDHAI', 'LNDHAF', 'FNQSIM', 'ASTJOU' ) THEN 3
			WHEN NOT REGEXP_CONTAINS(customer.debtor_number, '(?i)^B') THEN 
			CASE 
				WHEN mi.source_system = 'ODOO' THEN 3
				WHEN mi.source_system IN ('FLORANOW_ERP', 'FLORISOFT') THEN customer.company_id 
		    END
		END
	END

	WHEN customer.warehouse_id NOT IN (10, 79, 76, 43) OR customer.warehouse_id IS NULL THEN
	CASE
		WHEN mi.source_system = 'ODOO' THEN 3
		WHEN mi.source_system IN ('FLORANOW_ERP', 'FLORISOFT') THEN customer.company_id 
	END
END AS reporting_company_id,
**/

--case when mi.date >= '2023-01-01' AND mi.date <= '2023-07-09' then 'Y_to_9_Jul' else null end as Y_to_9_Jul, 


--case  when round(sum(stg_move_items.residual) over ()) != round(sum(mi.balance) over (), 2) then 'cheak' else null end as Ledger_SOA_cheack,


payment_terms.name as payment_term,
customer.credit_limit,


amu.name account_manager,

from `erp_prod.move_items` mi
left join `erp_prod.users` customer on mi.user_id = customer.id
left join `erp_prod.invoices` as i on mi.documentable_id = i.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'DEBIT'
left join `erp_prod.invoices` as cn on mi.documentable_id = cn.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'CREDIT'
left join `erp_prod.payment_transactions` pt on mi.documentable_id = pt.id and mi.documentable_type = 'PaymentTransaction' and  mi.entry_type = 'CREDIT'
left join `floranow.erp_prod.warehouses`  w on customer.warehouse_id = w.id

left join stg_move_items as stg_move_items on stg_move_items.move_item_id = mi.id
left join `floranow.erp_prod.payment_terms` as payment_terms on payment_terms.id = customer.payment_term_id


    left join `floranow.erp_prod.manageable_accounts`  manageable_accounts on customer.id = manageable_accounts.manageable_id and manageable_accounts.manageable_type = 'User'
    left join `floranow.erp_prod.account_managers`  am on manageable_accounts.account_manager_id = am.id
    left join `floranow.erp_prod.users`  as amu on am.user_id = amu.id



where customer.deleted_at is null
and  mi.deleted_at is null
and mi.balance != 0
--and ((mi.entry_type = 'DEBIT' AND round(residual, 2) >= 0) OR (mi.entry_type = 'CREDIT' AND round(mi.residual, 2) <= 0))