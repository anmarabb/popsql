create or replace table `floranow.Floranow_ERP.order_requests` as 


select

orr.id as order_request_id,
stg_users.customer,
orr.product_name,
orr.quantity,
orr.ordered_quantity,
orr.confirmed_quantity,



orr.delivery_date,
orr.departure_date,
orr.created_at,
orr.updated_at,
orr.rejected_at,



orr.currency,
orr.fob_price,

orr.price,

orr.status,


orr.color,
orr.stem_length,
orr.head_size,


created_by.name as created_by,
rejected_by.name as rejected_by,

orr_fs.name as feed_source,

stg_users.city,
stg_users.account_manager,
stg_users.country,
suppliers.supplier_name,
suppliers.account_manager as supplier_account_manager,
suppliers.supplier_region,
case when orr.standing_order_id is not null then 'standing_order' else 'normal' end as standing_order,

w.name as warehouse,


from `floranow.erp_prod.order_requests` as orr
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = orr.customer_id
left join `floranow.Floranow_ERP.suppliers` as suppliers on suppliers.id = orr.supplier_id
left join `floranow.erp_prod.users` as created_by on created_by.id = orr.created_by_id
left join `floranow.erp_prod.users` as rejected_by on rejected_by.id = orr.rejected_by_id
left join `floranow.erp_prod.feed_sources` as orr_fs on orr.feed_source_id = orr_fs.id
left join `floranow.erp_prod.standing_orders` as so on orr.standing_order_id = so.id
left join `floranow.erp_prod.order_builders` as ob on ob.id = orr.order_builder_id
left join `floranow.erp_prod.warehouses` as w on w.id = stg_users.warehouse_id

--where orr.standing_order_id is  null