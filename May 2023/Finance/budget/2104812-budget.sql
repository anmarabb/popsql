create or replace view `floranow.Floranow_ERP.budget` as



SELECT
bud.financial_administration,
bud.account_manager,
bud.city,
bud.date,
bud.client_category,
bud.budget,
DATETIME_DIFF(date(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY)),DATE_TRUNC( current_date(),month),DAY)+1 as days_total_current_month,

DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),CURRENT_DATE(),DAY) as days_remaining_current_month,

DATETIME_DIFF(CURRENT_DATE(),DATE_TRUNC( current_date(),month),day) as days_left_current_month,  --days_passed_current_month



FROM `floranow.erp_prod.budget` as bud