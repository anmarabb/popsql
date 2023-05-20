--create or replace view `floranow.Floranow_ERP.users` as 


-- prep query to pull in all raw data
    with 
    prep_MTD as (select customer_id , sum(total_price_without_tax) as MTD  from `floranow.erp_prod.line_items` where date_diff(cast(created_at as date), cast(current_date() as date ), MONTH) = 0 group by customer_id ), 
    prep_LMTD as (select customer_id , sum(total_price_without_tax) as LMTD  from `floranow.erp_prod.line_items` where date_diff(cast(current_date() as date ),cast(created_at as date), MONTH) = 1 and extract(day FROM cast(created_at as date)) <= extract(day FROM cast(current_date() as date)) group by customer_id ),
    prep_LMT as (select customer_id , sum(total_price_without_tax) as Last_Month_Total  from `floranow.erp_prod.line_items` where date_diff(cast(current_date() as date ),cast(created_at as date), MONTH) = 1  group by customer_id ),
    prep_LTV as  (select customer_id , sum(total_price_without_tax) as LTV from `floranow.erp_prod.line_items`  group by customer_id),


    prep_last_drop_date as (select customer_id,  max(i.printed_at) as last_drop_date  from `floranow.erp_prod.invoices` as i  group by customer_id ),


    prep_client_table_orders as ( select customer_id,  max(li.created_at) as last_order_date, DATE_DIFF(cast(CURRENT_DATE() as date) , cast(max(li.created_at) as date),day ) as days_since_last_order from `floranow.erp_prod.line_items` as li group by customer_id),
    prep_manageable_accounts as (select account_manager_id,manageable_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User')




SELECT 
u.id, --erp_user_id
u.name,
u.debtor_number,
user_categories.name As client_category,
u2.name As account_manager,

u.country,
u.state,
case --financial ID
        when u.financial_administration_id = 1 then 'KSA'
        when u.financial_administration_id = 2 then 'UAE'
        when u.financial_administration_id = 4 then 'kuwait'
        when u.financial_administration_id = 5 then 'Qatar'
        when u.financial_administration_id = 6 then 'Bulk'
        when u.financial_administration_id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,

CASE --city transform
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
    ELSE 'check_my_logic'
    END as city,


-- others
u.created_at,


case when u.internal is true then 'Internal' else 'External' end as account_type,
--Access
 u.has_all_warehouses_access, 
 u.has_trade_access, 
 u.allow_due_invoices, 
 u.accessible_warehouses, 

u.order_block, 




u.credit_limit,
abs(u.credit_balance) as used_credit, --Credit Balance

(u.credit_limit - abs(u.credit_balance) + u.credit_note_balance) as remaning_credit,

u.credit_note_balance, --Credit Note Balance




case when  u.order_block is true then '1' end as total_blocked,

case 
    when u.customer_type = 0 then 'reseller'
    when u.customer_type = 1 then 'retail'
    when u.customer_type = 2 then 'fob'
    when u.customer_type = 3 then 'cif'
    else 'check_my_logic'
    end as customer_type,


case 
        
        when u.payment_term_id = 12 then 'Without invoicing'
        when u.payment_term_id = 4 then 'Cash on Delivery'
        when u.payment_term_id = 6 then 'On the 25th of the next Month'
        when u.payment_term_id = 7 then '7 Days After Delivery'
        when u.payment_term_id = 2 then '10 Days After Delivery'
        when u.payment_term_id = 2 then '14 Days After Delivery'
        when u.payment_term_id = 10 then '15 Days After Delivery'
        when u.payment_term_id = 5 then '30 Days After Delivery'
        when u.payment_term_id = 9 then '45 Days After Delivery'
        when u.payment_term_id = 10 then '60 Days After Delivery'
        when u.payment_term_id = 3 then 'Pre Paid UAE'
        when u.payment_term_id = 46 then 'Prepayment Bulk USD'
        when u.payment_term_id = 47 then 'Prepayment Bulk EUR'
        when u.payment_term_id = 48 then 'Due On the 7th of the Next Month'
        else 'check_my_logic'
        end as payment_term,


case --client engagment Status based on last order date (from line_item)
 when prep_client_table_orders.days_since_last_order <= 7 then 'active'
 --when DATE_DIFF(cast(CURRENT_DATE() as date) , cast(max(prep_last_drop_date.last_drop_date) as date),day ) <= 7 then 'active'
 when prep_client_table_orders.days_since_last_order > 7 and prep_client_table_orders.days_since_last_order <= 30 then 'inactive'
 when prep_client_table_orders.days_since_last_order > 30 then 'churned'
 else 'churned'
 end as Account_Status,



max(li.created_at) as last_order_date,
max(case when li.supplier_id IN (109,71) then li.created_at end) as last_express_order_date,


prep_LTV.LTV as LTV,
prep_LMT.Last_Month_Total as LMT,
prep_LMTD.LMTD,
prep_MTD.MTD,
prep_client_table_orders.days_since_last_order,


--case when  round(((abs(u.credit_balance)/u.credit_limit+1)*100),2) >= 80 then 'Risk' else 'OK' end as Balance_State ,
--sum(li.total_price_without_tax) over (partition by u.id)   as MTD2,
--statement_of_accounts.total_amount As total_statement_amount,
--sum(case when li.supplier_id IN (109,71) then li.total_price_without_tax else 0 end) as express_sales,
--max(li.created_at) over (partition by u.name) as last_order_date,


FROM `floranow.erp_prod.users` As u
left join floranow.erp_prod.line_items AS li ON li.customer_id = u.id
left join floranow.erp_prod.user_categories AS user_categories ON u.user_category_id = user_categories.id
 -- left join floranow.erp_prod.suppliers AS suppliers ON li.supplier_id = suppliers.id
left join prep_manageable_accounts as ma on ma.manageable_id = u.id 
left join `floranow.erp_prod.account_managers` as account_m on ma.account_manager_id = account_m.id
left join `floranow.erp_prod.users` as u2 on u2.id = account_m.user_id
left join floranow.erp_prod.statement_of_accounts AS statement_of_accounts ON statement_of_accounts.user_id = u.id
left join prep_MTD on u.id = prep_MTD.customer_id
left join prep_LMTD on u.id = prep_LMTD.customer_id
left join prep_LMT on u.id = prep_LMT.customer_id
left join prep_LTV on u.id = prep_LTV.customer_id
left join prep_last_drop_date on u.id = prep_last_drop_date.customer_id

left join prep_client_table_orders on u.id = prep_client_table_orders.customer_id

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,LTV,LMTD,LMT,MTD, days_since_last_order

order by prep_MTD.MTD desc