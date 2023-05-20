select 
pod.id,

stg_users.financial_administration,
pod.delivery_date,
stg_users.customer,
stg_users.debtor_number,
pod.source_type,
pod.sequence,
pod.status,


rou.name as routes_name,
dispatched_by.name as dispatched_by,

w.name as warehouse,

from `floranow.erp_prod.proof_of_deliveries` as pod
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = pod.customer_id
left join `floranow.erp_prod.users` as dispatched_by on dispatched_by.id = pod.dispatched_by_id
left join `floranow.erp_prod.routes` as rou on rou.id = pod.route_id
left join `floranow.erp_prod.warehouses` as w on rou.warehouse_id = w.id

left join `floranow.erp_prod.line_items` as li on li.proof_of_delivery_id = pod.id