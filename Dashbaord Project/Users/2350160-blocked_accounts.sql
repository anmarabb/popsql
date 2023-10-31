create or replace table `floranow.Floranow_ERP.blocked_accounts` as 


WITH subquery_cte AS (
    SELECT invoices.customer_id, SUM(move_items.residual) AS total_residual
    FROM `floranow.erp_prod.move_items` As move_items
    LEFT JOIN `floranow.erp_prod.invoices` As invoices ON move_items.documentable_id = invoices.id
    WHERE invoices.status IN (3,1,6)
        AND invoices.payment_status IN (0,1)
        AND invoices.invoice_type = 0
        AND invoices.due_date > CURRENT_DATE()
        AND invoices.deleted_at IS NULL
        AND move_items.entry_type = 'DEBIT'
        AND move_items.deleted_at IS NULL
    GROUP BY invoices.customer_id
)


SELECT 

u.name as customer,
 
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

        
case 
when u.order_block is true then '1. The customer is blocked manually by Growth team, from user settings page on ERP.'
when credit_limit IS NOT NULL
    AND u.deleted_at IS NULL
    AND ( COALESCE(u.debit_balance, 0)
        + COALESCE(u.pending_balance, 0)
        + COALESCE(u.pending_order_requests_balance, 0)
        + u.credit_limit + u.credit_balance) <= 0
then '4. The users remaining credit is less than or equal to zero.'

when subquery_cte.total_residual > COALESCE(pt.unblock_amount, 0) then '3. The outstanding invoices due balance is greater than the unblocked amount configured on the user payment terms'


else 'To Be Scoped' end as blocked_account_logic,

FROM `floranow.erp_prod.users` As u
left join `floranow.erp_prod.payment_terms` as pt on pt.id = u.payment_term_id
LEFT JOIN subquery_cte ON u.id = subquery_cte.customer_id


where u.deleted_at is null
and u.email not like '%fake_%' and u.email not like '%temp_%'