--In this exercise, you will calculate the percent of sales for each city relative to the entire markets and relative to that cities's country


select

stg_users.financial_administration as country,
stg_users.city as city,

sum(i.total_amount) as city_sales,
sum(sum(i.total_amount)) over (partition by stg_users.financial_administration) as country_sales ,
round((sum(i.total_amount)/sum(sum(i.total_amount)) over (partition by stg_users.financial_administration)*100),2) as perc_city_country_sales,


sum(sum(i.total_amount)) over () as global_sales,
round((sum(i.total_amount)/sum(sum(i.total_amount)) over ()*100),2) as perc_global_sales,


from `floranow.erp_prod.invoices` as i
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = i.customer_id
group by country, city
order by country desc;


select
stg_users.financial_administration as country,
stg_users.city as city,


sum(ii.price_without_tax) as city_sales,
sum(sum(ii.price_without_tax)) over (partition by stg_users.financial_administration) as country_sales ,
round((sum(ii.price_without_tax)/sum(sum(ii.price_without_tax)) over (partition by stg_users.financial_administration)*100),2) as perc_city_country_sales,


sum(sum(ii.price_without_tax)) over () as global_sales,
round((sum(ii.price_without_tax)/sum(sum(ii.price_without_tax)) over ()*100),2) as perc_global_sales,


from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.Floranow_ERP.users` as stg_users on stg_users.id = ii.customer_id
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
--stg_users.financial_administration ='UAE' and 
where ii.status ='APPROVED'  and date_diff(current_date() ,date(i.printed_at), MONTH) = 1
group by country, city
order by country desc