create or replace table `floranow.Floranow_ERP.move_items` as

   -- sum(case when date_diff( cast(current_date() as date ),cast(mi.date as date), DAY) <= 30 then mi.balance else 0 end) as up_to_30_days,


select 
customer.name as Customer,
customer.debtor_number,
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




case when entry_type = 'DEBIT' then balance else 0 end as total_debits,
case when entry_type = 'CREDIT' then balance else 0 end as total_credits,

    case when entry_type = 'CREDIT' and mi.documentable_type = 'PaymentTransaction' then balance else 0 end as payments,
    case when entry_type = 'CREDIT' and mi.documentable_type = 'Invoice' then balance else 0 end as credit_nots,


case when entry_type = 'CREDIT' then residual else 0 end as unreconciled_credits,
case when entry_type = 'DEBIT' then residual else 0 end as unreconciled_debits,




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

mi.residual,

mi.documentable_type,
mi.balance,
mi.currency,
mi.entry_type,




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


case when mi.date >= '2023-01-01' AND mi.date <= '2023-07-09' then 'Y_to_9_Jul' else null end as Y_to_9_Jul, 


from `erp_prod.move_items` mi
join `erp_prod.users` customer on mi.user_id = customer.id
left join `erp_prod.invoices` as i on mi.documentable_id = i.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'DEBIT'
left join `erp_prod.invoices` as cn on mi.documentable_id = cn.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'CREDIT'
left join `erp_prod.payment_transactions` pt on mi.documentable_id = pt.id and mi.documentable_type = 'PaymentTransaction' and  mi.entry_type = 'CREDIT'
left join `floranow.erp_prod.warehouses`  w on customer.warehouse_id = w.id

where customer.deleted_at is null
and  mi.deleted_at is null
--and customer.financial_administration_id = 1
and mi.balance != 0
and ((mi.entry_type = 'DEBIT' AND round(residual, 2) >= 0) OR (mi.entry_type = 'CREDIT' AND round(mi.residual, 2) <= 0))

--and customer.id=965

order by mi.date desc