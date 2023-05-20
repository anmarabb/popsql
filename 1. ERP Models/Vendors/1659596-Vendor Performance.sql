with
perp_manageable_accounts as (select * from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User'),
perp_manageable_supplier_accounts as (select * from `floranow.erp_prod.manageable_accounts` where manageable_type = 'Supplier')
select


li.id,
li.product_name,
li.order_number,
s.name as Shipment,
li.order_type,
li.replace_for_id as Replace_For,

concat (u.debtor_number," (",u.name,") ") as Customer,

uc.name as Customer_Category,
u.email as Customer_Email,
case
when u.customer_type = 0 then 'Reseller'
when u.customer_type = 1 then 'Retailer'
when u.customer_type = 2 then 'FOB'
when u.customer_type = 4 then 'CIF'
else "Fix the Query"
end as Customer_Type,
u2.name as Account_Manager,
AccountManager.name as Supplier_Account_Manager,

u.debtor_number,
u.city,
u.country,
li.location,
li.quantity,
li.fulfilled_quantity,
li.inventory_quantity,
li.missing_quantity,
li.damaged_quantity,
li.delivered_quantity,
li.returned_quantity,
li.canceled_quantity,
li.created_at,
li.packaging.name as Packages,
sup.name as Supplier,
li.categorization,
concat (u3.name ," - ",r.name," (",pod.delivery_date,")") as Proof_Of_Delivery,
r1.name as Route,
fs.name as Feed_Source,
u4.name as Reseller,


li.grower_id as Grower,
li.supplier_product_name,
li.color,
li.stem_length,
li.tags,
li.properties,
li.pn.p1,
li.pn.p2,
li.pn.p3,
li.original_feed_source_id as Original_Feed_source,
li.calculated_price,
li.price_margin,
li.ordering_pattern,


concat (li.fob_currency , " " ,li.unit_fob_price) as Unit_Fob_Price,
concat(li.landed_currency , " " ,li.unit_landed_cost) as Unit_Landed_Cost,
concat(li.currency ," ",li.unit_price) as Unit_price,
concat (li.sales_unit," ",li.sales_unit_name) as Sales_Unit,


li.total_price_include_tax,
li.total_price_without_tax,
li.total_tax,
li.exchange_rate,
li.departure_date,
li.delivery_date,
li.expired_at,
li.completed_at,
li.delivered_at,
li.received_at,
li.received_note,
li.returned_at,
li.returned_by_id,
li.returned_note,
li.canceled_at,
li.canceled_by_id,
li.cancellation_reason,
li.damaged_at,
li.source_line_item_id,
li.state,
li.fulfillment,
li.custom_price,
li.pricing_type,
li.created_by_id,


from `floranow.erp_prod.line_items` as li
left join `floranow.erp_prod.shipments` as s on li.shipment_id = s.id

left join `floranow.erp_prod.users` as u on li.customer_id = u.id
left join `floranow.erp_prod.user_categories` as uc on u.user_category_id = uc.id
left join perp_manageable_accounts as ma on ma.manageable_id = u.id
left join `floranow.erp_prod.account_managers` as am on ma.account_manager_id = am.id
left join `floranow.erp_prod.users` as u2 on am.user_id = u2.id
left join `floranow.erp_prod.suppliers` as sup on li.supplier_id = sup.id
left join perp_manageable_supplier_accounts as sa on sa.manageable_id = sup.id
left join `floranow.erp_prod.account_managers` as saname on sa.account_manager_id = saname.id
left join `floranow.erp_prod.users` as AccountManager on saname.user_id = AccountManager.id
left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id =pod.id
left join `floranow.erp_prod.users` as u3 on pod.customer_id = u3.id
left join `floranow.erp_prod.routes` as r on pod.route_id = r.id
left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id
left join `floranow.erp_prod.routes` as r1 on r1.id = u.route_id
left join `floranow.erp_prod.users` as u4 on li.reseller_id = u4.id