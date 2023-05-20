SELECT
concat( "https://erp.floranow.com/invoices/", i.id) as invoice_link,
i.source_type,
i.number,
i.total_amount,
i.remaining_amount,

i.paid_amount as erp_paid_amount,
jibu_uae.PaidAmount as florisfot_paid_amount,
case 
when jibu_uae.PaidAmount is null  and i.paid_amount =0 then 'Not_paid_erp_nor_florisfot'
when jibu_uae.PaidAmount =0  and i.paid_amount =0 then 'Not_paid_erp_nor_florisfot'

when jibu_uae.PaidAmount is null and i.paid_amount >0 then 'paid_in_ERP'
when jibu_uae.PaidAmount =0 and i.paid_amount !=0 then 'paid_in_ERP'

when jibu_uae.PaidAmount = i.paid_amount then 'paid_moved_ok'
when jibu_uae.PaidAmount >0 and i.paid_amount=0 then 'paid_in_florisft_not_moved'
else 'check'
end as logic

from `floranow.erp_prod.invoices` as i
left join `floranow.Floranow_ERP.Jibu_UAE_florisfot_data` as jibu_uae on concat('F',jibu_uae.FACTNR)=number

--where number is not null and i.source_type != 'INTERNAL' and jibu_uae.PaidAmount is not null