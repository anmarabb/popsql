with product_incidents as (
            select 
            pi.line_item_id,
            count(*) as incidents_count,
            sum(quantity) as incidents_quantity,
            from `floranow.erp_prod.product_incidents` as pi 
            where  pi.deleted_at is null
            group by pi.line_item_id
      )


select
p.product_id,
max(p.order_type) as order_type,
max(p.loc_status) as loc_status,
max(date(p.created_at)) as oder_date,
max(date(p.delivery_date)) as delivery_date,
max(date(p.fulfilled_at)) as stock_in_at,
max(date(p.empty_at)) as empty_at,
max(date(p.expired_at)) as expired_at,
max(age) as age,

max(p.ordered_quantity) as ordered_quantity,
max(p.location_quantity) as location_quantity,

count(li.line_item_id) as item_Selled,
sum(li.ordered_quantity) as quantity_Selled,
sum(li.returned_quantity) as returned_quantity,

max(pi.incidents_count) as incidents,
max (pi.incidents_quantity) as incidents_quantity,

from `floranow.dbt_dev_stg.int_line_items` as li 
left join `floranow.dbt_dev_stg.int_products` as p on p.line_item_id = li.parent_line_item_id
left join product_incidents as pi on pi.line_item_id = li.parent_line_item_id
where li.record_type_details = 'Customer Inventory Order'   --and product_id=43949

group by 1
limit 100