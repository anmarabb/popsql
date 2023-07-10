select count (*) as row_count
from products as p
left join stocks as st on st.id = p.stock_id and  st.reseller_id = p.reseller_id
left join line_items as li on li.id = p.line_item_id
--left join product_locations as pl on pl.locationable_id = p.id and pl.locationable_type = "Product"
--left join locations as loc on pl.location_id=loc.id