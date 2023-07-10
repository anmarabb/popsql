create view  products as 
select 

from products as p

left join stocks as st on st.id = p.stock_id and  st.reseller_id = p.reseller_id
left join line_items as li on li.id = p.line_item_id
left join product_locations as pl on pl.locationable_id = p.id and pl.locationable_type = 'Product'
left join locations as loc on pl.location_id=loc.id
left join warehouses as w on w.id = st.warehouse_id
left join sections as sec on sec.id =loc.section_id
left join  line_items as parent_li on parent_li.id = li.parent_line_item_id
left join suppliers as stg_suppliers on stg_suppliers.id = p.supplier_id
left join suppliers as li_suppliers on li_suppliers.id = li.supplier_id
left join feed_sources as fs on fs.id = p.origin_feed_source_id
left join feed_sources as fs2 on fs2.id = p.publishing_feed_source_id
left join feed_sources as fs3 on fs3.id = p.feed_source_id
left join feed_sources as fs4 on fs4.id = st.out_feed_source_id
left join users as reseller on reseller.id = p.reseller_id
left join additional_items_reports as ad on ad.line_item_id=li.id
left join order_requests as orr on li.order_request_id = orr.id
where p.deleted_at is  null;