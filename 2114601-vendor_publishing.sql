create or replace table `floranow.Floranow_ERP.vendor_publishing` as 



SELECT
o.id as offer_id,
g.name as supplier,
o.name as offer_name,
ot.name as offer_template,

a.floranow_account_id,

case 
when ot.name like '%Event%' THEN 'Event Offer' 

else 'Regular Offer' end as offer_type,


count(o.id) over (partition by g.name) as publishing_time_per_supplier,

--count(distinct g.name) over() as active_suppliers,

st.status as stocks_status,

  DATE_DIFF(st.created_at, o.created_at, DAY) AS created_at_days_difference,
  DATE_DIFF(st.updated_at, o.updated_at, DAY) AS updated_at_days_difference,


concat(g.name,date(o.created_at)) as publish_id,



--date
    o.created_at as offer_created_at,

    o.updated_at as offer_updated_at,
    o.departure_date_time as offer_departure_date,
    o.status as offer_status,

    st.created_at as stocks_created_at,
    st.updated_at as stocks_updated_at,
    st.deleted_at as stocks_deleted_at,
    st.last_published_at as stocks_last_published_at,

    max(o.created_at) over (partition by g.name) as last_publisheded,
    --max(st.last_published_at) over (partition by g.name ) as last_publisheded,



p.name as product,
p.color,
p.flori_main_group_name as product_group,
p.flori_sub_group_name as product_sub_group,
st.quantity,
st.remain_quantity,
st.minimum_order_quantity,

count (distinct grower_id) over() as registered_suppliers,

s.account_manager,
s.supplier_region,



max(date(o.departure_date_time)) over(partition by g.name, ot.name)  as last_departure_date,  --over(partition by g.name)
DATE_DIFF(cast (max(date(o.departure_date_time)) over(partition by g.name) as date), CAST(CURRENT_DATE() AS date) ,day) as days_to_next_departure,
case when DATE_DIFF(cast (max(date(o.departure_date_time)) over(partition by g.name) as date), CAST(CURRENT_DATE() AS date) ,day) in (3,4,5,6,7,8,9)then 'active' else 'inactive' end as supplier_status,



from `floranow.vendor_portal_prod.stocks` as st
left join `floranow.vendor_portal_prod.offers` as o on st.stockable_id = o.id
left join `floranow.vendor_portal_prod.products` as p on st.product_id = p.id

left join `floranow.vendor_portal_prod.growers`as g on g.id = p.grower_id
left join `floranow.vendor_portal_prod.offer_templates` as ot on ot.id = o.offer_template_id
left join `floranow.vendor_portal_prod.quantity_units` as qu on qu.id = st.quantity_unit_id
left join `floranow.vendor_portal_prod.feeds` as f on f.id = ot.feed_id

left join `floranow.vendor_portal_prod.accounts` as a on g.account_id= a.id


left join `floranow.Floranow_ERP.suppliers` as s on s.floranow_supplier_id = a.floranow_account_id

where ot.name not like '%Event%'
--left join `floranow.vendor_portal_prod.specifications` as spec on spec.specifiable_id = p.id
--left join `floranow.vendor_portal_prod.specification_values` as specV on specV.specification_id = spec.id