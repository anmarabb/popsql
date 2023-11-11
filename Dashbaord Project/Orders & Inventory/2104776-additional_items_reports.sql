create or replace view `floranow.Floranow_ERP.additional` as 


select
ad.created_at,
ad.delivery_date,
ad.status,
ad.creation_stage,

ad.quantity,
locations_quantities.value,


reported_by.name as reported_by,
rejected_by.name as rejected_by,
approved_by.name as approved_by,


w.name as warehouse,
fs.name as feed_source,
sh.name as shipment,



from `floranow.erp_prod.additional_items_reports` ad
left join floranow.erp_prod.products as p on p.id = ad.product_id
left join floranow.erp_prod.line_items as li on li.id = ad.line_item_id
left join `floranow.erp_prod.users` as reported_by on reported_by.id = ad.reported_by_id
left join `floranow.erp_prod.users` as rejected_by on rejected_by.id = ad.rejected_by_id
left join `floranow.erp_prod.users` as approved_by on approved_by.id = ad.approved_by_id
left join `floranow.erp_prod.shipments` as sh on ad.shipment_id = sh.id
left join `floranow.erp_prod.feed_sources` as fs on ad.feed_source_id = fs.id
left join `floranow.erp_prod.warehouses` as w on w.id = sh.warehouse_id