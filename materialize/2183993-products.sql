drop source erp_prod cascade;



CREATE SOURCE erp_prod
  IN CLUSTER ingest_postgres
  FROM POSTGRES CONNECTION pg_connection (PUBLICATION 'mz_source')
  FOR TABLES (sections,suppliers, account_managers, manageable_accounts, stocks, users, products, locations, warehouses, line_items, feed_sources, order_requests, picking_products, product_locations, additional_items_reports);