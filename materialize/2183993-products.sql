create view  products as 
select 

p.id,
p.feed_source_id,
p.supplier_id,
p.reseller_id,
p.order_id,
p.stock_id,
p.tags,
p.product_name AS product,
p.stem_length,
p.color,
p.updated_at,
p.expired_at,
p.created_at,
p.departure_date AS row_departure_date,
p.unit_fob_price,
p.fob_currency,
p.unit_landed_cost,
p.landed_currency,
p.unit_price,
p.currency,
p.age,
p.sales_unit, 
p.category AS item_category,
p.category2 AS item_sub_category,
p.stem_length_unit,
p.published_quantity,
p.remaining_quantity,
p.quantity,
p.quantity AS p_quantity,
p.remaining_quantity * p.unit_price AS remaining_value,
EXTRACT(DAY FROM (CAST(p.expired_at AS DATE) - CAST(p.updated_at AS DATE))) - EXTRACT(DAY FROM (CAST(CURRENT_DATE AS DATE) - CAST (p.updated_at AS DATE))) AS Remaining_Age,
pl.empty_at AS pl_empty_at,
pl.labeled AS pl_labeled,
pl.created_at AS scaned_to_location_date,
pl.quantity AS pl_quantity,
pl.remaining_quantity AS pl_remaining_quantity,
li.quantity AS li_quantity,
li.inventory_quantity,
li.fulfilled_quantity,
li.quantity - li.fulfilled_quantity AS gap_quantity,
w.country AS warehouse_country,
w.status AS warehouse_status,
w.name AS warehouse,
w.region_name AS warehouse_region,
fs.name AS origin_feed_name,
fs2.name AS publishing_feed_name,
fs3.name AS feed_name,
fs4.name AS out_feed_source_name,
st.name AS stock,
st.availability_type,
reseller.name AS reseller,
stg_suppliers.supplier_name AS supplier,
stg_suppliers.supplier_region,
CASE
    WHEN ad.id IS NOT NULL THEN 'additional_inventory_item_id'
    WHEN li.order_type ='RETURN' THEN 'return_inventory_item_id'
    WHEN li.order_type ='MOVEMENT' THEN 'movement_inventory_item_id'
    ELSE  'inventory_item_id'
END AS inventory_item_type,
CASE
    WHEN p.remaining_quantity > 0 THEN 'Live Stock'
    ELSE 'Total Stock'
END AS Stock_type,
CASE
    WHEN li.order_type = 'OFFLINE' AND orr.standing_order_id IS NOT NULL THEN 'STANDING'
    ELSE li.order_type
END AS order_type,
CASE
    WHEN li.order_type = 'IMPORT_INVENTORY' AND p.departure_date IS NULL THEN CAST(p.created_at AS DATE)
    ELSE p.departure_date
END AS departure_date,
CASE
    WHEN li.delivery_date IS NULL AND li.order_type IN ('IMPORT_INVENTORY', 'EXTRA','MOVEMENT') THEN CAST(li.created_at AS DATE)
    ELSE li.delivery_date
END AS delivery_date,
li.delivery_date AS row_delivery_date,
CASE WHEN fs3.name = fs.name THEN 'Same feed_name' ELSE 'Transformed feed_name' END AS feed_name_type,
CASE
    WHEN fs4.name IN ('Astra DXB out') THEN 'Astra'
    WHEN fs4.name IN ('Wish Flower Inventory') THEN 'Wish Flower'
    WHEN fs4.name IN ('Ecuador Out') THEN 'Ecuador'
    WHEN fs4.name IN ('Ward Flower Inventory') THEN 'Ward Flower'
    ELSE 'Normal'
END AS marketplace_projects,
'https://erp.floranow.com/products/' || p.id AS product_link,
CASE
    WHEN p.departure_date > CURRENT_DATE THEN 'Future'
    ELSE 'Present'
END AS future_departure_date,
st.id || ' - ' || reseller.name || ' - ' || st.name AS full_stock_name,
CASE
WHEN st.id IN (12,13) THEN 'Internal - Jumeriah'
WHEN st.id IN (10,11) THEN 'Internal - Spinnyes'
WHEN st.id IN (16,17) THEN 'Internal - TBF'
WHEN st.id IN (15) THEN 'Commission Based - Wish Flowers'
WHEN st.id IN (304,305) THEN 'Commission Based - Ward'
WHEN st.id IN (128,129,18,19,22,23,266,267,486,526,529,565,90,91) THEN 'Commission Based - Astra Express'
WHEN st.id IN (165,64,569,451,450,415,414,571,570,408,411,410,572,407,406,413,412) THEN 'Reselling Event'
WHEN st.id IN (522,484,567,566,531,530) THEN 'Reselling'
ELSE 'Reselling'
END AS stock_model,
parent_li.order_type AS parent_li_order_type,
CASE WHEN li.parent_line_item_id IS NOT NULL THEN 'parent_li' ELSE NULL END AS parent_li,
loc.id AS location_id,
loc.label AS location_name,
sec.name AS section,
li.creation_stage,
li.ordering_stock_type


from products as p

left join stocks as st on st.id = p.stock_id and  st.reseller_id = p.reseller_id
left join line_items as li on li.id = p.line_item_id
left join product_locations as pl on pl.locationable_id = p.id and pl.locationable_type = 'Product'
left join locations as loc on pl.location_id=loc.id
left join warehouses as w on w.id = st.warehouse_id
left join sections as sec on sec.id =loc.section_id
left join  line_items as parent_li on parent_li.id = li.parent_line_item_id
left join suppliers as stg_suppliers on stg_suppliers.id = p.supplier_id
left join suppliers as li_suppliers on li_suppliers.id = li.supplier_id
left join feed_sources as fs on fs.id = p.origin_feed_source_id
left join feed_sources as fs2 on fs2.id = p.publishing_feed_source_id
left join feed_sources as fs3 on fs3.id = p.feed_source_id
left join feed_sources as fs4 on fs4.id = st.out_feed_source_id
left join users as reseller on reseller.id = p.reseller_id
left join additional_items_reports as ad on ad.line_item_id=li.id
left join order_requests as orr on li.order_request_id = orr.id
where p.deleted_at is  null;