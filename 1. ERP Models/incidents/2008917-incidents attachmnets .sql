select 
atch.created_at,
atch.name as attachment_name,
atch.record_type as attachment_type,
blob.filename,
blob.content_type,
blob.checksum,
blob.key,


from `floranow.erp_prod.active_storage_attachments` as atch
left join `floranow.erp_prod.active_storage_blobs` as blob on blob.id = atch.blob_id
left join `floranow.erp_prod.active_storage_variant_records` as records on records.id = atch.blob_id;




select 

pi.*,

from `floranow.erp_prod.product_incidents` as pi 
left join `floranow.erp_prod.line_items` as li on pi.line_item_id = li.id
left join `erp_prod.products` as p on p.line_item_id = li.id 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = li.customer_id

left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = li.supplier_id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id

left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id
left join `floranow.erp_prod.stocks` as stock on p.stock_id = stock.id 
left join `floranow.erp_prod.warehouses` as w on w.id = stock.warehouse_id

left join floranow.erp_prod.users as reseller on reseller.id = p.reseller_id



where pi.deleted_at is null and pi.id=48302;