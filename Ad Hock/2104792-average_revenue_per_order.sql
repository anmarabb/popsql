SELECT
li.order_number,
sum(li.quantity*li.unit_price) as total_revenue_per_order,

FROM
    `floranow.erp_prod.line_items` AS li
    left join `floranow.erp_prod.users` as u on li.customer_id = u.id


  GROUP BY
    order_number;


with value_per_order as (
select 
order_id,
sum(quantity * unit_price) total_revenue_per_order,
from `floranow.erp_prod.line_items`
group by order_id
)

select

sum(total_revenue_per_order) total_revenue,
avg(total_revenue_per_order) average_revenue_per_order,
min(total_revenue_per_order) smallest_order, 
max(total_revenue_per_order) largest_order,

from 
  value_per_order;