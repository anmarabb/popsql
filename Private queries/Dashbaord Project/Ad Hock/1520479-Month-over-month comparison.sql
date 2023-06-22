--Your goal is to build a report that shows each country's month-over-month views.

select

DATE_TRUNC(invoices.items_collection_date,month) as month,


 case 
        when invoices.financial_administration_id = 1 then 'KSA'
        when invoices.financial_administration_id = 2 then 'UAE'
        when invoices.financial_administration_id = 4 then 'kuwait'
        when invoices.financial_administration_id = 5 then 'Qatar'
        when invoices.financial_administration_id = 6 then 'Bulk'
        when invoices.financial_administration_id = 7 then 'Internal'

        else 'not-set'
        end as country,



-- Pull in current month views
sum(invoices.total_amount) as month_sales, 

-- Pull in last month views
LAG(SUM(invoices.total_amount)) OVER (PARTITION BY invoices.financial_administration_id ORDER BY DATE_TRUNC(invoices.items_collection_date,month)) AS previous_month_sales,


-- Calculate the percent change

--SUM(invoices.total_amount) / LAG(SUM(invoices.total_amount)) OVER (PARTITION BY invoices.financial_administration_id ORDER BY DATE_TRUNC(invoices.items_collection_date,month)) - 1 AS perc_change


from `floranow.erp_prod.invoices` as invoices
--LEFT JOIN floranow.erp_prod.users AS users ON users.id = invoices.customer_id

group by  month, country, invoices.financial_administration_id, invoices.items_collection_date