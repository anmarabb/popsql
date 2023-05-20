--create or replace view `floranow.Floranow_ERP.line_items` as 

    with 
    prep_last_order_date as (select customer_id,  max(li.created_at) as last_order_date  from `floranow.erp_prod.line_items` as li  group by customer_id ),
    prep_product_incidents as (select distinct line_item_id, count(*) as incidents_count from `floranow.erp_prod.product_incidents` group by 1  ),
    prep_country as (select distinct country_iso_code  as code, country_name from `floranow.erp_prod.country` )
   
SELECT

case when li.proof_of_delivery_id is not null then 'POD' else 'null' end as proof_of_delivery_2,

case when li.original_feed_source_id is not null then 'mask suppler' else 'same suppler' end as feed_source_test,



case when li.shipment_id is not null then 'root_line_item' else 'parent_line_item' end as line_item_type,
case when u.customer_type = 0 then u.name else 'null' end as reseller,

/*
li.order_request_id,
li.source_line_item_id, 
li.parent_line_item_id,

li.shipment_id,
li.source_shipment_id,
li.root_shipment_id,
*/

case 
when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) = 0 then 'Same day express'
when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) = 1 then 'Next day express delivery'
when date_diff( cast(li.delivery_date  as date ),cast(li.created_at as date), DAY) > 1 then 'Regular delivery'
else 'check my logic'
end as delivery_type,

case when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' else li.order_type end as order_type,
li.order_type as row_order_type,



li.fob_currency,
li.landed_currency,
li.currency,
li.id,
li.product_name,
li.order_number,
li.order_id,



s.name as shipment,
li2.product_name as Replace_For,

u.name as Customer,
u.email,
u.debtor_number,

--quantity
    li.quantity,
    li.fulfilled_quantity,
    li.inventory_quantity,
    li.missing_quantity,
    li.damaged_quantity,
    li.delivered_quantity,
    li.returned_quantity,
    li.canceled_quantity,
    li.picked_quantity,



--li.packaging,
su.name as Supplier_Name,
concat(u3.name," ",r.name, " ","(",pod.delivered_at,")") as Proof_Of_Delivery,
r1.name as Route,


fs.name as Feed_Source,
fs1.name as Original_Feed_Source,



li.grower_id,
li.supplier_product_name,
li.supplier_product_id as Supplier_Product,
li.color,
li.stem_length,
li.tags,
li.calculated_price,
li.price_margin,
li.ordering_pattern,
li.unit_fob_price,
li.unit_price,
li.sales_unit,
li.total_price_include_tax,
li.total_price_without_tax,
li.total_tax,
li.exchange_rate,
li.departure_date,
li.delivery_date,

--date
    li.created_at,  
    li.dispatched_at,
    li.expired_at,
    li.completed_at,
    li.delivered_at,
    li.received_at,
    li.returned_at,
    li.damaged_at,
    li.canceled_at,


li.received_note,
li.returned_note,
li.canceled_by_id,
li.cancellation_reason,
li.state as Line_Item_Status,
li.fulfillment,
li.custom_price,
li.pricing_type,

w.name as Warehouse,
pod.status as POD_status,

--li.created_by_id,
--li.returned_by_id,

prep_last_order_date.last_order_date,


u.country as Row_country,

li.split_at,


inv.printed_at,


c.country_name as Country,
uc.name as User_Category,
u2.name as account_manager,
li.invoice_id,


u.city as row_city,

CASE
    WHEN u.city LIKE '%Abu Dhabi%' THEN 'Abu Dhabi' 
    WHEN u.city LIKE '%abu dhabi%' THEN 'Abu Dhabi' 
    WHEN u.city LIKE '%al ain city%' THEN 'Al Ain' 
    WHEN u.city LIKE '%Al Ain City%' THEN 'Al Ain' 
    WHEN u.city LIKE '%Dubai%' THEN 'Dubai' 
    WHEN u.city LIKE '%dubai%' THEN 'Dubai'
    WHEN u.city LIKE '%Ajman%' THEN 'Ajman'
    WHEN u.city LIKE '%Sharjah%' THEN 'Sharjah'
    WHEN u.city LIKE '%Al Fujairah City%' THEN 'Al Fujairah' 
    WHEN u.city LIKE '%Ras al-Khaimah%' THEN 'Ras Al-Khaimah' 
    WHEN u.city LIKE '%Umm Al Quwain City%' THEN 'Umm Al Quwain' 
    ELSE 'null'
    END as city,


--financial_administration
case 
        when u.financial_administration_id = 1 then 'KSA'
        when u.financial_administration_id = 2 then 'UAE'
        when u.financial_administration_id = 4 then 'kuwait'
        when u.financial_administration_id = 5 then 'Qatar'
        when u.financial_administration_id = 6 then 'Bulk'
        when u.financial_administration_id = 7 then 'Internal'
        else 'check my logic'
        end as financial_administration,

--customer_type
case 
        when u.customer_type = 0 then 'reseller'
        when u.customer_type = 1 then 'retail'
        when u.customer_type = 2 then 'fob'
        when u.customer_type = 3 then 'cif'
        when u.customer_type is null then 'null'
        else 'not-set'
        end as customer_type,



CASE
    WHEN li.supplier_id   IN (2) THEN 'South Africa' 
    WHEN li.supplier_id   IN (70,71) THEN 'Ecuador' 
    WHEN li.supplier_id   IN (68) THEN 'Astra' 
    WHEN li.supplier_id   IN (183) THEN 'South Africa' 

    WHEN li.supplier_id   IN (39) THEN 'Malaysia' 
    WHEN li.supplier_id   IN (109) THEN 'Express' 
    WHEN li.supplier_id   IN (100,66,79,98) THEN 'Ethiopia' 
    WHEN li.supplier_id   IN (19,10) THEN 'Thailand' 
    WHEN li.supplier_id   IN (1,7,52,4,113) THEN 'Holland' 
    WHEN li.supplier_id   IN (112,20,22,80) THEN 'UAE' 
    WHEN li.supplier_id   IN (104,27,11,18,57,97,99,102,103,9) THEN 'Colombia' 
    WHEN li.supplier_id   IN (81,36,105,91,85,61,74,84,149,150,148,59,25,33,12,15,23,51,89,73,32,13,111,49,14,77,76,26,45,62,17,16,88,34,54,101,86,21,92,24,3,63,90) THEN 'Kenya' 
    ELSE 'check my logical'
END as supplier_region,
        


--(li.total_price_without_tax - (li.quantity * li.unit_landed_cost)/li.total_price_without_tax) as margin,

--create financal month with query
--if the delivery_date in month (A) and printed_at in month(B) then moved_to_next_month_invoice if the delivery_date and printed_at in the same month then normal_invoicing

--Custom Fields
    case --improve this to include the last order from manual invoice, Osama case

        when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_order_date.last_order_date as date),day ) <= 7 then 'active'
        when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_order_date.last_order_date as date),day ) > 7 and DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_order_date.last_order_date as date),day ) <= 30 then 'inactive'
        when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_order_date.last_order_date as date),day ) > 30 then 'churned'
        else 'churned'
        end as clinet_engagmnet_status,
    


    DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_order_date.last_order_date as date),day ) as Days_since_last_order,


    case when li.supplier_id IN (109,71) then 'Express' when li.supplier_id is null then "Check My Logic" else 'NonExpress' end as order_mode,
    case when li.split_at is not null then 'split' else 'not-split' end as split_status,
    case when li.returned_at is not null then 'returned' else ' ' end as returned_status,
    case when li.missing_quantity > 0 or li.damaged_quantity > 0 or li.canceled_quantity > 0 or li.returned_quantity > 0  then 'incidents' else 'normal' end as incident,
    case when date_diff(cast (li.delivery_date as date) ,cast(inv.printed_at as date), MONTH) = 0 then 'ok' else 'moved_to_next_month_invoice' end as financal_month,
    case when inv.printed_at > li.delivery_date then "late_delivery" else "ontime_delivery" end as late_or_ontime_delivery,
    


    case when li.supplier_id IN (109,71) then li.total_price_without_tax else 0 end as express_sales,




    case 
        when li.invoice_id is not null and inv.printed_at is not null then 'Printed Invoice' 
        when li.invoice_id is not null and inv.printed_at is null then 'Proforma Invoice'
        else 'Not Printed Invoice' end as invoice_status,
   


    --case when li.state NOT IN ('DELIVERED','DISPATCHED') then 'not_invoiced' else 'invoiced' end as line_item_financial_status,
    --sum(case when li.state NOT IN ('PENDING','CANCELED','RETURNED') then li.total_price_without_tax else 0 end)  over (partition by li.id) as total_invoice_value,

    case when inv.payment_status = 0 then "Not Paid" when inv.payment_status = 1 then "partially_paid " when inv.payment_status = 2 then "Not Paid" else 'Not invoiced' End as payment_status,





case when li.id is not null then li.total_price_without_tax else 0 end as potential_revenue,
case when li.id is not null then li.fulfilled_quantity * li.unit_price else 0 end as fulfilled_revenue,
case when li.invoice_id is not null and inv.printed_at is not null then li.fulfilled_quantity * li.unit_price else 0 end as invoiced_revenue,
case when li.invoice_id is not null and inv.printed_at is null then li.fulfilled_quantity * li.unit_price else 0 end as Proforma_revenue,



(li.quantity*li.unit_fob_price) as fob_revenue,


li.quantity * li.unit_landed_cost as orderd_cost,
li.fulfilled_quantity * li.unit_landed_cost as fulfilled_cost,


li.total_price_without_tax - li.quantity * li.unit_landed_cost as potential_profit,

li.fulfilled_quantity * li.unit_price - li.fulfilled_quantity * li.unit_landed_cost as actual_profit,



li.unit_landed_cost,

product_incidents.incidents_count,
case when product_incidents.incidents_count is not null then 'incident' else 'No-incident' end as incident_check,

/*
product_incidents.incident_type,
product_incidents.stage,


case 
when product_incidents.stage is null  then 'order' 
when product_incidents.stage is not null and incident_type in ('EXTRA') then 'EXTRA' 
else 'incident' end as order_status,

*/

CASE WHEN inv.printed_at > li.delivery_date then 'late_delivery' else 'on_time_delivery' End as otd_check,
case when li.delivery_date > current_date() then "Furue" else "Present" end as future_orders,
case when EXTRACT(HOUR FROM li.created_at) in (1,2,3,4,5,6) then "5_to_10_time_slote" else "otheres" end as time_slot,


FROM
`floranow.erp_prod.line_items` As li
left join `floranow.erp_prod.shipments` as s on li.shipment_id = s.id
left join `floranow.erp_prod.users` as u on li.customer_id = u.id


left join `floranow.erp_prod.line_items` as li2 on li.replace_for_id = li2.id
left join `floranow.erp_prod.user_categories` as uc on u.user_category_id = uc.id
left join  (select manageable_id,account_manager_id  from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User') manageable_accounts on li.customer_id = manageable_accounts.manageable_id
left join `floranow.erp_prod.account_managers` as am on manageable_accounts.account_manager_id = am.id
left join `floranow.erp_prod.users` as u2 on u2.id = am.user_id
left join `floranow.erp_prod.suppliers` as su on li.supplier_id = su.id

left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id = pod.id
left join `floranow.erp_prod.users` as u3 on pod.customer_id = u3.id
left join `floranow.erp_prod.routes` as r on pod.route_id = r.id

left join `floranow.erp_prod.routes` as r1 on u.route_id = r1.id

left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id


left join `floranow.erp_prod.feed_sources` as fs1 on fs1.id = li.original_feed_source_id


left join `floranow.erp_prod.warehouses` as w on u.warehouse_id = w.id

left join prep_last_order_date on u.id = prep_last_order_date.customer_id
left join `floranow.erp_prod.invoices` as inv on li.invoice_id = inv.id
left join prep_country as c on u.country = c.code

left join prep_product_incidents AS product_incidents ON product_incidents.line_item_id = li.id

left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id

left join floranow.erp_prod.products AS products ON li.id = products.line_item_id