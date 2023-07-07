--create or replace table `floranow.Floranow_ERP.monthly_views` as

with preb_budget as (
SELECT
bud.financial_administration,
extract(year from bud.date) as year,
extract(month from bud.date) as month,
sum(bud.budget) as budget,
FROM `floranow.erp_prod.budget` as bud
group by 1,2,3

)

select
        stg_users.financial_administration,
        DATE_TRUNC(i.printed_at,month) as month_of_year,
        extract(year from i.printed_at) as year,
        extract(month from i.printed_at) as month,

        count(distinct stg_users.debtor_number) as clients,
        SAFE_DIVIDE(count(distinct concat(stg_users.debtor_number,i.printed_at)),count(distinct stg_users.debtor_number)) as frequency, --orders/clients
        SAFE_DIVIDE(sum(ii.price_without_tax),count(distinct concat(stg_users.debtor_number,i.printed_at))) as basket_size, --revenue/orders
        count(distinct concat(stg_users.debtor_number,i.printed_at)) as deliveries,
        count(ii.id) as items,
        sum(ii.quantity) as quantity,
        sum(ii.price_without_tax) as monthly_revenue,
        sum(case when i.invoice_type = 1 then ii.price_without_tax else 0 end) as credit_note,
        sum(case when i.invoice_type = 0 then ii.price_without_tax else 0 end) as invoiced_revenue,
       round(SAFE_DIVIDE(sum(case when i.invoice_type = 1 then ii.price_without_tax else 0 end), sum(case when i.invoice_type = 0 then ii.price_without_tax else 0 end)),4) creditNote_perc,

        max(budget.budget) as budget ,
        
        SAFE_DIVIDE(sum (case when ( i.printed_at is not null and i.generation_type !='AUTO' and i.source_type = 'INTERNAL' and li.order_type is null) or (i.printed_at is not null and i.source_type = 'INTERNAL' and li.order_type not in ('ONLINE') )   then ii.price_without_tax else 0 end) , sum( case when i.source_type = 'INTERNAL' and i.printed_at is not null then ii.price_without_tax else 0 end)) as offline_perc, 

        
    --SAFE_DIVIDE(sum(ii.price_without_tax),max(budget.budget)) as achievement_rate, 

from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = ii.customer_id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id
left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = li.supplier_id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id

left join preb_budget as budget on budget.month = extract(month from i.printed_at) and budget.year = extract(year from i.printed_at) and budget.financial_administration = stg_users.financial_administration

where ii.status = 'APPROVED' and ii.deleted_at is null  --and i.printed_at >= '2022-01-01'
group by  1,2,3,4
order by 1 desc,2 desc, 3 desc