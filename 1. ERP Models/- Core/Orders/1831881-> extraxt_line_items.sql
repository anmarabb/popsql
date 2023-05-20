SELECT
li.id,
stg_users.financial_administration,
concat( "https://erp.floranow.com/line_items/", li.id) as line_item_link,


li.state,
li.tags,
li.created_at,
li.delivery_date,
li.departure_date,

stg_suppliers.supplier_name,
fs.name as feed_source,

stg_users.customer,
stg_users.debtor_number,


li.product_name as product,
li.unit_landed_cost,
li.unit_fob_price,
li.unit_price,

li.total_price_without_tax,

li.order_number,
case when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' else li.order_type end as order_type,


sh.name as shipment,
    
case when li.proof_of_delivery_id is not null then 'POD' else 'null' end as proof_of_delivery,




--quantity
    li.quantity,  --conformed_quantity from supplier
    li.fulfilled_quantity, --received and valied excluding extra --- minace extra
    li.received_quantity, --received and valied including extra, received quantity on the warehouse
    li.missing_quantity,
    li.damaged_quantity,
    li.delivered_quantity,
    li.extra_quantity,
    li.returned_quantity,
    li.canceled_quantity,
    




li.category as item_category,
li.category2 as item_sub_category,
li.currency,
li.landed_currency,
li.fob_currency,


FROM
`floranow.erp_prod.line_items` As li

left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = li.customer_id
left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = li.supplier_id
left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id = pod.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id
left join `floranow.erp_prod.invoices` as i on li.invoice_id = i.id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join floranow.erp_prod.products AS products ON li.id = products.line_item_id
left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id


--where stg_users.financial_administration in ('UAE','KSA','Bulk')