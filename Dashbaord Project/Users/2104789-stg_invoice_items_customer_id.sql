--create or replace view `floranow.Floranow_ERP.stg_invoice_items_customer_id` as


select


---Holland
        sum (case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as MTD_holland,
        sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 and extract(day FROM i.printed_at) <= extract(day FROM current_date()) and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as LMTD_holland,
        sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as m_1_holland,
        sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 2 and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as m_2_holland,
        sum (case when date_diff(current_date(),date(i.printed_at), MONTH) = 3 and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as m_3_holland,
        sum (case when date_diff(current_date(),date(i.printed_at), YEAR) = 0 and li_suppliers.supplier_region = 'Holland' then ii.price_without_tax else 0 end) as ytd_holland,


SUM (
  CASE 
    WHEN 
      TIMESTAMP_TRUNC(TIMESTAMP(i.printed_at), WEEK(MONDAY)) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), WEEK(MONDAY)) 
      AND li_suppliers.supplier_region = 'Holland' 
    THEN ii.price_without_tax 
    ELSE 0 
  END
) AS WTD_holland,

SUM (
  CASE 
    WHEN 
      DATE(TIMESTAMP_TRUNC(i.printed_at, WEEK(MONDAY))) = DATE_SUB(DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), WEEK(MONDAY))), INTERVAL 7 DAY)
      AND EXTRACT(DAYOFWEEK FROM i.printed_at) <= EXTRACT(DAYOFWEEK FROM CURRENT_TIMESTAMP())
      AND li_suppliers.supplier_region = 'Holland' 
    THEN ii.price_without_tax 
    ELSE 0 
  END
) AS LWTD_holland,

SUM (
  CASE 
    WHEN 
      DATE(TIMESTAMP_TRUNC(i.printed_at, WEEK(MONDAY))) = DATE_SUB(DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), WEEK(MONDAY))), INTERVAL 7 DAY)
      AND li_suppliers.supplier_region = 'Holland' 
    THEN ii.price_without_tax 
    ELSE 0 
  END
) AS w_1_holland,

SUM (
  CASE 
    WHEN 
      DATE(TIMESTAMP_TRUNC(i.printed_at, WEEK(MONDAY))) = DATE_SUB(DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), WEEK(MONDAY))), INTERVAL 14 DAY)
      AND li_suppliers.supplier_region = 'Holland' 
    THEN ii.price_without_tax 
    ELSE 0 
  END
) AS w_2_holland,

SUM (
  CASE 
    WHEN 
      DATE(TIMESTAMP_TRUNC(i.printed_at, WEEK(MONDAY))) = DATE_SUB(DATE(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), WEEK(MONDAY))), INTERVAL 21 DAY)
      AND li_suppliers.supplier_region = 'Holland' 
    THEN ii.price_without_tax 
    ELSE 0 
  END
) AS w_3_holland,




--w_1_holland

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

count (distinct case when date_diff(date(i.printed_at) , current_date() , MONTH) = 0 then ii.invoice_id else null end) as MTD_orders,
count (distinct case when date_diff(current_date(),date(i.printed_at), MONTH) = 1 then ii.invoice_id else null end) as m_1_orders,
count (distinct case when date_diff(current_date(),date(i.printed_at), MONTH) = 2 then ii.invoice_id else null end) as m_2_orders,
count (distinct case when date_diff(current_date(),date(i.printed_at), MONTH) = 3 then ii.invoice_id else null end) as m_3_orders,
count (distinct case when date_diff(current_date(),date(i.printed_at), YEAR) = 0 then ii.invoice_id else null end) as ytd_orders,



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
    when max(i.generation_type) = 'MANUAL' and max(i.invoice_type) = 0 and abs (DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day )) <= 7 then 'active'
    when max(i.generation_type) = 'MANUAL' and max(i.invoice_type) = 0 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 7 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) <= 30 then 'inactive'
    when max(i.generation_type) = 'MANUAL' and max(i.invoice_type) = 0 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 30 then 'churned'
    else 'churned'  
    end as manual_account_status,



case 
    when max(li.order_type) = 'OFFLINE' and  max(orr.standing_order_id) is not null  and abs (DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day )) <= 7 then 'active'
    when max(li.order_type) = 'OFFLINE' and  max(orr.standing_order_id) is not null  and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 7 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) <= 30 then 'inactive'
    when max(li.order_type) = 'OFFLINE' and  max(orr.standing_order_id) is not null  and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(i.printed_at) AS date),day ) > 30 then 'churned'
    else 'churned'  
    end as standing_order_account_status,

    



from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id
left join `floranow.Floranow_ERP.suppliers` as li_suppliers on li_suppliers.id = li.supplier_id

left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id

where ii.status = 'APPROVED' and ii.deleted_at is null and ii.customer_id and =1385


group by ii.customer_id