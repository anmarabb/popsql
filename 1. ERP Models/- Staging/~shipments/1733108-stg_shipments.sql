create or replace view `floranow.Floranow_ERP.stg_shipments` as

select
msh.id,
sum(sh.total_quantity) as calc_total_quantity,
count (distinct sh.id) as shipments_count,


from `floranow.erp_prod.shipments` as sh
left join  `floranow.erp_prod.master_shipments` as msh on sh.master_shipment_id = msh.id
left join `floranow.erp_prod.warehouses` as w on msh.warehouse_id = w.id


group by msh.id