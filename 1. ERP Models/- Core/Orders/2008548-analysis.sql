---order_payloads
select
count(*) as row_count,
from `floranow.erp_prod.order_payloads` as opl
;


select
opl.status,
count(*) as row_count,
from `floranow.erp_prod.order_payloads` as opl
group by opl.status
;

select
opl.response_code,
count(*) as row_count,
from `floranow.erp_prod.order_payloads` as opl
group by opl.response_code
;

select
opl.marketplace_request.order_type,
count(*) as row_count,
from `floranow.erp_prod.order_payloads` as opl
group by opl.marketplace_request.order_type
;



------------------------------------------order_requests

select
orr.order_number,
count(*) as row_count,
from `floranow.erp_prod.order_requests` as orr
where orr.order_number = 'R043149716'
;




select
orr.status,
count(*) as row_count,
from `floranow.erp_prod.order_requests` as orr
group by orr.status
;



select
count(*) as row_count,
from `floranow.erp_prod.order_requests` as orr
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = orr.customer_id
left join `floranow.Floranow_ERP.suppliers` as suppliers on suppliers.id = orr.supplier_id
left join `floranow.erp_prod.users` as created_by on created_by.id = orr.created_by_id
left join `floranow.erp_prod.users` as rejected_by on rejected_by.id = orr.rejected_by_id
left join `floranow.erp_prod.feed_sources` as orr_fs on orr.feed_source_id = orr_fs.id
left join `floranow.erp_prod.standing_orders` as so on orr.standing_order_id = so.id
left join `floranow.erp_prod.order_builders` as ob on ob.id = orr.order_builder_id
left join `floranow.erp_prod.warehouses` as w on w.id = stg_users.warehouse_id

left join `floranow.erp_prod.line_items` as li on li.order_request_id = orr.id 
;



select
li.order_request_id,
li.id as line_item_id,
li.order_payload_id,
li.order_number,
li.state,
from `floranow.erp_prod.line_items` as li
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id= orr.id
where order_request_id = 3085
;




select
count(*)
from `floranow.erp_prod.line_items` as li
;

select
count(*)
from `floranow.erp_prod.order_requests` as orr
;


-------------------line_items

select
li.state,
count(*) as row_count,
from `floranow.erp_prod.line_items` as li
group by li.state
;


select
li.order_type,
count(*) as row_count,
from `floranow.erp_prod.line_items` as li
where li.order_payload_id is null
group by li.order_type
;



select
count(*)
from `floranow.erp_prod.order_payloads` as opl
;



--join line_item with order_requsets
select
count(*)
from `floranow.erp_prod.line_items` as li
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id= orr.id
;