--create or replace view `floranow.Floranow_ERP.stg_PACKING` as

select 
pi.line_item_id,
pi.stage,

sum(case when pi.incident_type = 'MISSING' then pi.quantity else 0 end) as PACKING_missing_quantity,
sum(case when pi.incident_type = 'EXTRA' then pi.quantity else 0 end) as PACKING_extra_quantity,



from `floranow.erp_prod.product_incidents` as pi 
left join `floranow.erp_prod.line_items` as li on pi.line_item_id = li.id

where  pi.deleted_at is null and pi.stage = 'PACKING'

group by pi.line_item_id, pi.stage,pi.incidentable_type, pi.incident_type;

select 
concat(pi.line_item_id,pi.stage),
sum(pi.quantity),
sum(case when pi.incident_type = 'MISSING' then pi.quantity else 0 end) as PACKING_missing_quantity,
sum(case when pi.incident_type = 'EXTRA' then pi.quantity else 0 end) as PACKING_extra_quantity,

from `floranow.erp_prod.product_incidents` as pi 
left join `floranow.erp_prod.line_items` as li on pi.line_item_id = li.id

where  pi.deleted_at is null and pi.stage = 'PACKING' and pi.line_item_id= 100452

group by concat(pi.line_item_id,pi.stage);