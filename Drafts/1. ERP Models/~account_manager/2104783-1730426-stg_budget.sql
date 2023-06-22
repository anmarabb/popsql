create or replace view `floranow.Floranow_ERP.stg_budget_account_manager` as


SELECT 
account_manager,
sum(case when extract(month from date) = 9 and extract(year from date) = 2022 then budget else 0 end) as Sep_2022_budget,
sum (case when date_diff(cast(current_date() as date ),cast(date as date), MONTH) = 1 then budget else 0 end) as m_1_budget,



 FROM `floranow.Floranow_ERP.budget`  
group by account_manager