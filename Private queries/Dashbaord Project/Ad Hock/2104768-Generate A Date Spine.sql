--create or replace view `floranow.Floranow_ERP.date_spine` as



select 
date_in_range,
day_number,
week_number,
min(date_in_range) over (partition by week_number) week_start,
max(date_in_range) over (partition by week_number) week_end,
month_start,
month_end,
from (SELECT 
	date_in_range,
	date_diff(date_in_range, cast('2019-07-01' as date), DAY)+1 as day_number,
	cast(trunc(date_diff(date_in_range, cast('2019-07-01' as date), DAY)/7)+1 as int64) as week_number,
  date_trunc( date_in_range, MONTH) month_start,
  last_day (date_in_range) as month_end,
	FROM UNNEST(
    	GENERATE_DATE_ARRAY(DATE('2019-07-01'), CURRENT_DATE(), INTERVAL 1 DAY)
	) AS date_in_range);


SELECT
ii.debtor_number,
week_start,
week_end,
week_number,
sum(CASE WHEN ii.printed_at >= date_spine.week_start AND ii.printed_at <= date_spine.week_end THEN 1 ELSE 0 END) as transactions_created

 
FROM `floranow.Floranow_ERP.date_spine` as date_spine
JOIN `floranow.Floranow_ERP.invoices_items`  as ii 
ON date_spine.date_in_range = ii.printed_at
GROUP BY 1, 2, 3, 4;