with value_per_order as (
SELECT
li.order_id,
sum(li.quantity*li.unit_price) as total_revenue_per_order,
FROM
    `floranow.erp_prod.line_items` AS li
    left join `floranow.erp_prod.users` as u on li.customer_id = u.id


  GROUP BY
    order_id

  )
  select 
  
 sum(total_revenue_per_order) as total_revenue,
 avg(total_revenue_per_order) as avg_revenue_per_order,
 min(total_revenue_per_order) as smalles_order,
 max(total_revenue_per_order) as largest_order,
  
  
  from value_per_order;