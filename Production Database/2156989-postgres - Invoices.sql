-- Table: invoices
-- number of Credit Note for May 


SELECT
    count(invoices.number) as row_count
FROM
    invoices -- dmi.residual, dmi.balance 
    JOIN users AS customers ON customers.id = invoices.customer_id
    join move_items cmi on cmi.documentable_type = 'Invoice'
    and cmi.documentable_id = invoices.id
    and cmi.entry_type = 'CREDIT'
WHERE
    customers.warehouse_id = 79 -- Qassim
    and customers.odoo_code like 'BQ-%'
    and invoices.status in (1, 3, 6)
    and invoices.invoice_type = 1
    and invoices.printed_at >= '2023-05-01'
    and invoices.printed_at < '2023-06-01';