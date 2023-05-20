create or replace table `floranow.Floranow_ERP.line_items` as 

with 
prep_registered_clients as (select financial_administration,count(*) as registered_clients from `floranow.Floranow_ERP.users` where account_type in ('External') group by financial_administration),   
prep_product_locations as (select  pl.locationable_id, max(pl.id) as id from `floranow.erp_prod.product_locations` as pl group by 1),
prep_picking_products as (select  pk.line_item_id, max(pk.id) as id from `floranow.erp_prod.picking_products` as pk group by 1)

SELECT

case when li.parent_line_item_id is not null then parent_li.unit_fob_price else li.unit_fob_price end as unit_fob_price_2,
case when li.parent_line_item_id is not null then parent_li.fob_currency else li.fob_currency end as fob_currency_2,

case when stg_users.debtor_number in ('WANDE','95110') then 'manual_invoices' else 'normal' end as order_segemnt,


parent_li.unit_fob_price as root_unit_fob_price,
parent_li.fob_currency as root_fob_currency,


li.order_request_id,
li.supplier_product_id,
li.offer_id,
li.id,
li.unit_fob_price,
li.fob_currency,
li.ordering_pattern,
li.location,
li.fulfillment,
li.stem_length,
li.color,
li.pn.p1 as spec_1,
li.pn.p2 as spec_2,
li.pn.p3 as spec_3,
li.pn.p4 as spec_4,
li.Properties,
li.categorization,
li.sales_unit,
li.creation_stage,
li.source_line_item_id, 
li.parent_line_item_id,
li.pricing_type,
li.order_id,
li.proof_of_delivery_id,

li.state,
li.tags,
li.unit_landed_cost,
li.landed_currency,
li.unit_price,
li.currency,
li.total_price_without_tax,
li.product_name as product,
li.order_number,
li.order_type as row_order_type,

--date
    li.departure_date,
    li.delivery_date as row_delivery_date,
    li.created_at,

li.inventory_quantity,
li.missing_quantity,
li.damaged_quantity,
li.delivered_quantity,
li.extra_quantity,
li.returned_quantity,
li.canceled_quantity,
li.picked_quantity,

li.picked_from,


---------- Start First Level Custom Metrics --------------
case when li.received_quantity > 0 then 1 else 0 end as order_received,
case when li.fulfilled_quantity > 0 then 1 else 0 end as order_fulfilled,
case when li.location = 'loc' then 1 else 0 end as order_loc_moved,
case when li.location = 'pod' then 1 else 0 end as order_pod_moved,
case when li.picked_quantity > 0 then 1 else 0 end as order_picked,

case when li.dispatched_at is not null then 1 else 0 end as order_dispatched,
case when li.state = 'DELIVERED' then 1 else 0 end as order_delivered,
case when li.invoice_id is not null then 1 else 0 end as invoice_created,
case when li.invoice_id is not null and i.printed_at is not null then 1 else 0 end as invoice_printed,


concat( "https://erp.floranow.com/line_items/", li.id) as line_item_link,
concat( "https://erp.floranow.com/order_requests/", li.order_request_id) as order_request_link,

case  --generate new delivery date as some manual input to system intr without delivery date
when li.delivery_date is null and li.order_type in ('IMPORT_INVENTORY', 'EXTRA','MOVEMENT') then date(li.created_at) else li.delivery_date end as delivery_date,

li.quantity*li.unit_fob_price as potential_fob_revenue,
li.fulfilled_quantity*li.unit_fob_price as fulfilled_fob_revenue,
(li.quantity*li.unit_fob_price) - (li.fulfilled_quantity*li.unit_fob_price) as fob_missed_revenue,
case when li.id is not null then li.total_price_without_tax else 0 end as potential_revenue,
case when li.id is not null then li.fulfilled_quantity * li.unit_price else 0 end as fulfilled_revenue,
case when li.invoice_id is not null and i.printed_at is not null then li.fulfilled_quantity * li.unit_price else 0 end as invoiced_revenue,
case when li.invoice_id is not null and i.printed_at is null then li.fulfilled_quantity * li.unit_price else 0 end as Proforma_revenue,

li.quantity * li.unit_landed_cost as potential_cost,
li.fulfilled_quantity * li.unit_landed_cost as fulfilled_cost,
li.total_price_without_tax - li.quantity * li.unit_landed_cost as potential_profit,
li.fulfilled_quantity * li.unit_price - li.fulfilled_quantity * li.unit_landed_cost as actual_profit,


case when EXTRACT(HOUR FROM li.created_at) in (1,2,3,4,5,6) then "5_to_10_time_slote" else "otheres" end as time_slot,
case when li.supplier_id IN (109,71) then li.total_price_without_tax else 0 end as express_sales,

---------- End First Level Custom Metrics --------------


--by
    dispatched_by.name as dispatched_by,
    returned_by.name as returned_by,
    created_by.name as created_by,
    split_by.name as split_by,
    order_requested_by.name as order_requested_by,






---User table

case 
    when stg_users.customer_type = 'reseller' then 'Resale Trading'
    when stg_users.customer_type = 'cif' then 'Bulk Trading'
    when stg_users.customer_type = 'fob' then 'Bulk Trading'
    when stg_users.customer_type = 'retail' then 'Traditional Trading'
    else 'check_my_logic'
end as trading_model,

    stg_users.customer,
    stg_users.client_category,
    stg_users.customer_type,
    stg_users.payment_term,
    stg_users.financial_administration,



---shipments table
    sh.name as shipment,
    msh.name as master_shipment_name,
    



--proof of delivery table
    case when li.proof_of_delivery_id is not null then 'POD' else 'null' end as proof_of_delivery,
    pod.status as pod_status,


    pod.source_type as pod_source_type,


--quantity
    li.quantity,  --conformed_quantity from supplier
    li.fulfilled_quantity, --received and valied excluding extra --- minace extra
    li.received_quantity, --received and valied including extra, 
li.quantity - li.fulfilled_quantity as gap_quantity,

    li.quantity as li_quantity,
    p.quantity as p_quantity,




   


--line items custom metrics
  
    case 
    when date_diff(date(li.delivery_date)  ,current_date(), month) > 1 then 'Wrong date' 
    when li.delivery_date > current_date() then "Future" 
    when li.delivery_date = current_date()-1 then "Yesterday" 
    when li.delivery_date = current_date() then "Today" 
    when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 0 then 'Month To Date'
    when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), MONTH) = 1 then 'Last Month'
    when date_diff(cast(current_date() as date ),cast(li.delivery_date as date), YEAR) = 0 then 'Year To Date'

    else "Past" end as future_delivery_date,

    case 
    when date_diff(date(li.departure_date)  ,current_date(), month) > 1 then 'Wrong date' 
    when li.departure_date = current_date() then "Today" 
    when li.departure_date > current_date() then "Future" 
    when li.departure_date < current_date() then "Past" 

    else "check my logic" end as departure_timing,

    




--  order requests table
case when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' else li.order_type end as order_type,


--stg_users
    stg_users.city,
    stg_users.account_manager,
    stg_users.country,
    stg_users.reseller,
    stg_users.retail,
    stg_users.debtor_number,
 

--invoice table.
 date(i.printed_at) as printed_at,
    case when date_diff(cast (li.delivery_date as date) ,cast(i.printed_at as date), MONTH) = 0 then 'ok' else 'moved_to_next_month_invoice' end as financal_month,
    case when date(i.printed_at) > li.delivery_date then "late_delivery" else "ontime_delivery" end as late_or_ontime_delivery,
    CASE WHEN date(i.printed_at) > li.delivery_date then 'late_delivery' else 'on_time_delivery' End as otd_check,

  



prep_registered_clients.registered_clients,

/*
client_orders_from_express
client_orders_from_marketplace
resllers_orders_from_marketplace
resllers_orders_from_express

case 
    when u.customer_type = 0 then 'reseller'
    when u.customer_type = 1 then 'retail'
    when u.customer_type = 2 then 'fob'
    when u.customer_type = 3 then 'cif'
    else 'check_my_logic'
    end as customer_type,

*/

--ordering source type (external, flying ,envetry)

concat(stg_users.debtor_number,li.delivery_date) as drop_id, 


case 
when li_suppliers.supplier_name = 'ASTRA Farms' then 'Astra'
when li_suppliers.supplier_name = 'Fulfilled by Floranow SA' and li_fs.name in ('Express Jeddah','Express Dammam','Express Riyadh','Express Tabuk')  then 'Astra'
else 'Non Astra'
end as sales_source,


li.category as item_category,
li.category2 as item_sub_category,

stock.name as stock_name,

case when w.name is not null then w.name  end as warehouse,
 w.country as warehouse_country,




case
    when li.order_type in ('ADDITIONAL') and msh.name is null  then 'ADDITIONAL Not from shipment'
    when li.order_type in ('EXTRA') and msh.name is null  then 'EXTRA Not from shipment'
    when li.order_type in ('IMPORT_INVENTORY') then 'IMPORT_INVENTORY'
    when li.order_type in ('RETURN') then 'RETURN'
    when li.ordering_stock_type is null and li.state not in ('CANCELED') and li.order_type not in ('IMPORT_INVENTORY','RETURN')  then 'Vendor Performance Report'
    else 'check_my_logic'
 end as report_filter,


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



case
    when li.parent_line_item_id is not null then null
    when li.ordering_stock_type is not null then null
    when li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is not null and li.order_type in ('IMPORT_INVENTORY') then 're-selling path (IMPORT_INVENTORY)'
    when li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is null then 'pre-selling path'
    when li.parent_line_item_id is null and li.ordering_stock_type is null and li.reseller_id is not null then 're-selling path'

    else 'check_my_logic'
 end as report_filter_vendor,


case
    when li.parent_line_item_id is null then null
    when li.ordering_stock_type is null then null
    when li.parent_line_item_id is not null and li.ordering_stock_type is not null and li.reseller_id is not null then 'reseller from stock'
    when li.parent_line_item_id is not null and li.ordering_stock_type is not null and li.reseller_id is null then 'client from stock'
    else 'check_my_logic'
 end as report_filter_stock,

li.ordering_stock_type,

case
when li.order_type in ('EXTRA') and li.creation_stage in ('INVENTORY') and msh.name is not null then 'EXTRA_SHIPMENT_INVENTORY'
when li.order_type in ('EXTRA') and li.creation_stage in ('PACKING') and msh.name is not null then 'EXTRA_SHIPMENT_PACKING'
when li.order_type in ('EXTRA') and li.creation_stage in ('INVENTORY') and msh.name is  null then 'EXTRA_IMPORT_INVENTORY'
when li.order_type in ('EXTRA') and li.creation_stage in ('PACKING') and msh.name is  null then 'EXTRA_IMPORT_PACKING'
 else 'NOT_EXTRA'
 end as Extra_type,


li.packaging,






case 
when li.ordering_stock_type = 'INVENTORY' and li.parent_line_item_id is not null then 'INVENTORY'
when li.ordering_stock_type = 'FLYING' and li.parent_line_item_id is not null then 'FLYING'
when li.ordering_stock_type in ('INVENTORY','FLYING') and li.parent_line_item_id is null then 'problem'
when li.ordering_stock_type is null and li.parent_line_item_id is null then null
end as calc_ordering_stock_type,





li_suppliers.account_manager as supplier_account_manager,
li_suppliers.supplier_region,
li_suppliers.supplier_type,



li_suppliers.supplier_name,
li_fs.name as feed_source,


p_suppliers.supplier_name as p_supplier,
p_fs.name as p_feed_source,
p_origin_fs.name as p_origin_feed_source,

--parent
parent_li_suppliers.supplier_name as parent_li_supplier,
parent_li_fs.name as parent_li_feed_source,

p_parent_li_suppliers.supplier_name as p_parent_li_supplier,
p_parent_li_fs.name as p_parent_li_feed_source,
p_parent_li_origin_fs.name as p_parent_li_origin_feed_source,

case 
when p_suppliers.supplier_name = li_suppliers.supplier_name then 'Same supplier' 
when p_suppliers.supplier_name != li_suppliers.supplier_name then 'Transformed supplier' 
end as supplier_transform,




parent_li.order_type as parent_li_order_type,


    case when li.parent_line_item_id is null then null else 'have_parent_line_item_id' end as parent_line_item_id_cheack,
    case when li.ordering_stock_type is null then null else 'Inventory_order' end as ordering_stock_type_cheack,
    case when li.invoice_id is null then null else 'have_invoice_id' end as invoice_id_cheack,
    case when p.line_item_id is null then null else  'have_product_id' end as product_id_cheack,

    case when li.source_line_item_id is null then null else 'have_source_line_item_id' end as source_line_item_id_cheack,

    case when li.shipment_id is null then null else 'have_shipment_id' end as shipment_id_cheack,
    case when li.root_shipment_id is null then null else 'have_root_shipment_id' end as root_shipment_id_cheack,
    case when li.source_shipment_id is null then null else 'have_source_shipment_id' end as source_shipment_id_cheack,







users.name as user,




prep_ploc.id as product_locations_id,
sh.status as shipments_status,

prep_picking_products.id as picking_products_id,



  case 
        when li.invoice_id is not null and i.printed_at is not null then 'Invoice Printed' 
        when li.invoice_id is not null and i.printed_at is null then 'Invoice Created, Not Printed'
        else 'No Invoice ID' 
    end as invoice_status,

    case 
        when i.payment_status = 0 then "Not Paid" 
        when i.payment_status = 1 then "partially_paid " 
        when i.payment_status = 2 then "Not Paid" 
        else 'Not invoiced' 
    End as payment_status,


concat( "https://erp.floranow.com/invoice_items/", ii.id) as invoice_items_link,
i.generation_type,
ii.status as line_invoice_status,

case when ii2.id is not null then 'credit note' else 'invoice' end as invoice_type,


pi.incidents_count,
case when pi.incidents_count is not null then 'incident' else null end as ch_incidents,


concat(stock.id, " - ", li.reseller_id , " - ", stock.name ) as full_stock_name,

concat( "https://erp.floranow.com/products/", p.id) as product_link,


case 
    when p.deleted_at is not null then 'p.deleted_at'
    when p.deleted_at is null then '--'
end as ch_product_deleted_at,



case when ad.id is not null then 'additional_items' else null end as ch_additional_items,




case 
when li_suppliers.supplier_name in ('wish flower','ASTRA Farms','Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis')
and date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) in (0,1) then 'Express'
else 'Regular'
end as delivery_method,

case when li.supplier_id IN (109,71) then 'Express' when li.supplier_id is null then "Check My Logic" else 'NonExpress' end as order_mode,

    case 
        when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) = 0 then 'Same day express'
        when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) = 1 then 'Next day express delivery'
        when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) > 1 then 'Regular delivery'
        else 'check my logic'
    end as delivery_type,


---------------------------- test area ------------------------

case 
    when p.id is not null then 'product_id'
    when p.id is null then '--'
end as ch_product_id,




case 
    when li.published_canceled_quantity > 0 then 'published_canceled_quantity'
    when li.published_canceled_quantity = 0 then '--'
end as ch_published_canceled_quantity,

case 
    when li.missing_quantity > 0 then 'missing_quantity'
    when li.missing_quantity = 0 then '--'
end as ch_missing_quantity,


case 
    when li.delivered_quantity > 0 then 'delivered_quantity'
    when li.delivered_quantity = 0 then '--'
end as ch_delivered_quantity,



case 
    when li.damaged_quantity > 0 then 'damaged_quantity'
    when li.damaged_quantity = 0 then '--'
end as ch_damaged_quantity,

case 
    when li.extra_quantity > 0 then 'extra_quantity'
    when li.extra_quantity = 0 then '--'
end as ch_extra_quantity,

case 
    when li.replaced_quantity > 0 then 'replaced_quantity'
    when li.replaced_quantity = 0 then '--'
end as ch_replaced_quantity,
case 
    when li.splitted_quantity > 0 then 'splitted_quantity'
    when li.splitted_quantity = 0 then '--'
end as ch_splitted_quantity,
case 
    when li.returned_quantity > 0 then 'returned_quantity'
    when li.returned_quantity = 0 then '--'
end as ch_returned_quantity,


case 
    when li.quantity > 0 then 'quantity'
    when li.quantity = 0 then '--'
end as ch_quantity,


case 
    when li.received_quantity > 0 then 'received_quantity'
    when li.received_quantity = 0 then '--'
end as ch_received_quantity,


case 
    when li.fulfilled_quantity > 0 then 'fulfilled_quantity'
    when li.fulfilled_quantity = 0 then '--'
end as ch_fulfilled_quantity,



case 
    when li.picked_quantity > 0 then 'picked_quantity'
    when li.picked_quantity = 0 then '--'
end as ch_picked_quantity,


case 
    when li.warehoused_quantity > 0 then 'inventory_quantity'
    when li.warehoused_quantity = 0 then '--'
end as ch_warehoused_quantity,

case 
    when li.inventory_quantity > 0 then 'inventory_quantity'
    when li.inventory_quantity = 0 then '--'
end as ch_inventory_quantity,




    
case 
    when i.printed_at is not null then 'printed_at'
    when i.printed_at is null then '--'
end as ch_printed_at,

case 
    when prep_picking_products.id is not null then 'picking_products_id'
    when prep_picking_products.id is null then '--'
end as ch_picking_products,


case 
    when prep_ploc.id is not null then 'product_locations_id'
    when prep_ploc.id is null then '--'
end as ch_product_locations_id,



case 
    when li.previous_shipments is not null then 'previous_shipments'
    when li.previous_shipments is null then '--'
end as ch_previous_shipments,

case 
    when li.previous_split_proof_of_deliveries is not null then 'previous_split_proof_of_deliveries'
    when li.previous_split_proof_of_deliveries is null then '--'
end as ch_previous_split_proof_of_deliveries,



case 
    when li.previous_moved_proof_of_deliveries is not null then 'previous_moved_proof_of_deliveries'
    when li.previous_moved_proof_of_deliveries is null then '--'
end as ch_previous_moved_proof_of_deliveries,

case 
    when li.barcode is not null then 'barcode'
    when li.barcode is null then '--'
end as ch_barcode,

case 
    when li.product_mask is not null then 'product_mask'
    when li.product_mask is null then '--'
end as ch_product_mask,

case 
    when li.variety_mask is not null then 'variety_mask'
    when li.variety_mask is null then '--'
end as ch_variety_mask,

case 
    when li.number is not null then 'number'
    when li.number is null then '--'
end as ch_number,

case 
    when li.sequence_number is not null then 'sequence_number'
    when li.sequence_number is null then '--'
end as ch_sequence_number,

case 
    when li.id is not null then 'line_item_id'
    when li.id is null then '--'
end as ch_line_item_id,

case 
    when li.source_line_item_id is not null then 'source_line_item_id'
    when li.source_line_item_id is null then '--'
end as ch_source_line_item_id,

case 
    when li.parent_line_item_id is not null then 'parent_line_item_id'
    when li.parent_line_item_id is null then '--'
end as ch_parent_line_item_id,


case 
    when li.proof_of_delivery_id is not null then 'proof_of_delivery_id'
    when li.proof_of_delivery_id is null then '--'
end as ch_proof_of_delivery_id,

case 
    when li.invoice_id is not null then 'invoice_id'
    when li.invoice_id is null then '--'
end as ch_invoice_id,

case 
    when li.source_invoice_id is not null then 'source_invoice_id'
    when li.source_invoice_id is null then '--'
end as ch_source_invoice_id,

case 
    when li.order_payload_id is not null then 'order_payload_id'
    when li.order_payload_id is null then '--'
end as ch_order_payload_id,


case 
    when li.order_request_id is not null then 'order_request_id'
    when li.order_request_id is null then '--'
end as ch_order_request_id,

case 
    when li.supplier_product_id is not null then 'supplier_product_id'
    when li.supplier_product_id is null then '--'
end as ch_supplier_product_id,



case 
    when li.dispatched_by_id is not null then 'dispatched_by_id'
    when li.dispatched_by_id is null then '--'
end as ch_dispatched_by_id,



case 
    when li.canceled_by_id is not null then 'canceled_by_id'
    when li.canceled_by_id is null then '--'
end as ch_canceled_by_id,

case 
    when li.returned_by_id is not null then 'returned_by_id'
    when li.returned_by_id is null then '--'
end as ch_returned_by_id,

case 
    when li.split_by_id is not null then 'split_by_id'
    when li.split_by_id is null then '--'
end as ch_split_by_id,

case 
    when li.supplier_id is not null then 'supplier_id'
    when li.supplier_id is null then '--'
end as ch_supplier_id,

case 
    when li.created_by_id is not null then 'created_by_id'
    when li.created_by_id is null then '--'
end as ch_created_by_id,


case 
    when li.reseller_id is not null then 'reseller_id'
    when li.reseller_id is null then '--'
end as ch_reseller_id,

case 
    when li.user_id is not null then 'user_id'
    when li.user_id is null then '--'
end as ch_user_id,

case 
    when li.customer_id is not null then 'customer_id'
    when li.customer_id is null then '--'
end as ch_customer_id,

case 
    when li.customer_master_id is not null then 'customer_master_id'
    when li.customer_master_id is null then '--'
end as ch_customer_master_id,

case 
    when li.feed_source_id is not null then 'feed_source_id'
    when li.feed_source_id is null then '--'
end as ch_feed_source_id,



case 
    when li.replace_for_id is not null then 'replace_for_id'
    when li.replace_for_id is null then '--'
end as ch_replace_for_id,

case 
    when li.split_source_id is not null then 'split_source_id'
    when li.split_source_id is null then '--'
end as ch_split_source_id,


case 
    when li.source_shipment_id is not null then 'source_shipment_id'
    when li.source_shipment_id is null then '--'
end as ch_source_shipment_id,

case 
    when li.shipment_id is not null then 'shipment_id'
    when li.shipment_id is null then '--'
end as ch_shipment_id,

case 
    when li.root_shipment_id is not null then 'root_shipment_id'
    when li.root_shipment_id is null then '--'
end as ch_root_shipment_id,


case 
    when li.offer_id is not null then 'offer_id'
    when li.offer_id is null then '--'
end as ch_offer_id,






case 
    when li.order_id is not null then 'order_id'
    when li.order_id is null then '--'
end as ch_order_id,

case 
    when li.order_number is not null then 'order_number'
    when li.order_number is null then '--'
end as ch_order_number,




case 
    when li.returned_at is not null then 'returned_at' else '--' 
end as ch_returned_at,

case 
    when li.dispatched_at is not null then 'dispatched_at' else '--' 
end as ch_dispatched_at,

case 
    when li.delivered_at is not null then 'delivered_at' else '--' 
end as ch_delivered_at,

case 
    when li.canceled_at is not null then 'canceled_at' else '--' 
end as ch_canceled_at,

case 
    when li.split_at is not null then 'split_at' else '--' 
end as ch_split_at,

case 
    when li.deleted_at is not null then 'deleted_at' else '--' 
end as ch_deleted_at,

case 
    when li.delivery_date is not null then 'delivery_date' else '--' 
end as ch_delivery_date,

case 
    when li.departure_date is not null then 'departure_date' else '--' 
end as ch_departure_date,

case 
    when li.completed_at is not null then 'completed_at' else '--' 
end as ch_completed_at,

case 
    when li.created_at is not null then 'created_at' else '--' 
end as ch_created_at,

case 
    when li.updated_at is not null then 'updated_at' else '--' 
end as ch_updated_at,


------------------------------end test area --------------------------------------

ii.id as invoice_item_id,

from `floranow.erp_prod.line_items` as li
--fetsh data from (line_items)
    left join `floranow.Floranow_ERP.suppliers` as li_suppliers on li_suppliers.id = li.supplier_id
    left join `floranow.erp_prod.feed_sources` as li_fs on li.feed_source_id = li_fs.id

--fetsh data from (parent line_items)
    left join  `floranow.erp_prod.line_items` as parent_li on parent_li.id = li.parent_line_item_id
    left join `floranow.Floranow_ERP.suppliers` as parent_li_suppliers on parent_li_suppliers.id = parent_li.supplier_id
    left join `floranow.erp_prod.feed_sources` as parent_li_fs on parent_li.feed_source_id = parent_li_fs.id

--fetsh data from (products)

    left join floranow.erp_prod.products as p on p.line_item_id = li.id 

    left join `floranow.Floranow_ERP.suppliers` as p_suppliers on p_suppliers.id = p.supplier_id
    left join `floranow.erp_prod.feed_sources` as p_fs on p_fs.id = p.feed_source_id
    left join `floranow.erp_prod.feed_sources` as p_origin_fs on p_origin_fs.id = p.origin_feed_source_id 


   -- left join floranow.erp_prod.products as p_parent_li on p_parent_li.line_item_id = li.parent_line_item_id
    left join floranow.erp_prod.products as p_parent_li on p_parent_li.line_item_id = parent_li.id
    left join `floranow.Floranow_ERP.suppliers` as p_parent_li_suppliers on p_parent_li_suppliers.id = p_parent_li.supplier_id
   left join `floranow.erp_prod.feed_sources` as p_parent_li_fs on p_parent_li_fs.id = p_parent_li.feed_source_id
    left join `floranow.erp_prod.feed_sources` as p_parent_li_origin_fs on p_parent_li_origin_fs.id = p_parent_li.origin_feed_source_id 



left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = li.customer_id

left join `floranow.erp_prod.users` as dispatched_by on dispatched_by.id = li.dispatched_by_id
left join `floranow.erp_prod.users` as returned_by on returned_by.id = li.returned_by_id
left join `floranow.erp_prod.users` as created_by on created_by.id = li.created_by_id
left join `floranow.erp_prod.users` as split_by on split_by.id = li.split_by_id




left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id = pod.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id
left join `floranow.erp_prod.invoices` as i on li.invoice_id = i.id

left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join `floranow.erp_prod.users` as order_requested_by on order_requested_by.id = orr.created_by_id



left join prep_registered_clients as prep_registered_clients on prep_registered_clients.financial_administration = stg_users.financial_administration

left join `floranow.erp_prod.stocks` as stock on p.stock_id = stock.id 
left join `floranow.erp_prod.warehouses` as w on w.id = stg_users.warehouse_id



left join `floranow.erp_prod.packages` as packages on packages.shipment_id = sh.id and packages.sub_master_shipment_id = msh.id
left join `floranow.erp_prod.package_line_items` as packages_li on packages_li.line_item_id  = li.id  and packages_li.package_id = packages.id
left join `floranow.erp_prod.packing_box_items` as packbox on packbox.shipment_id = sh.id and packbox.line_item_number =li.number and packbox.package_number = packages.number
left join `floranow.erp_prod.packing_lists` as packlist on packlist.shipment_id = sh.id and packlist.supplier_id = li.supplier_id and packlist.departure_date = li.departure_date

left join floranow.erp_prod.users as users on users.id = li.user_id
left join `floranow.erp_prod.additional_items_reports` as ad on ad.line_item_id=li.id
left join `floranow.erp_prod.invoice_items` as ii on ii.line_item_id=li.id and ii.invoice_type =0
left join `floranow.erp_prod.invoice_items` as ii2 on ii2.line_item_id=li.id and ii.invoice_type =1
left join `floranow.Floranow_ERP.product_incidents_stg1` as pi on pi.line_item_id = li.id



left join prep_product_locations as prep_ploc on prep_ploc.locationable_id = p.id 
left join prep_picking_products as prep_picking_products on prep_picking_products.line_item_id = li.id




--where li.ordering_stock_type is null
--stg_users.client_category = 'Internal-UAE'
--stg_users.customer_type = 'reseller'
--where stg_users.financial_administration = 'Internal'
--where stg_users.payment_term = 'Without invoicing'





--product_incidents.line_item_id as incident, 
--prep_product_incidents as (select line_item_id, count(*) as incidents_count, sum(case when  pi.stage in('PACKING','RECEIVING') then pi.quantity else 0 end) as extra_quantity, from `floranow.erp_prod.product_incidents` as pi group by line_item_id  having extra_quantity<0 ),
--abs(product_incidents.extra_quantity) as calc_extra_quantity, --Abi
--product_incidents.extra_quantity + li.fulfilled_quantity as  valid_received_quantity, calculate it in datastudio.
--left join prep_product_incidents AS product_incidents ON product_incidents.line_item_id = li.id