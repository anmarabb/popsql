create or replace view `floranow.Floranow_ERP.master_shipments` as 



with

prep_shipment as (select master_shipment_id , sum(shipping_boxes_count) as shipping_boxes_count,sum(warehousing_boxes_count) as warehousing_boxes_count  from `floranow.erp_prod.shipments` group by master_shipment_id),

prep_packing as (select count(*) as number_of_packages,s2.master_shipment_id from `floranow.erp_prod.packages` 
left join `floranow.erp_prod.shipments` as s2 on s2.id = `floranow.erp_prod.packages`.shipment_id
where (`floranow.erp_prod.packages`.fulfillment <> 'FAILED' and `floranow.erp_prod.packages`.status <> 'INSPECTED') 
and `floranow.erp_prod.packages`.__hevo__marked_deleted is false group by s2.master_shipment_id )


select 

concat( "https://erp.floranow.com/master_shipments/", msh.id) as link,



msh.id,
msh.name as master_shipment_name,

msh.departure_date,

msh.status as master_shipments_status,
w.name as warehouse,
u.name as customer,
u.debtor_number,
msh.total_fob,
msh.total_quantity,
msh.customer_type,

p.number_of_packages as packing_boxes_count,
sh.shipping_boxes_count,
sh.warehousing_boxes_count,
msh.note,

stg_shipments.calc_total_quantity,
stg_shipments.shipments_count as farms,

msh.total_quantity - stg_shipments.calc_total_quantity as gab_quantity,

msh.arrival_time,

from `floranow.erp_prod.master_shipments` as msh
left join `floranow.erp_prod.warehouses` as w on msh.warehouse_id = w.id
left join `floranow.erp_prod.users` as u on msh.customer_id = u.id 
left join prep_shipment as sh on sh.master_shipment_id = msh.id
left join prep_packing as p on msh.id = p.master_shipment_id



left join `floranow.Floranow_ERP.stg_shipments` as stg_shipments on stg_shipments.id = msh.id
--left join `floranow.erp_prod.shipments` as s2 on msh.id = s2.master_shipment_id
--left join prep_packing as p on s2.id = p.shipment_id

--where msh.id = 441