create or replace view `floranow.Floranow_ERP.shipments` as 
--with dim_date as (select * from UNNEST(GENERATE_TIMESTAMP_ARRAY('2021-06-01', '2030-01-01', INTERVAL 1 Day)) as dim_date)

select
case 
    when msh.arrival_time is not null then 'arrival_time'
    when msh.arrival_time is null then '--'
end as ch_arrival_time,


case 
    when sh.total_received_quantity > 0 then 'total_received_quantity'
    when sh.total_received_quantity = 0 then '--'
end as ch_total_received_quantity,

case 
    when sh.total_missing_quantity > 0 then 'total_missing_quantity'
    when sh.total_missing_quantity = 0 then '--'
end as ch_total_missing_quantity,

case 
    when sh.total_damaged_quantity > 0 then 'total_damaged_quantity'
    when sh.total_damaged_quantity = 0 then '--'
end as ch_total_damaged_quantity,

sh.is_local,
sh.id,
sh.name as shipment_name,
sh.departure_date,
sh.received_at,
sh.created_at,
sh.status as shipments_status,
sh.fulfillment,
sh.number,
sh.total_quantity,
sh.total_received_quantity,
sh.total_missing_quantity,
sh.total_damaged_quantity,
sh.shipping_boxes_count,
sh.warehousing_boxes_count,
sh.total_fob,
sh.total_received_fob,
sh.total_missing_fob,
sh.total_damaged_fob,
sh.invoice_amount,
sh.proforma_amount,
sh.customer_type,
sh.receiving_way,
sh.previous_masters,
sh.packing_type,


msh.id as master_shipment_id,
msh.status as master_shipments_status,
msh.name as master_shipment_name,
--msh.destination, not work
msh.arrival_time,
msh.fulfillment as msh_fulfillment,
msh.customer_type as msh_customer_type,
msh.origin,
--msh.clearance_cost,
--msh.freight_cost,
--msh.clearance_currency,
msh.order_sequence,
msh.customer_id, --when the shipmnet from bulk
msh.warehouse_id,

case when msh.customer_id is not null then 'Bulk shipments' else null end as shipment_type,


concat( "https://erp.floranow.com/master_shipments/", msh.id) as master_shipment_link,
concat( "https://erp.floranow.com/shipments/", sh.id) as shipment_link,

shipments_suppliers.supplier_name,
shipments_suppliers.supplier_region,


w.name as warehouse,
w.country as warehouse_country,
case when msh.arrival_time is not null then 1 else 0 end as shipments_received,

case 
when msh.arrival_time is null  then 'shipmnet_not_arrived'
else 'shipmnet_arrived'
end as shipmnet_arrival,


case 
    when date_diff(date(msh.arrival_time)  ,current_date(), month) > 1 then 'Wrong date' 
        when date(msh.arrival_time) = current_date()+1 then "Tomorrow" 

    when date(msh.arrival_time) > current_date() then "Future" 
    when date(msh.arrival_time) = current_date()-1 then "Yesterday" 
    when date(msh.arrival_time) = current_date() then "Today" 
    when date_diff(cast(current_date() as date ),cast(msh.arrival_time as date), MONTH) = 0 then 'Month To Date'
    when date_diff(cast(current_date() as date ),cast(msh.arrival_time as date), MONTH) = 1 then 'Last Month'
    when date_diff(cast(current_date() as date ),cast(msh.arrival_time as date), YEAR) = 0 then 'Year To Date'
    else "Past" end as select_arrival_time,
case 
    when date_diff(date(sh.departure_date)  ,current_date(), month) > 1 then 'Wrong date' 
    when date(sh.departure_date) = current_date()+1 then "Tomorrow" 
    when date(sh.departure_date) > current_date() then "Future" 
    when date(sh.departure_date) = current_date()-1 then "Yesterday" 
    when date(sh.departure_date) = current_date() then "Today" 
    when date_diff(cast(current_date() as date ),cast(sh.departure_date as date), MONTH) = 0 then 'Month To Date'
    when date_diff(cast(current_date() as date ),cast(sh.departure_date as date), MONTH) = 1 then 'Last Month'
    when date_diff(cast(current_date() as date ),cast(sh.departure_date as date), YEAR) = 0 then 'Year To Date'
    else "Past" end as select_departure_date,


from `floranow.erp_prod.shipments` as sh
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id
left join `floranow.erp_prod.warehouses` as w on msh.warehouse_id = w.id

left join `floranow.Floranow_ERP.suppliers` as shipments_suppliers on shipments_suppliers.id = sh.supplier_id


--left join dim_date on date(dim_date.dim_date)=date(sh.created_at)


--left join `floranow.erp_prod.line_items` as li on li.shipment_id = sh.id