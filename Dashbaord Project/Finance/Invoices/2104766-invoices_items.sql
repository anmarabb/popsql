create or replace table `floranow.Floranow_ERP.invoices_items` as

with 
prep_product_incidents as (select distinct line_item_id, count(*) as incidents_count from `floranow.erp_prod.product_incidents` group by 1  ),
prep_registered_clients as (select financial_administration,count(*) as registered_clients from `floranow.Floranow_ERP.users` u where account_type in ('External') and deleted_accounts != 'Deleted' and email not like '%fake_%' and u.email not like '%temp_%'
 group by financial_administration)   
SELECT
 
 
CASE  
    WHEN LOWER(stg_users.customer) LIKE '%tamimi%' THEN 'Tamimi Sales'
    WHEN stg_users.customer IN ('REMA1','REMA2','REMA3','REMA4','REMA5','REMA6','REMA7','REMA8') THEN 'REMA Sales'
    ELSE 'Astra Sales'
END as astra_sales_segments,


/*
case 
when astra_shop = 'Astra Shop' and sales_source = 'Astra' then 'Astra Shop Sales From Astra Products' 
when astra_shop = 'Astra Shop' and sales_source = 'Non Astra' then 'Astra Shop Sales From Non Astra Prudyct' 

else null end as astra_shop_sales_type,
*/


--abs(quantity)*unit_landed_cost
case when i.invoice_type = 0 then ii.quantity * li.unit_landed_cost else 0 end as total_cost, 

ii.price_without_tax - (case when i.invoice_type = 0 then ii.quantity * li.unit_landed_cost else 0 end) as profit,

case when i.invoice_type != 1 then ii.price_without_tax else 0 end as invoice_revenue,


case 
    when w.name in ('Riyadh Warehouse','Qassim Warehouse','Jouf WareHouse','Hail Warehouse') then 'Al Amir'
    when w.name in ('Dammam Warehouse','Hafar WareHouse') then 'Hani'
    when w.name in ('Jeddah Warehouse') then 'Mahmoud'
    when w.name in ('Tabuk Warehouse') then 'Majed'
    when w.name in ('Medina Warehouse') then 'Abd Alaziz'
    else null end as astra_accountant,





        case 
            when li.parent_line_item_id is not null then parent_li_suppliers.supplier_name 
            when stg_users.financial_administration = 'Bulk' then  ii.meta_data.supplier
            else li_suppliers.supplier_name 
        end as supplier,


case 
when parent_li_suppliers.supplier_name  = 'ASTRA Farms' then 'Astra'
when li_suppliers.supplier_name = 'ASTRA Farms' then 'Astra'
when ii.meta_data.supplier_name in ('Astra Farm','Astra farm Barcode','Astra Farm - Event','Astra Flash Sale - R','Astra Flash sale - W') then 'Astra'
--when fs.name in ('Express Jeddah','Express Dammam', 'Express Riyadh') and  parent_li_suppliers.supplier_name in ('Holex','Floradelight', 'Waridi', 'Sierra','Vianen','PJ Dave Roses','Heritage Flowers','Décor Foliage','Sian Flowers', 'Flora Ola') then 'Non Astra'
--when fs.name in ('Express Jeddah','Express Dammam', 'Express Riyadh', 'Express Tabuk') or li_suppliers.supplier_name in ('Express Jeddah','Express Dammam', 'Express Riyadh', 'Express Tabuk') then 'Astra'


else 'Non Astra'
end as sales_source,





ii.Reason,


case when w.name is not null then w.name  end as warehouse,

case
when i.financial_administration_id = 1 then  w.name
else  stg_users.city end as city,

--stg_users
    stg_users.city as raw_city,
    stg_users.customer,
    stg_users.client_category,
    stg_users.payment_term,
    stg_users.account_manager,
    stg_users.country,
    stg_users.reseller,


    stg_users.customer_type as row_customer_type,

    case 
        when stg_users.customer_type = 'reseller' and stg_users.warehouse_id in (10,43,76,79) then 'remote branch reseller'
        when stg_users.customer_type = 'reseller' then 'main branch reseller'
        else stg_users.customer_type
    end as customer_type,


    stg_users.debtor_number,
    stg_users.last_drop_date,
    stg_users.days_since_last_drop,
    stg_users.master_account,
    stg_users.client_value_segments,
    stg_users.financial_administration as u_financial_administration,
    case 
    when stg_users.client_value_segments in ('1- Clients who pay +50K per month') then 'Whales'
    when stg_users.client_value_segments in ('2- Clients who pay +24K per month') then 'Sharks'
    when stg_users.client_value_segments in ('3- Clients who pay +12K per month') then 'Big Fish'
    else 'Small Fish'
    end as client_value_segments_2,

    case --financial ID
        when i.financial_administration_id = 1 then 'KSA'
        when i.financial_administration_id = 2 then 'UAE'
        when i.financial_administration_id = 3 then 'Jordan'
        when i.financial_administration_id = 4 then 'kuwait'
        when i.financial_administration_id = 5 then 'Qatar'
        when i.financial_administration_id = 6 then 'Bulk'
        when i.financial_administration_id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,





sh.name as shipment,



--Master Metrics
    ii.quantity as row_quantity,
    case when i.invoice_type = 1 then -ii.quantity else ii.quantity end as quantity,



    case when i.invoice_type = 1 then null else ii.invoice_id end as orders_count,

    case when ii.creditable_id is null then 0 else ii.quantity end as quantity_cn,
    case when ii.creditable_id is not null then 0 else ii.quantity end as quantity_sold,


concat(stg_users.debtor_number,ii.delivery_date) as drop_id, 




case when i.invoice_type = 1  then ii.price_without_tax else 0  end as credit_note_total,



case when i.invoice_type = 1 then 'credit note' else 'invoice' end as invoice_type,



case when i.invoice_type = 1 then (ii.price_without_tax + ii.total_tax) else 0 end as credit_note_total_vat,


















ii.meta_data.supplier_code as meta_supplier_code,
ii.meta_data.supplier_name as meta_supplier_name, 
ii.meta_data.supplier as meta_supplier,  --bullk but here
li_suppliers.supplier_name as li_erp_supplier_name,
parent_li_suppliers.supplier_name as parent_li_supplier, --to discover orginal supplier

--refactor


stg_users.company_name,


fs.name as feed_source,


--case when ii.meta_data.supplier_name is null then li_suppliers.supplier_name else ii.meta_data.supplier_name end as supplier_name,


parent_li.order_type as parent_li_order_type,


li.unit_fob_price,
li.fob_currency,
parent_li.unit_fob_price as root_unit_fob_price,
parent_li.fob_currency as root_fob_currency,



ii.creditable_id,



case when ii.creditable_id is not null then 0 else 1 end as items_sold,

case when li.parent_line_item_id is not null then parent_li.unit_fob_price else li.unit_fob_price end as unit_fob_price_2,
case when li.parent_line_item_id is not null then parent_li.fob_currency else li.fob_currency end as fob_currency_2,



ii.price, 
ii.price_without_tax,
ii.discount_amount,
ii.price_without_discount,

i.number as invoice_number,
ii.status, --APPROVED, DRAFT, REJECTED, CANCELED


li.order_number,



--




ii.total_tax,
ii.currency,
(ii.quantity*li.unit_fob_price) as fob_revenue,

ii.unit_price,
li.unit_landed_cost,

--ii.quantity * li.unit_landed_cost  as total_cost, --we have problem that manual invoice not have line_item so we can't capture the landed cost



li.landed_currency,





case
    when li.landed_currency in ('KWD') then (li.unit_landed_cost * 3.256648) * ii.quantity
    when li.landed_currency in ('USD') then (li.unit_landed_cost) * ii.quantity
    when li.landed_currency in ('EUR') then (li.unit_landed_cost * 1.0500713) * ii.quantity
    when li.landed_currency in ('AED') then (li.unit_landed_cost * 0.27229408) * ii.quantity
    when li.landed_currency in ('SAR') then (li.unit_landed_cost * 0.26666667) * ii.quantity
end as usd_total_cost,


case 
    when ii.currency in ('SAR') then ii.price_without_tax * 0.26666667
    when ii.currency in ('AED') then ii.price_without_tax * 0.27229408
    when ii.currency in ('KWD') then ii.price_without_tax * 3.256648 
    when ii.currency in ('USD') then ii.price_without_tax
    when ii.currency in ('EUR') then ii.price_without_tax * 1.0500713
    when ii.currency in ('QAR', 'QR') then ii.price_without_tax * 0.27472527
    when ii.currency is null then ii.price_without_tax * 0.27229408
end as usd_price_without_tax,


case 
    when ii.currency in ('SAR') then ii.price * 0.26666667
    when ii.currency in ('AED') then ii.price * 0.27229408
    when ii.currency in ('KWD') then ii.price * 3.256648 
    when ii.currency in ('USD') then ii.price
    when ii.currency in ('EUR') then ii.price * 1.0500713
    when ii.currency in ('QAR', 'QR') then ii.price * 0.27472527
    when ii.currency is null then ii.price * 0.27229408
end as usd_price,



i.generation_type,

concat( "https://erp.floranow.com/invoice_items/", ii.id) as invoice_items_link,
concat( "https://erp.floranow.com/line_items/", ii.line_item_id) as line_items_link,




CASE 
     when ii.source_type = 'INTERNAL' then 'ERP'
     when ii.source_type is null  then 'Florisft'
     else  'check_my_logic'
     END AS source_type,





i.purchase_order_number,






li.sales_unit,






case 
when li_suppliers.supplier_name in ('Astra DXB out') then 'Astra'
when li_suppliers.supplier_name in ('Wish Flower Inventory') then 'Wish Flower'
when li_suppliers.supplier_name in ('Ecuador Out') then 'Ecuador'
when li_suppliers.supplier_name in ('Ward Flowers') then 'Ward Flower'
else 'Normal'
end as marketplace_projects,


case 
when parent_li_suppliers.supplier_name in ('ASTRA Farms') then 'Commission Based'

when fs.name in ('Express Jeddah','Express Dammam', 'Express Riyadh', 'Express Tabuk') or li_suppliers.supplier_name in ('Express Jeddah','Express Jeddah', 'Express Jeddah', 'Express Tabuk') or ii.meta_data.supplier_name in ('Express Jeddah','Express Jeddah', 'Express Jeddah', 'Express Tabuk') then 'Commission Based'
when li_suppliers.supplier_name in ('Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis') then 'Reselling'
when stg_users.financial_administration = 'UAE' and li_suppliers.supplier_name in ('Fulfilled by Floranow') then 'Reselling'
when li_suppliers.supplier_name in ('Floranow Flash Sale Dammam', 'Floranow Flash Sale Riyadh', 'Floranow Flash Sale Tabuk', 'Floranow Flash Sale Jeddah') then 'Reselling'
when ii.meta_data.supplier_name in ('Verdissimo - AWS','The Orchid garden Reselling','The Orchid Garden - Event','The Orchid Garden - AWS','The Orchid Garden','Smithers Oasis - AWS','Loma Linda Re-selling','Loma Linda - Event','Loma Linda - AWS','Holland Reselling','Gallica AWS','Galleria Farms Reselling','Galleria Farms','Fulfilled By Floranow-KSA','Fresh cap reselling- AWS','Fresh Cap','Florius - event','Florius','Flores Del Este Reselling','Flores del Este - Event','Flores del Este','Floranow Flash sale Dammam','Floranow Express Flash Sale','Express Store','Express Reselling','Elite Flower Farm - Re-selling','Elite flower farm - event','Elite Flower Farm','Ecoflor Re-selling','Ecoflor Event','Ecoflor AWS','Capiro Re-selling','Capiro Event','Capiro AWS','AgroIndustria Reselling','Agroindustria Colombia - AWS','Agroindustria - Event','Holland Reselling Riyadh','Holland Reselling Dammam','Florius Reselling','Flores Del Este - AWS','Floranow Tabuk','Floranow Riyadh','Floranow Medina','Floranow Jeddah','Floranow Dammam','Floranow Jeddah','Floranow Flash Sale Dammam', 'Floranow Flash Sale Riyadh', 'Floranow Flash Sale Tabuk', 'Floranow Flash Sale Jeddah') then 'Reselling'
when li_suppliers.supplier_name in ('Floranow Holland') and fs.name in ('Holland Reselling','Holland Reselling Dammam','Holland Reselling Riyadh') then 'Reselling'
when li_suppliers.supplier_name in ('Floranow Flash sale') and fs.name in ('Floranow Express Flash sale', 'Floranow Flash Sale Dammam','Floranow Flash Sale Riyadh','Floranow Flash Sale Tabuk', 'Floranow Flash Sale Jeddah') then 'Reselling'
when li_suppliers.supplier_name in ('wish flower') then 'Reselling'
when li_suppliers.supplier_name in ('ASTRA Farms') and fs.name in ('Astra DXB out') then 'Commission Based'
when ii.meta_data.supplier_name in ('ASTRA Farms') and fs.name in ('Astra DXB out') then 'Commission Based'
when li_suppliers.supplier_name in ('Ward Flowers') and fs.name in ('Ward Flower Inventory') then 'Commission Based'


else 'Pre-Selling'
end as stock_model,

case 
when li_suppliers.supplier_name in ('wish flower','Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis') then 'Trading'
when li_suppliers.supplier_name in ('ASTRA Farms') and fs.name in ('Astra DXB out') then 'Trading'
when li_suppliers.supplier_name in ('ASTRA Farms') and fs.name in ('Astra Farm') then 'Normal'

when ii.meta_data.supplier_name in ('Verdissimo - AWS','The Orchid garden Reselling','The Orchid Garden - Event','The Orchid Garden - AWS','The Orchid Garden','Smithers Oasis - AWS','Loma Linda Re-selling','Loma Linda - Event','Loma Linda - AWS','Holland Reselling','Gallica AWS','Galleria Farms Reselling','Galleria Farms','Fulfilled By Floranow-KSA','Fresh cap reselling- AWS','Fresh Cap','Florius - event','Florius','Flores Del Este Reselling','Flores del Este - Event','Flores del Este','Floranow Flash sale Dammam','Floranow Express Flash Sale','Express Store','Express Reselling','Elite Flower Farm - Re-selling','Elite flower farm - event','Elite Flower Farm','Ecoflor Re-selling','Ecoflor Event','Ecoflor AWS','Capiro Re-selling','Capiro Event','Capiro AWS','AgroIndustria Reselling','Agroindustria Colombia - AWS','Agroindustria - Event','Holland Reselling Riyadh','Holland Reselling Dammam','Florius Reselling','Flores Del Este - AWS','Floranow Tabuk','Floranow Riyadh','Floranow Medina','Floranow Jeddah','Floranow Dammam','Floranow Jeddah','Floranow Flash Sale Dammam', 'Floranow Flash Sale Riyadh', 'Floranow Flash Sale Tabuk', 'Floranow Flash Sale Jeddah') then 'Trading'
when li_suppliers.supplier_name in ('Ward Flowers') and fs.name in ('Ward Flower Inventory') then 'Trading'

else 'Normal'
end as trading_funcation,

case 
when 
li_suppliers.supplier_name in ('Ward Flowers','wish flower','ASTRA Farms','Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis')
and date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) in (0,1) then 'Express'
else 'Regular'
end as delivery_method,

case 
when 
li_suppliers.supplier_type = 'Re-Selling' and date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) in (0,1) then 'Express'
else 'Regular'
end as delivery_method_2,


case 
when 
li_suppliers.supplier_name in ('wish flower','ASTRA Farms','Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis')
and date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) = 0 then 'Same day express'
when
li_suppliers.supplier_name in ('wish flower','ASTRA Farms','Fulfilled by Floranow','Fulfilled by Floranow SA','The Orchid Garden','Solai Roses','Selemo Valley Farms','Lomalinda','Gallica','Galleria Farms','Fresh Cap','Florius','Flores Del Este','Floranow Holland','Elite Flower Farm','Ecoflor','Capiro','Agroindustria','Smithers Oasis')
and date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) in (1,2) then 'Next day express delivery'
--when date_diff( cast(ii.delivery_date  as date ),cast(ii.order_date as date), DAY) > 2 then 'Regular delivery'
else 'Regular delivery'
end as delivery_type,





case when ii.meta_data.invoice_date is not null and ii.source_type is null then ii.price_without_tax else 0 end as meta_invoice_date_HORDER_FCTDAT_jibu_sales,
case when ii.meta_data.delivery_date is not null and ii.source_type is null then ii.price_without_tax else 0 end as meta_delivery_date_and_printed_at_vertrekdag_abi_sales,

date(ii.meta_data.invoice_date) as meta_invoice_date,
date(ii.meta_data.order_date) as meta_order_date,
date(ii.meta_data.created_at) as meta_created_at,
date(ii.meta_data.parcel_date) as meta_parcel_date,
date(ii.meta_data.delivery_date) as meta_delivery_date,






--case when li.supplier_id IN (109,71) then 'Express' when li.supplier_id is null then 'non' else 'NonExpress' end as order_mode,





prep_registered_clients.registered_clients,
product_incidents.incidents_count,
case when product_incidents.incidents_count is not null then 'incident' else 'No-incident' end as incident_check,






ii.meta_data.order_number as meta_order_number,
ii.meta_data.price_without_tax as meta_price_without_tax,
case

    when stg_users.days_since_last_drop <= 7 then 'active'
    when stg_users.days_since_last_drop > 7 and  stg_users.days_since_last_drop <= 30 then 'inactive'
    when stg_users.days_since_last_drop > 30 then 'churned'
    else 'churned'
    end as account_status_drop_date,





--li_suppliers
    li_suppliers.account_manager as supplier_account_manager,
    li_suppliers.supplier_region,
    li_suppliers.supplier_type,





    
    



---------


ii.id,
ii.line_item_id,
li.id as line_item_id_2,
ii.invoice_id,
li.order_request_id,

--what the diff from i.generation_type?? 

--date:
    date(i.printed_at) as printed_at ,
    ii.delivery_date,  -- promised delivery date / as appeear in marketplace
    ii.order_date,
    ii.created_at,
    ii.updated_at,

    li.departure_date,


li.order_type as row_order_type,

case 
when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' 
else li.order_type end as order_type,

case 
when li.order_type = 'OFFLINE' and orr.standing_order_id is not null then 'STANDING' 
when li.order_type = 'ONLINE' then 'ONLINE' 
else 'OFFLINE' 
end as order_method,








case when i.printed_at is not null then 'Printed' else 'Not-Printed' end as is_printed,
case when ii.id is not null and li.id is null then 'without_line_item' else 'normal' end as line_item_check,





li.proof_of_delivery_id as li_proof_of_delivery_id,

li.ordering_stock_type,

i.proof_of_delivery_id as i_proof_of_delivery_id,




DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),CURRENT_DATE(),DAY) as days_remaining_current_month,


case
    when i.payment_status = 0 then "Not_paid"
    when i.payment_status = 1 then "Partially_paid"
    when i.payment_status = 2 then "Totally_paid "
    else "Null"
    end as payment_status,

--on time delivery rate OTD rate, To calculate OTD rate, you divide the total number of orders delivered by the number of deliveries that arrived after the promised delivery date.
--out_of_period_check

CASE WHEN date(i.printed_at) > ii.delivery_date then 'late_delivery' else 'on_time_delivery' End as otd_check,
case when ii.delivery_date > current_date() then "Furue" else "Present" end as future_orders,
--case when EXTRACT(HOUR FROM li.created_at) in (1,2,3,4,5,6) then "5_to_10_time_slote" else "otheres" end as time_slot,

case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type != 1 then ii.price_without_tax else 0 end  end as out_of_period_invoice_revenue,
case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type = 1 then ii.price_without_tax else 0 end  end as out_of_period_credit_note,
case when i.invoice_type != 1 then ii.price_without_tax else 0 end - case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then 0 else case when i.invoice_type != 1 then ii.price_without_tax else 0 end  end invoice_revenue_subtracting_out_of_period,
case when EXTRACT(MONTH FROM ii.delivery_date) = EXTRACT(MONTH FROM i.printed_at) and EXTRACT(YEAR FROM ii.delivery_date) = EXTRACT(YEAR FROM i.printed_at) then "in_period_revenue" else "out_of_period_revenue" end as out_of_period_check,




li.stem_length,

ii.product_name as product,

case 
when ii.product_name like '%Chrysanthemum%' THEN 'Chrysanthemum'
when ii.product_name like '%Eustoma%' THEN 'Eustoma'
when ii.product_name like '%Gerbera%' THEN 'Gerbera'
when ii.product_name like '%Gerbera%' THEN 'Gerbera'

when li.category is null then INITCAP(ii.category) 
else INITCAP(li.category) 
end as item_category,


li.category2 as row_item_sub_category,

case 
when ii.product_name like '%Lily Ot%' THEN 'Lily Or' 
when ii.product_name like '%Lily Or%' THEN 'Lily Or' 
when ii.product_name like '%Lily La%' THEN 'Lily La' 
when ii.product_name like '%Li La%'  THEN 'Lily La' 
else INITCAP(li.category2) end as item_sub_category,




stg_users.first_order_date,

    pod.status as pod_status,
    pod.source_type as row_pod_source_type,

case 
when pod.source_type = 'INVENTORY' then 'Shipment'
when pod.source_type = 'EXTERNAL' then 'Express'
when pod.source_type is null then 'Manual'
end as pod_source_type,

/*
identfy the out_of_period_revenue 
1. extract the month/year of delivery_date - example 3 - 2022
2. extract the month/year of printed_at - example 3- 2022
3. if year(delivery_date)=year(printed_at) and month(delivery_date)=month(printed_at) then in_period_revenue else out_of_period_revenue
*/
---------
li.tags,



li.parent_line_item_id,





case when li.product_name like 'Lily%'then substr(li.properties, strpos(li.properties, 'minimal'),9) else 'Null'end as S2,



--'Astra Shop Sales From Astra Products '
--'Astra Shop Sales From Non Astra Prudyct' 

i.source_system,
routes.name as routes,



CASE 
    WHEN ROW_NUMBER() OVER (PARTITION BY ii.invoice_id ORDER BY ii.id) = 1 THEN i.delivery_charge_amount 
    ELSE 0 
  END as delivery_charge_amount,

CASE 
    WHEN SUM(ii.price_without_tax) OVER (PARTITION BY ii.invoice_id) < 200 THEN 'Valid Delivery Charge' 
    ELSE 'Check' 
  END as delivery_charge_check,



case when i.delivery_charge_amount > 0 then 'Yes' else 'No' end as delivery_charge_applied,
--li.delivery_charge.amount as delivery_charge_amount,


case
when i.status = 0 then "Draft"
when i.status = 1 then "signed"
when i.status = 2 then "Open"
when i.status = 3 then "Printed"
when i.status = 6 then "Closed"
when i.status = 7 then "Canceled"
when i.status = 8 then "Rejected"
when i.status = 9 then "voided"

else "check_my_logic"
end as invoice_header_status,

from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = ii.customer_id
left join `floranow.erp_prod.line_items` as li on ii.line_item_id = li.id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join `floranow.Floranow_ERP.suppliers` as li_suppliers on li_suppliers.id = li.supplier_id
left join `floranow.erp_prod.order_requests` as orr on li.order_request_id = orr.id
left join  prep_registered_clients as prep_registered_clients on prep_registered_clients.financial_administration = stg_users.financial_administration
left join  prep_product_incidents AS product_incidents ON product_incidents.line_item_id = li.id
left join `floranow.erp_prod.shipments` as sh on li.shipment_id = sh.id
left join `floranow.erp_prod.proof_of_deliveries` as pod on li.proof_of_delivery_id = pod.id
left join `floranow.erp_prod.feed_sources` as fs on li.feed_source_id = fs.id
left join `floranow.erp_prod.line_items` as parent_li on parent_li.id = li.parent_line_item_id
left join `floranow.Floranow_ERP.suppliers` as parent_li_suppliers on parent_li_suppliers.id = parent_li.supplier_id
left join `floranow.erp_prod.warehouses` as w on w.id = stg_users.warehouse_id

left join `floranow.erp_prod.routes` as routes on routes.id = pod.route_id 

where ii.deleted_at is null and  ii.__hevo__marked_deleted is not true

--left join  floranow.erp_prod.products as p on p.line_item_id = li.id
--left join `floranow.erp_prod.stocks` as stock on p.stock_id = stock.id 
--left join `floranow.erp_prod.warehouses` as w on w.id = stock.warehouse_idserbi