create or replace table `floranow.Floranow_ERP.users` as 



with 

prep_manageable_accounts as (select account_manager_id,manageable_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User'),
prep_country as (select distinct country_iso_code  as code, country_name from `floranow.erp_prod.country` )

SELECT 
u.id, --erp_user_id
u.email,
u.phone_number,
u.bank_account_id,
u.name as customer,
u.debtor_number,
u.country as row_country,
c.country_name as country,

case 
--when u.order_blocked_status = 0  and u.allow_due_invoices is true then 'Temporal Unblocked By Finance' --88
when u.order_blocked_status = 0 then 'Unblocked'
when u.order_blocked_status = 1 then 'Manually Blocked'
when u.order_blocked_status = 2 then 'Exceeded Credit Limit'
when u.order_blocked_status = 3 then 'Overdue Invoices'
else null end as order_blocked_status,




u.state,
u.created_at,

u.order_block as row_order_block, 

case when u.order_blocked_status in (1,2,3) then 'Blocked' else 'Unblocked' end as order_block,

case when  u.order_blocked_status in (1,2,3) then '1' end as total_blocked,

case when  user_categories.name = 'Closed' then 'Deleted' else 'in business' end as deleted_accounts,

--case when u.allow_due_invoices is true then 'Unblocked' else 'Blocked' end as order_block,
--case when  u.allow_due_invoices is not true then '1' end as total_blocked,



u.credit_limit,
abs(u.credit_balance) as credit_balance, --Credit Balance


--mercy Logic
(u.credit_limit - abs(u.credit_balance) ) as used_credit_limit,  --Available Credit Limit

--(u.credit_limit - abs(u.credit_balance) + u.credit_note_balance) as available_credit_limit,  --Available Credit Limit

u.credit_note_balance, --Credit Note Balance



user_categories.name As client_category,
u2.name As account_manager,

case when u.internal is true then 'Internal' else 'External' end as account_type,
case when date_diff(cast(current_date() as date ),cast(u.created_at as date), MONTH) <10 then 1 else 0 end as new_client,


case --financial ID
        when u.financial_administration_id = 1 then 'KSA'
        when u.financial_administration_id = 2 then 'UAE'
        when u.financial_administration_id = 3 then 'Jordan'
        when u.financial_administration_id = 4 then 'kuwait'
        when u.financial_administration_id = 5 then 'Qatar'
        when u.financial_administration_id = 6 then 'Bulk'
        when u.financial_administration_id = 7 then 'Internal'
        else 'check_my_logic'
        end as financial_administration,


INITCAP(u.city) as city,



u.city as row_city,


--Access
 u.has_all_warehouses_access, 
 u.has_trade_access, 
 u.allow_due_invoices, 
 u.accessible_warehouses, 
u.warehouse_id,

case 
when u.customer_type = 0 then u.name 
when u.customer_type in (2,3)  then 'Bulk' 
else 'Retail' 
end as reseller,

case 
when u.customer_type = 1 then u.name 
when u.customer_type in (2,3)  then 'Bulk' 
else 'Reseller' 
end as retail,

case 
    when u.customer_type = 0 then 'reseller'
    when u.customer_type = 1 then 'retail'
    when u.customer_type = 2 then 'fob'
    when u.customer_type = 3 then 'cif'
    else 'check_my_logic'
    end as customer_type,

u.customer_type as row_customer_type,
/*
case 
        when u.payment_term_id = 4 then 'Cash on Delivery'
        when u.payment_term_id = 3 then 'Pre Paid UAE'
        when u.payment_term_id = 7 then '7 Days After Delivery'
        when u.payment_term_id = 48 then 'Due On the 7th of the Next Month'
        when u.payment_term_id = 5 then '30 Days After Delivery'
        when u.payment_term_id = 49 then 'On the 15th of the Next Month'
        when u.payment_term_id = 2 then '10 Days After Delivery'
        when u.payment_term_id = 46 then 'Prepayment Bulk USD'
        when u.payment_term_id = 11 then '90 Days After Delivery'
        when u.payment_term_id = 12 then 'Without invoicing'
        when u.payment_term_id = 13 then 'Prepayment'
        when u.payment_term_id = 9 then '45 Days After Delivery' 
        when u.payment_term_id = 8 then '10 Days After Delivery'
        when u.payment_term_id = 10 then '60 Days After Delivery'
        when u.payment_term_id = 47 then 'Prepayment Bulk EUR'
        when u.payment_term_id = 50 then 'On the 28th of the Next Month'
        when u.payment_term_id is null then 'payment term not configured in ERP'
        when u.payment_term_id = 6 then 'On the 25th of the next Month'        
        else 'check_my_logic'
        end as payment_term,
*/

pt.name as payment_term,
u.payment_term_id as row_payment_term_id,


stg_orders.last_order_date as last_order_date,
stg_orders.days_since_last_order as days_since_last_order,
stg_orders.MTD_order_value as MTD,
stg_orders.LMTD_order_value as LMTD,
stg_orders.m_1 as m_1,
stg_orders.m_2 as m_2,
stg_orders.M_3 as M_3,
stg_orders.last_express_order_date as last_express_order_date,


stg_invoices.total_outstanding_balance, --Total Outstanding Balance
stg_invoices.total_outstanding_with_proforma,
stg_invoices.proforma_amount,
stg_invoices.total_lifetime_value_collectd,
stg_invoices.outstanding_count,

stg_invoices.up_to_30_days as up_to_30_days,
stg_invoices.between_31_to_60_days as between_31_to_60_days,
stg_invoices.between_61_to_90_days as between_61_to_90_days,
stg_invoices.between_91_to_120_days	 as between_91_to_120_days,
stg_invoices.more_than_120_days as more_than_120_days,

stg_invoices.m_1_remaining as m_1_remaining,
stg_invoices.m_2_remaining as m_2_remaining,
stg_invoices.m_3_remaining as m_3_remaining,
stg_invoices.MTD_remaining as MTD_remaining,



stg_invoices.total_lifetime_value as total_lifetime_value,
stg_invoices.days_since_last_drop as days_since_last_drop,

case when stg_invoices.client_value_segments is null then 'Zero order clinets' else stg_invoices.client_value_segments end as client_value_segments,



stg_invoices.avg_monthly_value as avg_monthly_value,
stg_invoices.success_rate as success_rate,
stg_invoices.creditNote_perc as creditNote_perc,
stg_invoices.first_order_date as first_order_date,
stg_invoices.last_drop_date,
stg_invoices.logic_qa_1,
stg_invoices.total_active_months,

stg_invoices.invoice_financial_administration_id,


stg_invoice_items_customer_id.MTD_invoice_value,
stg_invoice_items_customer_id.MTD_invoice_value_usd,

stg_invoice_items_customer_id.LMTD_invoice_value,
stg_invoice_items_customer_id.LMTD_invoice_value_usd,

stg_invoice_items_customer_id.m_1_invoice,
stg_invoice_items_customer_id.m_1_invoice_usd,

stg_invoice_items_customer_id.m_2_invoice,
stg_invoice_items_customer_id.m_2_invoice_usd,



stg_invoice_items_customer_id.m_3_invoice,
stg_invoice_items_customer_id.manual_account_status as manual_account_status,
stg_invoice_items_customer_id.ytd_invoice,
stg_invoice_items_customer_id.y_1_invoice,
stg_invoice_items_customer_id.y_2_invoice,
stg_invoice_items_customer_id.online_perc,
stg_invoice_items_customer_id.offline_perc,
stg_invoice_items_customer_id.auto_margin_perc,
stg_invoice_items_customer_id.MTD_auto_margin_perc,
stg_invoice_items_customer_id.CN_perc,

stg_invoice_items_customer_id.MTD_orders,
stg_invoice_items_customer_id.m_1_orders,
stg_invoice_items_customer_id.m_2_orders,
stg_invoice_items_customer_id.m_3_orders,
stg_invoice_items_customer_id.ytd_orders,






stg_paymnets_customer_id.MTD_paymnets,
stg_paymnets_customer_id.LMTD_paymnets,
stg_paymnets_customer_id.m_1_paymnets,
stg_paymnets_customer_id.m_2_paymnets,
stg_paymnets_customer_id.m_3_paymnets,


stg_invoice_items_customer_id.MTD_holland,
stg_invoice_items_customer_id.LMTD_holland,
stg_invoice_items_customer_id.m_1_holland,
stg_invoice_items_customer_id.m_2_holland,
stg_invoice_items_customer_id.m_3_holland,
stg_invoice_items_customer_id.ytd_holland,


stg_invoice_items_customer_id.wtd_holland,
stg_invoice_items_customer_id.w_1_holland,
stg_invoice_items_customer_id.w_2_holland,
stg_invoice_items_customer_id.w_3_holland,


case 
when stg_invoices.days_since_last_drop <= 7 then 'active'
when stg_invoices.days_since_last_drop > 7 and stg_invoices.days_since_last_drop  <= 30 then 'inactive'
when stg_invoices.days_since_last_drop  > 30 then 'churned'
else 'churned'
end as account_status_invoice,



case when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 7 or stg_invoice_items_customer_id.manual_account_status = 'active' then 1 else 0 end as active_clients,

 
case 
    --when stg_invoice_items_customer_id.manual_account_status = 'active' then 'active'
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) < 8  then 'active'
    when stg_invoice_items_customer_id.manual_account_status in ('active') then 'active'
    when  max(stg_invoice_items_customer_id.standing_order_account_status) in ('active') then 'active'
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) >= 8 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 30 then 'inactive'
    when DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) > 30 then 'churned'
    else 'churned'
    end as Account_Status,



case 
    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <8 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) <= 7 then 'new_active' 
        when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <8 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) >7 then 'new_inactive'  
 
    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <8 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) is not null then 'new_inactive'  

    when date_diff(cast(current_date() as date ),cast(max(u.created_at) as date), MONTH) <8 and DATE_DIFF(CAST(CURRENT_DATE() AS date), CAST(MAX(li.created_at) AS date),day ) is null then'new_not_activated_yet'   
    else 'old_client'
    end as acquisition_status,

case 
when u.master_id in (974,1119,407,1231,911,64,611) or u.debtor_number in ('10012','10011') then 'Alissar Flowers'

when u.master_id in (322) then 'Maison Des Fleurs'


when u.master_id in (1003) then 'FIKRA W HADIYA'
when u.master_id in (1423) then 'Vera La Fleurisite Floral Boutique'
else 'No Master'
end as master_account,

ro.name as route_name,

UPPER(u.city) as city_Upper,

concat( "https://erp.floranow.com/users/", u.id) as user_link,

case 
when u.company_id = 3 then 'Bloomax Flowers LTD'
when u.company_id = 2 then 'Global Floral Arabia tr'
when u.company_id = 1 then 'Flora Express Flower Trading LLC'
else  'cheack'
end as company_name,

stg_invoices.source_system,


w.name as warehouses,
 case when u.email  like '%fake_%' or u.email  like '%temp_%' then 'fake_temp' else 'Normal' end as fake_temp,



 CASE
           WHEN u.debtor_number IN (
               '4383', '132005', '132013', '132014', '132031', '132077', '132081', '132083', '132091', '132092',
               '132101', '132102', '132104', '132105', '132106', '132107', '132113', '132120', '132134', '132135',
               '132139', '132152', '132153', '132155', '132166', '132170', '132185', '132192', '132194', '132200',
               '132202', '132203', '132206', '132208', '132214', '132216', '132220', '132228', '132234', '132245',
               '132250', '132369', '132437', 'BF60022', 'BF60094', 'BF601', 'BF60234', 'EVEMED', 'BF60257',
               'BF60262', 'BF60274', 'BF60275', 'BF60279', 'BF60298', 'BF603', 'BF60300', 'BF60308',
               '134249', 'BF60353', 'BF60355', 'BF60356', 'BF604', '134152', '134153', '134156', '134154',
               '134157', 'khaled', 'aaldridi', '134155', '134159', 'm.salah', 'ASHIK', '134002', 'ashik',
               '134160', '131168', '131318', '131241', '131342', '131220', '131160', '131246', 'ASTMED', 'lndmed',
               '131140', '131137', '131199', '131170', '131069', '131247', '131245', '131123', '131017', '131119',
               '131298', '131317', '131003', '131008', '131389', '131206', '131259', '131334', '131315', '131019',
               '131231', '131321', '131294', '131312', '131120', '131324', '131037', '131018', '131314', '131207',
               '131105', '131330', '131252', '131237', '131038', '131122', '131020', '131230', '131092', '131413',
               '131326', '131186', '131178', '131185', '131323', '131327', '131145', '131035', '131125', '131264',
               '131166', '131030', '131193', '131063', '131060', '131192', '131216', '131176', '131223', '131194',
               '131083', '131094', '131050', '131182', '131213', '131283', '131196', '131202', '131335', '131278',
               '131129', '131205', '131179', '131204', '131124', '131046', '131224', '131225', '131261', '131372',
               '131184', '131180', '131101', '131203', '131087', '131228', '131197', '131347', 'BJ70005', 'BJ70013',
               'BJ70083', 'BJ70126', 'BJ70114', 'BJ21479', 'BJ70061', '134191', '134193', '134202', '134219',
               '134015', '134053', '134052', '134017', '134016', '134038', '134044', '134081', '134055', '134083',
               '134078', '134012', '134032', '134046', '134072', '134273', 'moutaz', 'alamohammed', '130312',
               '130303', '130305', '130311', 'ASTRUH', 's.hussain', '130309', '130310', '130313', 'm.bilal',
               'noushad', '130528', 'LNDRUH', '134314', 'scriyadh', '130314', '130521', '130304', '130307',
               '130306', 'm.tayseer', '4769', '134005', '132008', '132009', '134064', '134278', '132145', '132260',
               '132261', '132262', '132263', '132264', '132265', '132266', '132267', '132268', '132269', '132270',
               '132271', '132272', '132273', '132274', '132350', '132351', '132352', '132353', '132354', '132355',
               '132356', '132358', '132359', '132360', '132361', '132362', '132363', '132364', '132365', '132366',
               '132367', '132368', '132370', '132371', '132372', '132373', '132374', '132375', '132376', '132377',
               '132378', '132379', '132380', '132382', '132383', '132384', '132385', '132386', '132387', '132388',
               '132389', '132390', '132391', '132393', '132394', '132395', '132396', '132397', '132398', '132399',
               '132400', '132401', '132402', '132403', '132404', '132405', '132406', '132407', '132408', '132409',
               '132410', '132411', '132412', '132413', '132414', '132416', '132417', '132418', '132419', '132420',
               '132421', '132422', '132423', '132424', '132425', '132426', '130205', '132427', '132428', '132429',
               '130136', '130035', '130227', '132430', '132431', '132432', '130074', '132433', '130182', '130174',
               'ABDURAFEEQ', 'ALIAKBAR', 'ANSONJAMAL', 'BABUL', 'EVEDMM', 'FAISAL', '130192', 'faisal',
               'hani', 'hebeeb', 'Irshad', '130158', 'j.cabarles', '130079', 'jazer', 'jojo', 'JUNAIDALI',
               '130180', '130124', '130131', '130135', 'k.khalel', 'LNDDMM', 'MDMONIR', 'MPUTHIYAPURAYIL',
               '130010', '130213', 'NAWAF', 'NISARMON', '130149', 'salah', 'sameh', 'SAMEHKHAIRY', 'UNAIS',
               'ASTHAF', '130151', 'bf60118', '130110', '130111', 'EVEHAF', 'hafartest', 'KHALID', '130146',
               'LNDHAF', 'MCHAFAR', 'MDAZAD', 'HAILTST', 'bhmarketing', 'demo_floranow', 'LNDHAI',
               '130073', '130164', '130125', '130155', '134145', '130165', 'ASTHAI', '130137', '130093', '130152',
               '130092', '130075', '130077', '130123', '130095', 'cashhail', 'EVEHAI', 'deenislam', 'WIJDAN',
               'mariamraja', 'anas', 'cashcustomerhail2', 'FLORANOWVIP', 'FNCLASSA', 'WALKINCUSTOMER',
               '130101', 'EVEJOU', 'ASTJOU', 'BJ00003', 'LNDJOU', '130178', '130108', '130159', '130191',
               '130156', 'bq40111111', '130173', '130154', '130243', '130254', 'bq40dsadas', 'EVEQAS', 'FNQSIM',
               'fntestqassim', 'LNDQAS', 'walkintestqassim', '133209', '133206', '133082', '133071', '133132',
               '133042', '133049', '133080', '133180', '133179', '133064', '133229', '133025', '133104', '133224',
               '133073', '133266', '133230', '13079', '133084', '133197', '133149', '133150', '133164', '133145',
               '133156', '133163', '133146', '133182', '133127', '133155', '133153', '133184', '133154', '133239',
               '133166', '133272', '133126', '133160', '133157', '133158', '133159', '133125', '133131', '133188',
               '133101', '133173', '133074', '133069', '133186', '133176', '133148', '133205', '133151', '133175',
               '133161', '133190', '133147', '133048', '133072', '133121', '133248', '133227', '133130', '133057',
               '133168', '133162', '133171', '133172', '133191', '133167', '133193', '133170', '133194', '133189',
               'YASER', 'm.masri', 'mmustafa', 'FSTUU'
           )
           THEN 'Faisal Comment'
           ELSE 'Normal'
       END AS comment,



FROM `floranow.erp_prod.users` As u
left join floranow.erp_prod.line_items AS li ON li.customer_id = u.id
left join floranow.erp_prod.user_categories AS user_categories ON u.user_category_id = user_categories.id
left join prep_manageable_accounts as ma on ma.manageable_id = u.id 
left join `floranow.erp_prod.account_managers` as account_m on ma.account_manager_id = account_m.id
left join `floranow.erp_prod.users` as u2 on u2.id = account_m.user_id

left join `floranow.Floranow_ERP.stg_orders` as stg_orders on stg_orders.customer_id = u.id
left join `floranow.Floranow_ERP.stg_invoices` as stg_invoices on stg_invoices.customer_id = u.id
left join prep_country as c on u.country = c.code

left join `floranow.Floranow_ERP.stg_invoice_items_customer_id` as stg_invoice_items_customer_id on stg_invoice_items_customer_id.customer_id = u.id

left join `floranow.Floranow_ERP.stg_paymnets_customer_id` as stg_paymnets_customer_id on stg_paymnets_customer_id.customer_id = u.id
left join `floranow.erp_prod.routes` As ro on ro.id = u.route_id
left join `floranow.erp_prod.payment_terms` as pt on pt.id = u.payment_term_id

left join `floranow.erp_prod.financial_administrations` as f on f.id = u.financial_administration_id
left join `floranow.erp_prod.warehouses`  w on u.warehouse_id = w.id


--where u.email not like '%fake_%' and u.email not like '%temp_%'

--where u.debtor_number = '10622'


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,master_account,route_name,city_Upper,user_link,company_name,warehouses,MTD_holland,LMTD_holland,m_1_holland,m_2_holland,m_3_holland,ytd_holland,wtd_holland,w_1_holland,w_2_holland,w_3_holland,source_system,comment