create or replace view `floranow.Floranow_ERP.mov` as


select 
customer.id, 
customer.name,

case
when mi.documentable_id is not null and mi.documentable_type is not null then

(case when mi.documentable_type = 'PaymentTransaction' then pt.number else
(case when mi.entry_type = 'DEBIT' then i.number else cn.number end) 
 end )
 else null end as doc_number,



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


from `erp_prod.move_items` mi
join `erp_prod.users` customer on mi.user_id = customer.id
left join `erp_prod.invoices` as i on mi.documentable_id = i.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'DEBIT'
left join `erp_prod.invoices` as cn on mi.documentable_id = cn.id and mi.documentable_type = 'Invoice' and mi.entry_type = 'CREDIT'
left join `erp_prod.payment_transactions` pt on mi.documentable_id = pt.id and mi.documentable_type = 'PaymentTransaction' and  mi.entry_type = 'CREDIT'

where customer.deleted_at is null
and  mi.deleted_at is null
and customer.financial_administration_id = 1
and mi.balance != 0
and ((mi.entry_type = 'DEBIT' AND round(residual, 2) >= 0) OR (mi.entry_type = 'CREDIT' AND round(mi.residual, 2) <= 0))

and customer.id=965

order by mi.date desc