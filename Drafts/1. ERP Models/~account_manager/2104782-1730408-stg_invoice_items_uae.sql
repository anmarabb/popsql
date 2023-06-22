with
prep_manageable_accounts as (select account_manager_id , manageable_id from `floranow.erp_prod.manageable_accounts` where manageable_type = 'User')

select
u3.name as account_manager,

sum (case when date_diff(cast(current_date() as date ),cast(i.printed_at as date), MONTH) = 1 then ii.price_without_tax else 0 end) as m_1_invoice,
sum (case when date_diff(cast(current_date() as date ),cast(i.printed_at as date), MONTH) = 2 then ii.price_without_tax else 0 end) as m_2_invoice,
sum (case when date_diff(cast(current_date() as date ),cast(i.printed_at as date), MONTH) = 3 then ii.price_without_tax else 0 end) as m_3_invoice,


max(stg_budget_account_manager.m_1_budget) as m_1_budget,

round(SAFE_DIVIDE((case when date_diff(cast(current_date() as date ),cast(i.printed_at as date), MONTH) = 1 then ii.price_without_tax else 0 end) , max(stg_budget_account_manager.m_1_budget)) ,2) as budget_achievement_rate,

round(SAFE_DIVIDE(sum(case when extract(month from i.printed_at) = 9 and extract(year from i.printed_at) = 2022 then ii.price_without_tax else 0 end) , max(stg_budget_account_manager.Sep_2022_budget)) ,2) as budget_achievement_rate,


--sum(case when extract(month from i.printed_at) = 9 and extract(year from i.printed_at) = 2022 then ii.price_without_tax else 0 end) as Sep_2022_invoice,
--max(stg_budget_account_manager.Sep_2022_budget) as Sep_2022_budget,






from `floranow.erp_prod.invoice_items`  as ii 
left join `floranow.erp_prod.invoices` as i on ii.invoice_id = i.id
left join prep_manageable_accounts as ma on ii.customer_id = ma.manageable_id
left join `floranow.erp_prod.account_managers` as am on ma.account_manager_id = am.id
left join `floranow.erp_prod.users` as u3 on am.user_id = u3.id
left join `floranow.Floranow_ERP.stg_budget_account_manager` as stg_budget_account_manager on stg_budget_account_manager.account_manager = u3.name

where ii.status = 'APPROVED' and ii.deleted_at is null and i.financial_administration_id=2 and u3.internal is true


group by u3.name
order by u3.name