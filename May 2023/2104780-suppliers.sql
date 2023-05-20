create or replace view `floranow.Floranow_ERP.suppliers` as 



with
perp_manageable_accounts_suppliers as (select account_manager_id,manageable_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'Supplier'),
perp_feed_sources as (
select s.id, count(fs) as feed_souce_count from `floranow.erp_prod.feed_sources` as fs left join `floranow.erp_prod.suppliers`  as s on fs.supplier_id = s.id group by 1)

SELECT
s.id,
s.name as supplier_name,
us.name as account_manager,

s.floranow_supplier_id,

/*
CASE
    WHEN s.id   IN (2) THEN 'South Africa' 
    WHEN s.id   IN (70,71) THEN 'Ecuador' 
    WHEN s.id   IN (68) THEN 'Astra' 
    WHEN s.id   IN (183) THEN 'South Africa' 
    WHEN s.id   IN (39) THEN 'Malaysia' 
    WHEN s.id   IN (109) THEN 'Express' 
    WHEN s.id   IN (100,66,79,98) THEN 'Ethiopia' 
    WHEN s.id   IN (19,10) THEN 'Thailand' 
    WHEN s.id   IN (1,7,52,4,113,108) THEN 'Holland' 
    WHEN s.id   IN (112,20,22,80) THEN 'UAE' 
    WHEN s.id   IN (104,27,11,18,57,97,99,102,103,9) THEN 'Colombia' 
    WHEN s.id   IN (81,36,105,91,85,61,74,84,149,150,148,59,25,33,12,15,23,51,89,73,32,13,111,49,14,77,76,26,45,62,17,16,88,34,54,101,86,21,92,24,3,63,90) THEN 'Kenya' 
    ELSE 'check my logical'
END as supplier_region_2,
*/

CASE
    WHEN s.country   IN ('EC') THEN 'Ecuador' 
    WHEN s.country   IN ('SA') THEN 'Saudi' 
    WHEN s.country   IN ('ZA') THEN 'South Africa' 
    WHEN s.country   IN ('MY') THEN 'Malaysia' 
    WHEN s.country   IN ('ET') THEN 'Ethiopia' 
    WHEN s.country   IN ('TH') THEN 'Thailand' 
    WHEN s.country   IN ('NL') THEN 'Holland' 
    WHEN s.country   IN ('AE') THEN 'UAE' 
    WHEN s.country   IN ('CO') THEN 'Colombia' 
    WHEN s.country   IN ('KE') THEN 'Kenya' 
    WHEN s.country   IN ('LK') THEN 'Sri Lanka' 
    WHEN s.country   IN ('ES') THEN 'Spain' 
    WHEN s.country   IN ('TR') THEN 'Turkey' 
   WHEN s.country   IN ('CN') THEN 'China' 
   WHEN s.country   IN ('EG') THEN 'Egypt' 
   WHEN s.country   IN ('JO') THEN 'Jordan' 
   WHEN s.country   IN ('KW') THEN 'Kuwait' 
   WHEN s.country   IN ('PE') THEN 'Peru' 
   WHEN s.country   IN ('TW') THEN 'Taiwan' 
   WHEN s.country   IN ('VN') THEN 'Viatnam' 
    ELSE s.country
    END as supplier_region,


CASE
    WHEN s.id   IN (282,216,79,78,348,9,97,99,104,102,18,11,42,66,27,49,39,19,87,2,93,29,35,38,64,31,57,43,28,37,70,100,40,105,53,30,67,71,113,183,109,110,95) THEN 'Re-Selling' 
    ELSE 'Pre-selling'
END as supplier_type,


perp_feed_sources.feed_souce_count,





FROM `floranow.erp_prod.suppliers` as s
left join perp_manageable_accounts_suppliers as mas on mas.manageable_id = s.id --s.id
left join `floranow.erp_prod.account_managers` as ams on mas.account_manager_id = ams.id
left join `floranow.erp_prod.users` as us on us.id = ams.user_id
left join perp_feed_sources as perp_feed_sources on perp_feed_sources.id = s.id