SELECT

count(distinct i.id) as row_coun,
max(i.printed_at) as max_date,

from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = ii.customer_id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.Floranow_ERP.suppliers` as li_suppliers on li_suppliers.id = li.supplier_id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id = pod.id
left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id
left join  `floranow.erp_prod.line_items` as parent_li on parent_li.id = li.parent_line_item_id
left join `floranow.Floranow_ERP.suppliers` as parent_li_suppliers on parent_li_suppliers.id = parent_li.supplier_id
left join `floranow.erp_prod.warehouses` as w on w.id = stg_users.warehouse_id
where ii.deleted_at is null and  ii.__hevo__marked_deleted is not true and EXTRACT(YEAR FROM i.printed_at) = EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) and i.financial_administration_id = 1 and ii.status = 'APPROVED' and w.name = 'Qassim Warehouse'