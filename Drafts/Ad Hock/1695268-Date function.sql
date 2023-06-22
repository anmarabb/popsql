where date_diff(cast(i.printed_at as date), cast(current_date() as date ), MONTH) = 0 as MTD


when date_diff(current_date() , date(i.printed_at) , YEAR) = 0  then 'YTD' 

when date_diff(current_date() ,date(li.created_at), MONTH) = 1 then 'M-1' 



where i.printed_at = DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY) as  yesterday

where fii.invoice_date >= '2022-02-01'  and fii.invoice_date <  '2022-02-18'


TIMESTAMP_DIFF(LEAD(pi.created_at) OVER(PARTITION BY pi.line_item_id ORDER BY  pi.line_item_id,pi.created_at), pi.created_at,MILLISECOND) AS millisecond_difference,


select

i.printed_at as drop_date,
--current_date() as curent_date,
--CURRENT_TIMESTAMP() as current_timestamps,

DATE_SUB ( i.printed_at, INTERVAL 5 DAY) AS five_days_ago,
DATE_ADD(i.printed_at, INTERVAL 5 DAY) AS five_days_later,

date_diff(cast(i.printed_at as date), cast(current_date() as date ), MONTH) = 0 as MTD,
--date_diff(cast(current_date() as date), cast(i.printed_at as date ), MONTH) as months_between,
--date_diff(cast(current_date() as date), cast(i.printed_at as date), day) as days_between,
date_diff(current_date(), i.printed_at , day) as days_between,

DATE_TRUNC(i.printed_at,month) as first_day_of_month, --first day of month, bring beginning of date_part.
last_day (i.printed_at) as last_day_of_month,
--DATE_ADD(DATE'2021-05-20', INTERVAL (-1*EXTRACT(DAY FROM DATE'2021-05-20')+1) day), --first_day_of_month
--DATE_SUB(DATE'2021-05-20', INTERVAL (EXTRACT(DAY FROM DATE'2021-05-20')-1) day), --first_day_of_month

extract  (day from i.printed_at) as day, 
extract  (month from i.printed_at) as month, 
extract  (year from i.printed_at) as year, 



DATE_DIFF(i.due_date, i.printed_at, DAY) AS date_diff_days,


case 
  when date(li.created_at) >= DATE_TRUNC(current_date(),month) then 'MTD'
  when date_diff(current_date() ,date(li.created_at), MONTH) = 1 then 'M-1' 
  when date_diff(current_date() ,date(li.created_at), MONTH) = 2 then 'M-2' 
else null end ,

 DATE_TRUNC( current_date(),DAY) first_hour_of_current_day,
 DATE_TRUNC( current_date(),YEAR) first_month_of_current_year,



DATE_TRUNC( current_date(),month) first_day_of_current_month,
--– add one month to the first day of the current month. This will return first day of the next month.
DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH) as first_day_of_next_month,

--– subtract one day from the first day of the next month. This will help return last day of the current month.
DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY) as last_day_of_current_month,

--return the number of days remaining in the current month by calculating date difference between the last day of the current month and current date using DATE_DIFF fucntion.
DATETIME_DIFF(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY),CURRENT_DATE(),DAY) as days_remaining_current_month,
from `floranow.erp_prod.invoices` as i

DATETIME_DIFF(date(DATETIME_SUB(DATETIME_ADD(DATETIME_TRUNC(CURRENT_DATE(),MONTH), INTERVAL 1 MONTH), INTERVAL 1 DAY)),DATE_TRUNC( current_date(),month),DAY)+1 as days_total_current_month,

DATETIME_DIFF(CURRENT_DATE(),DATE_TRUNC( current_date(),month),day) as days_left_current_month,

where i.printed_at is not null