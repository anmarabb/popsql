create or replace view `floranow.Floranow_ERP.stg_invoice_items` as


SELECT


ii.invoice_id,


count(ii.id) as items_count,
CASE WHEN max(date(i.printed_at)) > max(ii.delivery_date) then 'late_delivery' else 'on_time_delivery' End as otd_check,
sum(ii.price_without_tax) price_without_tax,
sum(case when li.supplier_id IN (109,71) then ii.price_without_tax else 0 end) as express_revenue,
sum(case when li.supplier_id is null then ii.price_without_tax else 0 end) as manual_revenue,
sum(case when li.supplier_id not IN (109,71) and li.supplier_id is not null then ii.price_without_tax else 0 end) as NonExpress_revenue,

sum(ii.quantity * li.unit_landed_cost)  as total_cost,
sum(ii.price_without_tax) - sum(ii.quantity * li.unit_landed_cost) as profit,

sum(ii.quantity) as quantity,
max(ii.delivery_date) as delivery_date,

--ii.price_without_tax - sum(ii.quantity * li.unit_landed_cost) as profit,


from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id


where ii.status = 'APPROVED' and ii.deleted_at is null




group by ii.invoice_id