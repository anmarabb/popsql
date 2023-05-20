select 
pi.id,
pi.incident_type,
pi.stage,
pi.status,
pi.line_item_id as Line_Item_id,
line_items.product_name,
users.name as Customer,
suppliers.name as Supplier_Name,
line_items.quantity as Total_Ordered_Quantity,
pi.quantity,
pi.accounted_quantity,
line_items.unit_fob_price,
line_items.unit_landed_cost,
line_items.color,
line_items.stem_length,
line_items.delivery_date,
pi.credit_note_item_id,
pi.created_at,
pi.updated_at,
pi.note,
pi.quantity * line_items.unit_landed_cost as value,
pi.quantity * line_items.unit_fob_price as fob_value
from `floranow.erp_prod.product_incidents` as pi 
left join `floranow.erp_prod.line_items` as line_items on pi.line_item_id = line_items.id
left join `floranow.erp_prod.users` as users on line_items.user_id = users.id
left join `floranow.erp_prod.suppliers` as suppliers on line_items.supplier_id = suppliers.id