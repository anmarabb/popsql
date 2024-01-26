create or replace table `floranow.Floranow_ERP.product_incidents` as

select 


--concat ('NCR-',li.departure_date,'-', sh.id) as NCR,

concat('NCR-', FORMAT_TIMESTAMP('%y%m%d', li.departure_date), '-', sh.id) as NCR,



pi.incident_type, --MISSING, DAMAGED, EXTRA, RETURNED, QUALITY_ISSUES, TRANSACTIONAL_ISSUES, INCORRECT_ITEM
pi.stage, --PACKING, DELIVERY, INVENTORY, RECEIVING, AFTER_RETURN
--pi.status, --REPORTED, CLOSED, null | It is no longer used (dev team)
--pi.accountable_type, --Supplier, User | It is no longer used (dev team)f
pi.incidentable_type, --PackageLineItem, InvoiceItem, LineItem, ProductLocation
pi.credited, --false, true
pi.reason,

CONCAT(COALESCE(pi.incident_type, ''), '-', COALESCE(pi.reason, '')) as reason_2,


pi.id,
pi.location_id,
pi.line_item_id,
pi.credit_note_item_id,
pi.incidentable_id,
pi.inventory_cycle_check_id,
--pi.accountable_id, --It is no longer used

/*
case 
when stg_suppliers.supplier_name in ('Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis') then 'Re-Selling'
when stg_suppliers.supplier_name in ('wish flower','ASTRA Farms') then 'Marketplace'
else 'Pre-Selling'
end as trading_model,
*/
pi.after_sold,
case 
when 
pi.stage = 'INVENTORY' and pi.incidentable_type = 'ProductLocation' and p.remaining_quantity = 0 and pi.created_at > p.updated_at then true
else false end as after_product_is_sold,

concat( "https://erp.floranow.com/line_items/", pi.line_item_id) as line_item_link,
concat( "https://erp.floranow.com/product_incidents/", pi.id) as incidents_link,
concat( "https://erp.floranow.com/products/", p.id) as products_link,






stg_users.financial_administration,
stg_users.customer,
stg_users.debtor_number,
stg_suppliers.supplier_name as supplier,
stg_suppliers.supplier_region,


li.quantity as Total_Ordered_Quantity,
pi.quantity,
--pi.accounted_quantity, --It is no longer used
--pi.valid_quantity, --It is no longer used
p.remaining_quantity,

pi.quantity * li.unit_landed_cost as value,
pi.quantity * li.unit_fob_price as fob_value,


pi.created_at,
pi.updated_at,
pi.deleted_at,

pi.note,
pi.Reported_by, 

case when pi.stage = 'PACKING' then 'pre shipment' else 'post shipment' end as phase,

li.product_name as product,
li.unit_fob_price,
li.unit_landed_cost,
li.color,
li.stem_length,
li.delivery_date,
li.currency,
li.fob_currency,
li.departure_date,



--LEAD(pi.created_at) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id,pi.created_at) as lead_created_at,
--TIMESTAMP_DIFF(LEAD(pi.created_at) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id,pi.created_at), pi.created_at,MILLISECOND) AS millisecond_difference,




--LEAD(pi.quantity) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id, pi.created_at) as lead_quantity,
--LEAD(pi.quantity) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id, pi.created_at) + pi.quantity = 0,

case when TIMESTAMP_DIFF(LEAD(pi.created_at) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id,pi.created_at), pi.created_at,MILLISECOND)<5000 then 1 else  0 end as anomalies,
case when LEAD(pi.quantity) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id, pi.created_at) + pi.quantity = 0 then 'red_step_1' else 'ok' end as step_1_check,
case when TIMESTAMP_DIFF(LEAD(pi.created_at) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id,pi.created_at), pi.created_at,MILLISECOND)<5000 then 'red_step_3' else  'ok' end as step_3_check, --seconds_between_incidents_check,
case when sum(pi.quantity) OVER(PARTITION BY pi.line_item_id) > max(li.quantity) OVER(PARTITION BY pi.line_item_id) then 'red_step_4' else 'ok' end as step_4_check,


case when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' else li.order_type end as order_type,

    sh.name as shipment,
    msh.name as master_shipment_name,
    w2.name as warehouse,

    w.country as warehouse_country,

fs.name as feed_source,

case
when w2.name = 'Dammam Warehouse' then 'FN-Dammam'
when w2.name = 'Dubai Warehouse' then 'DXB'
when w2.name = 'Jeddah Warehouse' then 'FN-Jeddah'
when w2.name = 'Riyadh Warehouse' then 'FN-Riyadh'
when w2.name = 'Tabuk Warehouse' then 'FN-Tabuk'
when w2.name = 'Hail Warehouse' then 'FN-Hail'
when w2.name = 'Qassim Warehouse' then 'FN-Qassim'
when w2.name = 'Medina Warehouse' then 'FN-Medinah'
when w2.name = 'Jouf WareHouse' then 'FN-Jouf'
when w2.name = 'Hafar WareHouse' then 'FN-Hafar'
when w2.name = 'Kuwait Warehouse' then 'KWT-Design Cell'
else null end as box_label,




case 
when pi.stage = 'INVENTORY' and pi.incident_type = 'DAMAGED' and w.name is null then 'damage from order' 
when pi.stage = 'INVENTORY' and pi.incident_type = 'DAMAGED' and w.name is not null then 'damage from inventory' 
else null 
end as damage_type,




stock_id,
stock.name as stock,
reseller.name as reseller,
concat(stock.id, " - ", reseller.name , " - ", stock.name ) as full_stock_name, --stock_id

case 
when stock.id in (12,13) then 'Internal - Jumeriah'
when stock.id in (10,11,618,619) then 'Internal - Spinnyes'
when stock.id in (16,17) then 'Internal - TBF'
when stock.id in (15) then 'Commission Based - Wish Flowers'
when stock.id in (304,305) then 'Commission Based - Ward'
when stock.id in (128,129,18,19,22,23,266,267,486,526,529,565,90,91,527,564) then 'Commission Based - Astra Express'
when stock.id in (165,64,569,451,450,415,414,571,570,408,411,410,572,407,406,413,412,416,417,164,165,568,573) then  case  when stg_suppliers.supplier_name = 'ASTRA Farms' then 'Commission Based - Astra Express' else 'Reselling Event' end 
when stock.id in (613,614,615,606,607,608) then 'Internal - BX Shop'
when stock.id in (616,617) then 'Internal - Wedding & Events'
when stock.id in (621,620) then 'Internal - BX DMM'
when stock.id in (522,484,567,566,531,530,523,485,373,372,301,300,199,198,131,130,127,126,57,56,21,20,7,6,2,1) then  case  when stg_suppliers.supplier_name = 'ASTRA Farms' then 'Commission Based - Astra Express' else 'Reselling' end 
when stock.id in (622,623) then 'Internal - Grandiose'
     
else 'Others'
end as stock_model_details,

case 
when stock.id in (12,13) then 'Internal'
when stock.id in (10,11,618,619) then 'Internal'
when stock.id in (16,17) then 'Internal'
when stock.id in (15) then 'Commission Based'
when stock.id in (304,305) then 'Commission Based'
when stock.id in (128,129,18,19,22,23,266,267,486,526,529,565,90,91,527,564) then 'Commission Based'
when stock.id in (165,64,569,451,450,415,414,571,570,408,411,410,572,407,406,413,412,416,417,164,165,568,573) then  case  when stg_suppliers.supplier_name = 'ASTRA Farms' then 'Commission Based' else 'Reselling' end
when stock.id in (613,614,615,606,607,608) then 'Internal'
when stock.id in (616,617) then 'Internal'
when stock.id in (621,620) then 'Internal'
when stock.id in (522,484,567,566,531,530,523,485,373,372,301,300,199,198,131,130,127,126,57,56,21,20,7,6,2,1) then  case  when stg_suppliers.supplier_name = 'ASTRA Farms' then 'Commission Based' else 'Reselling' end 
else 'Others'
end as stock_model,


li.category as item_category,
li.category2 as item_sub_category,


case 
when pi.stage != 'INVENTORY' then null
when pi.incident_type = 'DAMAGED'  then 'inventory_dmaged'
when pi.incident_type != 'DAMAGED'  then 'inventory_incidents'
--when pi.incidentable_type in ('ProductLocation','Product') and 
--when pi.incidentable_type = 'LineItem' and pi.incident_type not in ('DAMAGED') then 'inventory_incidents'
else null  
end as report_filter,

case when pi.stage in ('PACKING', 'RECEIVING') then 'supplier_incidents' else null end as  report_filter_supplier,




case when pi.incident_type = 'EXTRA' then 'extra_report' else null end  as report_filter_extra,



case 
when stg_users.financial_administration = 'Internal' then null
when pi.incident_type = 'EXTRA' then null
when pi.incidentable_type = 'ProductLocation' then null
else 'client_incidents' 
end as report_filter_client,


li.order_number,



count(*) over(partition by pi.line_item_id) as incidents_count_per_line_item,


case 
    when pi.line_item_id is not null then 'line_item_id'
    when pi.line_item_id is null then '--'
end as ch_line_item_id,

case 
    when pi.credit_note_item_id is not null then 'credit_note_item_id'
    when pi.credit_note_item_id is null then '--'
end as ch_credit_note_item_id,

case 
    when pi.location_id is not null then 'location_id'
    when pi.location_id is null then '--'
end as ch_location_id,

from `floranow.erp_prod.product_incidents` as pi 
left join `floranow.erp_prod.line_items` as li on pi.line_item_id = li.id
left join `erp_prod.products` as p on p.line_item_id = li.id 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = li.customer_id

left join `floranow.Floranow_ERP.suppliers` as stg_suppliers on stg_suppliers.id = li.supplier_id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id

left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id


left join `floranow.erp_prod.stocks` as stock on p.stock_id = stock.id  --and  st.reseller_id = p.reseller_id --added 27 sep (after and)


left join `floranow.erp_prod.warehouses` as w on w.id = stock.warehouse_id
left join `floranow.erp_prod.warehouses` as w2 on w2.id = stg_users.warehouse_id

left join floranow.erp_prod.users as reseller on reseller.id = p.reseller_id

left join `floranow.erp_prod.invoice_items` as  i on i.id = pi.credit_note_item_id



where  pi.deleted_at is null
order by pi.line_item_id, pi.created_at