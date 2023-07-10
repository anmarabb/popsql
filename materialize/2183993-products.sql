select count (*) as row_count
from products as p
left join stocks as st on st.id = p.stock_id and  st.reseller_id = p.reseller_id
left join line_items as li on li.id = p.line_item_id