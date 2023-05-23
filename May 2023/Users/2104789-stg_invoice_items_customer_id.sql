--create or replace view `floranow.Floranow_ERP.stg_invoice_items_customer_id` as


select
--ii.order_date,
--ii.printed_at,

/*
sum (case when li.order_type = 'ONLINE' then ii.price_without_tax else 0 end) as online_invoice_value,
sum (case when li.order_type != 'ONLINE' or li.order_type is null then ii.price_without_tax else 0 end) as offline_invoice_value,
sum( case when i.printed_at is not null then ii.price_without_tax else 0 end) as ltv,
*/
SAFE_DIVIDE(sum (case when i.source_type = 'INTERNAL'  and li.order_type = 'ONLINE' then ii.price_without_tax else 0 end) , sum( case when i.source_type = 'INTERNAL'  and i.printed_at is not null then ii.price_without_tax else 0 end)) as online_perc, 
SAFE_DIVIDE(sum (case when ( i.printed_at is not null and i.generation_type !='AUTO' and i.source_type = 'INTERNAL' and li.order_type is null) or (i.printed_at is not null and i.source_type = 'INTERNAL' and li.order_type not in ('ONLINE') )   then ii.price_without_tax else 0 end) , sum( case when i.source_type = 'INTERNAL' and i.printed_at is not null then ii.price_without_tax else 0 end)) as offline_perc, 

/*
sum (case when i.generation_type ='AUTO' then ii.price_without_tax - ii.quantity * li.unit_landed_cost else 0 end) as auto_profit,
sum(case when i.generation_type ='AUTO' and  i.printed_at is not null then ii.price_without_tax else 0 end) as auto_ltv,
*/

SAFE_DIVIDE(sum (case when i.generation_type ='AUTO' then ii.price_without_tax - ii.quantity * li.unit_landed_cost else 0 end),sum(case when i.generation_type ='AUTO' and  i.printed_at is not null then ii.price_without_tax else 0 end)) as auto_margin_perc, 

SAFE_DIVIDE(sum (case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 and i.generation_type ='AUTO' then ii.price_without_tax - ii.quantity * li.unit_landed_cost else 0 end),sum(case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 and i.generation_type ='AUTO' and  i.printed_at is not null then ii.price_without_tax else 0 end)) as MTD_auto_margin_perc, 


/*
sum(case when i.invoice_type = 1 then ii.price_without_tax else 0 end) as credit_note_total,
sum(case when i.invoice_type != 1 then ii.price_without_tax else 0 end) as invoice_revenue,
*/
SAFE_DIVIDE(abs(sum(case when i.invoice_type = 1 then ii.price_without_tax else 0 end)),sum(case when i.invoice_type != 1 then ii.price_without_tax else 0 end)) as CN_perc, 


ii.customer_id as customer_id ,


sum (case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 then ii.price_without_tax else 0 end) as MTD_invoice_value,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 and extract(day FROM i.printed_at) <= extract(day FROM current_date()) then ii.price_without_tax else 0 end) as LMTD_invoice_value,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 then ii.price_without_tax else 0 end) as m_1_invoice,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 2 then ii.price_without_tax else 0 end) as m_2_invoice,
sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 3 then ii.price_without_tax else 0 end) as m_3_invoice,

sum (case when date_diff(current_date(),date(i.printed_at), YEAR) = 0 then ii.price_without_tax else 0 end) as ytd_invoice,
sum (case when date_diff(current_date(),date(i.printed_at), YEAR) = 1 then ii.price_without_tax else 0 end) as y_1_invoice,
sum (case when date_diff(current_date(),date(i.printed_at), YEAR) = 2 then ii.price_without_tax else 0 end) as y_2_invoice,


sum (case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 
then case 
    when ii.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when ii.currency in ('AED') then ii.price_without_tax * 0.27229408
    when ii.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when ii.currency in ('USD') then ii.price_without_tax
    when ii.currency in ('EUR') then ii.price_without_tax * 1.0500713
        when ii.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when ii.currency is null then ii.price_without_tax * 0.27229408

end  else 0 end) as MTD_invoice_value_usd,

sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 and extract(day FROM i.printed_at) <= extract(day FROM current_date()) 
then case 
    when ii.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when ii.currency in ('AED') then ii.price_without_tax * 0.27229408
    when ii.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when ii.currency in ('USD') then ii.price_without_tax
    when ii.currency in ('EUR') then ii.price_without_tax * 1.0500713
        when ii.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when ii.currency is null then ii.price_without_tax * 0.27229408

end  else 0 end) as LMTD_invoice_value_usd,


sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 
then case 
    when ii.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when ii.currency in ('AED') then ii.price_without_tax * 0.27229408
    when ii.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when ii.currency in ('USD') then ii.price_without_tax
    when ii.currency in ('EUR') then ii.price_without_tax * 1.0500713
        when ii.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when ii.currency is null then ii.price_without_tax * 0.27229408

end  else 0 end) as m_1_invoice_usd,

sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 2 
then case 
    when ii.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when ii.currency in ('AED') then ii.price_without_tax * 0.27229408
    when ii.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when ii.currency in ('USD') then ii.price_without_tax
    when ii.currency in ('EUR') then ii.price_without_tax * 1.0500713
        when ii.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when ii.currency is null then ii.price_without_tax * 0.27229408

end  else 0 end) as m_2_invoice_usd,

case 
    when max(i.generation_type) = 'MANUAL' and abs (DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day )) <= 7 then 'active'
    when max(i.generation_type) = 'MANUAL' and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 7 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) <= 30 then 'inactive'
    when max(i.generation_type) = 'MANUAL' and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 30 then 'churned'
    else 'churned'  
    end as manual_account_status,



    



from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id

where ii.status = 'APPROVED' and ii.deleted_at is null 


group by ii.customer_id