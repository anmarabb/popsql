select
ii.id,
ii.product_name as item,
ii.price_without_tax as price,
AVG(ii.price_without_tax) OVER() as avg_item_price,
max(ii.price_without_tax) OVER() as max_item_price,
min(ii.price_without_tax) OVER() as min_item_price,
sum(ii.price_without_tax) OVER() as sum_item_price,

count(ii.id) OVER() as num_of_items_soled,
/*

*/

from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.users` as u on ii.customer_id = u.id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id

where u.financial_administration_id =2 and ii.status ='APPROVED'  and date_diff(current_date() ,date(i.printed_at), MONTH) = 1

--limit 100