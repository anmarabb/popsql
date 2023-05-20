--create or replace view `floranow.Floranow_ERP.invoices_items` as
with
prep_manageable_accounts as (select account_manager_id , manageable_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User'),
prep_last_drop_date as (select customer_id,  max(i.printed_at) as last_drop_date  from `floranow.erp_prod.invoices` as i  group by customer_id ),
prep_country as (select distinct country_iso_code  as code, country_name from `floranow.erp_prod.country` )


select

case when ii.id is not null and li.id is null then 'without_line_item' else 'normal' end as line_item_check,

case 
when date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) = 0 then 'Same day express'
when date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) = 1 then 'Next day express delivery'
when date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) > 1 then 'Regular delivery'
else 'check my logic'
end as delivery_type,



i.number as invoice_number,
ii.price, --Qty. * unit_price + tax

case when i.printed_at is not null then 'Printed' else 'Not-Printed' end as is_printed,


--ii.generation_type as generation_type_inv_item, --don't use this 

i.generation_type,

--date:
    ii.delivery_date,  -- promised delivery date / as appeear in marketplace
    ii.order_date,
    ii.created_at,
    ii.updated_at,
    date(ii.meta_data.invoice_date) as meta_invoice_date,

    --i.items_collection_date,
    i.printed_at,




ii.id,
ii.status,
ii.product_name,
ii.line_item_id,
ii.invoice_id,


li.departure_date,
li.order_number,
li.order_type as row_order_type,
case when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' else li.order_type end as order_type,




u.name as Approved_by,
u2.name as Customer,
u2.debtor_number,
u3.name as account_manager,
u2.state,
u2.city as row_city,
u2.country as row_country,
c.country_name as country,
uc.name as user_category,
s.name as Supplier_name,

sh.name as shipment,


--- invoice source_type
CASE 
     when ii.source_type = 'INTERNAL' then 'ERP'
     when ii.source_type is null  then 'Florisft'
     else  'check_my_logic'
     END AS source_type,




----customer_type
case
    when u2.customer_type = 0 then 'reseller'
    when u2.customer_type = 1 then 'retail'
    when u2.customer_type = 2 then 'fob'
    when u2.customer_type = 3 then 'cif'
    else 'check_my_logic'
    end as customer_type,

---financial_administration
case
    when u2.financial_administration_id = 1 then 'KSA'
    when u2.financial_administration_id = 2 then 'UAE'
    when u2.financial_administration_id = 4 then 'kuwait'
    when u2.financial_administration_id = 5 then 'Qatar'
    when u2.financial_administration_id = 6 then 'Bulk'
    when u2.financial_administration_id = 7 then 'Internal'
    else 'check_my_logic'
    end as financial_administration,

--supplier_region
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

CASE
    WHEN s.id   IN (9,97,99,104,102,18,11,42,66,27,49,39,19,87,2,93,29,35,38,64,31,57,43,28,37,70,100,40,105,53,30,67,71,113,183,109,110,95) THEN 'Re-Selling' 
    ELSE 'Pre-selling'
END as supplier_type,


CASE
    WHEN u2.city LIKE '%Abu Dhabi%' THEN 'Abu Dhabi' 
    WHEN u2.city LIKE '%abu dhabi%' THEN 'Abu Dhabi' 
    WHEN u2.city LIKE '%al ain city%' THEN 'Al Ain' 
    WHEN u2.city LIKE '%Al Ain City%' THEN 'Al Ain' 
    WHEN u2.city LIKE '%Dubai%' THEN 'Dubai' 
    WHEN u2.city LIKE '%dubai%' THEN 'Dubai'
    WHEN u2.city LIKE '%Ajman%' THEN 'Ajman'
    WHEN u2.city LIKE '%Sharjah%' THEN 'Sharjah'
    WHEN u2.city LIKE '%Al Fujairah City%' THEN 'Al Fujairah' 
    WHEN u2.city LIKE '%Ras al-Khaimah%' THEN 'Ras Al-Khaimah' 
    WHEN u2.city LIKE '%Umm Al Quwain City%' THEN 'Umm Al Quwain' 
    WHEN u2.city LIKE '%riyadh%' THEN 'Riyadh' 
    WHEN u2.city LIKE '%Riyadh%' THEN 'Riyadh' 
    WHEN u2.city LIKE '%tabuk%' THEN 'Tabuk' 
    WHEN u2.city LIKE '%Tabuk%' THEN 'Tabuk' 
    WHEN u2.city LIKE '%jeddah%' THEN 'Jeddah' 
    WHEN u2.city LIKE '%Jeddah%' THEN 'Jeddah' 
    WHEN u2.city LIKE '%dammam%' THEN 'Dammam' 
    WHEN u2.city LIKE '%Dammam%' THEN 'Dammam' 
    WHEN u2.city LIKE '%medina%' THEN 'Medina' 
    WHEN u2.city LIKE '%Medina%' THEN 'Medina' 

    WHEN u2.city LIKE '%Makkah%' THEN 'Makkah' 
    WHEN u2.city LIKE '%Arar%' THEN 'Arar' 

    ELSE 'null'
    END as city,



---Express V. NonExpress
case  when li.supplier_id IN (109,71) then 'Express'  else 'NonExpress' end as order_mode,


case when i.invoice_type = 1 then 'credit note' else 'invoice' end as invoice_type,
case when ii.price_without_tax <= 0 then 'credit note' else 'invoice' end as anmar_invoice_type,

case when i.invoice_type = 1 then (ii.price_without_tax + ii.total_tax) else 0 end as credit_note_total_vat,

case when i.invoice_type = 1 then ii.price_without_tax else 0 end as credit_note_total,

case when i.invoice_type != 1 then ii.price_without_tax else 0 end as invoice_revenue,

(ii.quantity*li.unit_fob_price) as fob_revenue,
li.unit_fob_price as unit_fob_pric,
concat(u2.debtor_number,ii.invoice_id,i.printed_at) as drop_id, 





--- account status based. on last drop date
case

    when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_drop_date.last_drop_date as date),day ) <= 7 then 'active'
    when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_drop_date.last_drop_date as date),day ) > 7 and DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_drop_date.last_drop_date as date),day ) <= 30 then 'inactive'
    when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(prep_last_drop_date.last_drop_date as date),day ) > 30 then 'churned'
    else 'churned'
    end as account_status_drop_date,




prep_last_drop_date.last_drop_date,




ii.price_without_tax,
ii.total_tax,
ii.quantity,
ii.currency,


ii.unit_price,
li.unit_landed_cost,

--ii.quantity is actuly the invoiced quantity and = fulfeled quantity
ii.quantity * li.unit_landed_cost  as total_cost, --we have problem that manual invoice not have line_item so we can't capture the landed cost
ii.price_without_tax - ii.quantity * li.unit_landed_cost as profit,




-- (sum(price_without_tax)-sum(total_cost))/Sum(price_without_tax)
--(sum(ii.price_without_tax) - sum(ii.quantity * li.unit_landed_cost))/sum(ii.price_without_tax) as margin_2 --need grouping



case
    when i.payment_status = 0 then "Not_paid"
    when i.payment_status = 1 then "Partially_paid"
    when i.payment_status = 2 then "Totally_paid "
    else "Null"
    end as payment_status,



--on time delivery rate OTD rate, To calculate OTD rate, you divide the total number of orders delivered by the number of deliveries that arrived after the promised delivery date.
--out_of_period_check

CASE WHEN i.printed_at > ii.delivery_date then 'late_delivery' else 'on_time_delivery' End as otd_check,
case when ii.delivery_date > current_date() then "Furue" else "Present" end as future_orders,
--case when EXTRACT(HOUR FROM li.created_at) in (1,2,3,4,5,6) then "5_to_10_time_slote" else "otheres" end as time_slot,


case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type != 1 then ii.price_without_tax else 0 end  end as out_of_period_invoice_revenue,
case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type = 1 then ii.price_without_tax else 0 end  end as out_of_period_credit_note,

--invoice_revenue - out_of_period_invoice_revenue = prainted_at rev
case when i.invoice_type != 1 then ii.price_without_tax else 0 end - case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type != 1 then ii.price_without_tax else 0 end  end invoice_revenue_subtracting_out_of_period,



case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then "in_period_revenue" else "out_of_period_revenue" end as out_of_period_check,





/*
identfy the out_of_period_revenue 
1. extract the month/year of delivery_date - example 3 - 2022
2. extract the month/year of printed_at - example 3- 2022
3. if year(delivery_date)=year(printed_at) and month(delivery_date)=month(printed_at) then in_period_revenue else out_of_period_revenue
*/

from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.users` as u on ii.approved_by_id = u.id
left join `floranow.erp_prod.users` as u2 on ii.customer_id = u2.id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id
left join `floranow.erp_prod.suppliers` as s on li.supplier_id = s.id 
left join prep_manageable_accounts as ma on ii.customer_id = ma.manageable_id
left join `floranow.erp_prod.account_managers` as am on ma.account_manager_id = am.id
left join `floranow.erp_prod.users` as u3 on am.user_id = u3.id
left join prep_country as c on u2.country = c.code
left join `floranow.erp_prod.user_categories` as uc on u2.user_category_id = uc.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join prep_last_drop_date on u2.id = prep_last_drop_date.customer_id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id

--left join `floranow.erp_prod.products` as products on products.line_item_id = ii.line_item_id
--where ii.status = 'APPROVED'