create or replace view `floranow.Floranow_ERP.products` as 

with CTE as 
(

select
p.id,
p.feed_source_id,
p.supplier_id,
p.reseller_id,
p.order_id,
p.stock_id,
p.tags,
p.product_name as product,
p.stem_length,
p.color,
p.updated_at,
p.expired_at,
p.created_at,
p.departure_date as row_departure_date,
p.unit_fob_price,
p.fob_currency,
p.unit_landed_cost,
p.landed_currency,
p.unit_price,
p.currency,
p.age,
p.sales_unit, --monumon order quantity.
p.category as item_category,
p.category2 as item_sub_category,
p.stem_length_unit,

p.published_quantity,
p.remaining_quantity,
p.quantity,
p.quantity as p_quantity,



p.remaining_quantity * p.unit_price as remaining_value,
date_diff(cast(p.expired_at as date) , cast(p.updated_at as date), day) - date_diff(cast(current_date() as date), cast (p.updated_at as date) , day) as Remaining_Age,


pl.empty_at as pl_empty_at,
pl.labeled as pl_labeled,
pl.created_at as scaned_to_location_date,
pl.quantity as pl_quantity,
pl.remaining_quantity as pl_remaining_quantity,


li.quantity as li_quantity,
li.inventory_quantity,
li.fulfilled_quantity,
li.quantity - li.fulfilled_quantity as gap_quantity,


w.country as warehouse_country,
w.status as warehouse_status,
w.name as warehouse,
w.region_name as warehouse_region,

fs.name as origin_feed_name,
fs2.name as publishing_feed_name,
fs3.name as feed_name,
fs4.name as out_feed_source_name,


st.name as stock,
st.availability_type,

reseller.name as reseller,

stg_suppliers.supplier_name as supplier,
stg_suppliers.supplier_region,


case 
    when ad.id is not null then 'additional_inventory_item_id'
    when li.order_type ='RETURN' then 'return_inventory_item_id'
    when li.order_type ='MOVEMENT' then 'movement_inventory_item_id'
    else  'inventory_item_id'
end as inventory_item_type,

case 
    when p.remaining_quantity > 0 then 'Live Stock' 
    else 'Total Stock' 
end as Stock_type,

case 
    when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' 
    else li.order_type 
end as order_type,


case 
    when li.order_type = 'IMPORT_INVENTORY' and p.departure_date is null  then date(p.created_at) 
    else p.departure_date 
end as departure_date, 

case  
    when li.delivery_date is null and li.order_type in ('IMPORT_INVENTORY', 'EXTRA','MOVEMENT') then date(li.created_at)
    else li.delivery_date 
end as delivery_date,


 --   p.quantity - p.published_quantity  As sold_quantity,




li.delivery_date as row_delivery_date,


--li.order_type,

/*
locations.name as locations_name,
concat(locations.section , locations.label) as Location , 
*/





case when fs3.name = fs.name then 'Same feed_name' else 'Transformed feed_name' end as feed_name_type,

case 
    when fs4.name in ('Astra DXB out') then 'Astra'
    when fs4.name in ('Wish Flower Inventory') then 'Wish Flower'
    when fs4.name in ('Ecuador Out') then 'Ecuador'
    when fs4.name in ('Ward Flower Inventory') then 'Ward Flower'
    else 'Normal'
end as marketplace_projects,

concat( "https://erp.floranow.com/products/", p.id) as product_link,








case 
    when p.departure_date > current_date() then "Furue" 
    else "Present" 
end as future_departure_date,


concat(st.id, " - ", reseller.name , " - ", st.name ) as full_stock_name, --stock_id



case 
when st.id in (12,13) then 'Internal - Jumeriah'
when st.id in (10,11) then 'Internal - Spinnyes'
when st.id in (16,17) then 'Internal - TBF'
when st.id in (15) then 'Commission Based - Wish Flowers'
when st.id in (304,305) then 'Commission Based - Ward'
when st.id in (128,129,18,19,22,23,266,267,486,526,529,565,90,91) then 'Commission Based - Astra Express'
when st.id in (165,64,569,451,450,415,414,571,570,408,411,410,572,407,406,413,412) then 'Reselling Event'
when st.id in (522,484,567,566,531,530) then 'Reselling'
else 'Reselling'
end as stock_model,

--sometimes departure_date is null when the product source is imported from exel.
--



parent_li.order_type as parent_li_order_type,

case when li.parent_line_item_id is not null then 'parent_li' else null end as parent_li,


loc.id as location_id,
loc.label as location_name,
sec.name as section,

--quantity
    --product

    --line_item
        


li.creation_stage,
li.ordering_stock_type,


case 
when pl.quantity is null then 'not_scaned' 
when pl.quantity = p.quantity then 'scaned_good'
else 'scaned_flag' end as flag_1,





case when ad.id is not null then 'additional_items' else null end as ch_additional_items,




case 
when li.source_line_item_id is null and li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is not null then '1- Reselling Orders' --reselling_purchase_orders
when li.source_line_item_id is null and li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is null and li.pricing_type in ('FOB','CIF') then '3- Bulk Orders'
when li.source_line_item_id is null and li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is null then '2- Shipment Orders' --customer_direct_orders
when li.source_line_item_id is null and li.ordering_stock_type is not null and li.reseller_id is null then '4- Inventory Orders' --customer_inventory_orders

when li.source_line_item_id is null and li.ordering_stock_type is not null and li.reseller_id is not null then 'stock2stock'
when li.source_line_item_id is not null and li.order_type = 'EXTRA' then 'EXTRA'
when li.source_line_item_id is not null and li.order_type = 'RETURN' then 'RETURN' 
when li.source_line_item_id is not null and li.order_type = 'MOVEMENT' then 'MOVEMENT'
else 'cheack_my_logic'
end as persona,








-------- start cheack area ------------
case 
    when p.order_id is not null then 'order_id'
    when p.order_id is null then '--'
end as ch_order_id,

case 
    when p.line_item_id is not null then 'line_item_id'
    when p.line_item_id is null then '--'
end as ch_line_item_id,

case 
    when p.supplier_id is not null then 'supplier_id'
    when p.supplier_id is null then '--'
end as ch_supplier_id,

case 
    when p.feed_source_id is not null then 'feed_source_id'
    when p.feed_source_id is null then '--'
end as ch_feed_source_id,

case 
    when p.origin_feed_source_id is not null then 'origin_feed_source_id'
    when p.origin_feed_source_id is null then '--'
end as ch_origin_feed_source_id,


case 
    when p.publishing_feed_source_id is not null then 'publishing_feed_source_id'
    when p.publishing_feed_source_id is null then '--'
end as ch_publishing_feed_source_id,


case 
    when p.reseller_id is not null then 'reseller_id'
    when p.reseller_id is null then '--'
end as ch_reseller_id,


case 
    when p.supplier_product_id is not null then 'supplier_product_id'
    when p.supplier_product_id is null then '--'
end as ch_supplier_product_id,

case 
    when p.published_sales_unit is not null then 'published_sales_unit'
    when p.published_sales_unit is null then '--'
end as ch_published_sales_unit,

-------- End cheack area ------------



case when COUNT(*) over (partition by p.id)>1 then 'multi-location' else null end as multi_location,
row_number() over (partition by p.id) as row_number,



from floranow.erp_prod.products as p
left join `floranow.erp_prod.stocks` as st on st.id = p.stock_id and  st.reseller_id = p.reseller_id
left join `floranow.erp_prod.line_items` as li on li.id = p.line_item_id
left join `floranow.erp_prod.product_locations` as pl on pl.locationable_id = p.id and pl.locationable_type = "Product"
left join `floranow.erp_prod.locations` as loc on pl.location_id=loc.id

--left join `floranow.erp_prod.picking_products` as pp on pp.line_item_id = p.line_item_id
--left join `floranow.erp_prod.product_locations` as pl on  pp.product_location_id = pl.id and pl.locationable_id = p.id

left join `floranow.erp_prod.warehouses` as w on w.id = st.warehouse_id

left join `floranow.erp_prod.sections` as sec on sec.id =loc.section_id

left join  `floranow.erp_prod.line_items` as parent_li on parent_li.id = li.parent_line_item_id
left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = p.supplier_id
left join `floranow.Floranow_ERP.suppliers` as li_suppliers on li_suppliers.id = li.supplier_id


left join floranow.erp_prod.feed_sources as fs on fs.id = p.origin_feed_source_id
left join floranow.erp_prod.feed_sources as fs2 on fs2.id = p.publishing_feed_source_id
left join floranow.erp_prod.feed_sources as fs3 on fs3.id = p.feed_source_id
left join floranow.erp_prod.feed_sources as fs4 on fs4.id = st.out_feed_source_id
left join floranow.erp_prod.users as reseller on reseller.id = p.reseller_id

left join `floranow.erp_prod.additional_items_reports` as ad on ad.line_item_id=li.id


left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id

where p.deleted_at is  null



)

select

CTE.* EXCEPT(row_number)

from CTE
where row_number=1