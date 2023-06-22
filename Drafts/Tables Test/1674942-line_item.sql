create or replace view `floranow.test.line_items` as

select
    id,
    count(1) as row_count,
    max(created_at) as created_at,
    max(TIMESTAMP_MILLIS(__hevo__ingested_at)) as hevo_ingested_at,
from
    `floranow.erp_prod.line_items`
group by
    id
having
    count (1) > 1
order by
    id;