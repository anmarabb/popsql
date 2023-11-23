create or replace table `floranow.Floranow_ERP.vendor_publishing` as 

WITH OfferPrices AS (
  SELECT
    COALESCE((CASE WHEN p.approval = TRUE THEN p.price END),p.price) AS price, -- last aprroved price or default price
    p.stock_id,
    ROW_NUMBER() OVER (PARTITION BY p.stock_id ORDER BY p.created_at DESC) AS PriceRank
  FROM floranow.vendor_portal_prod.prices AS p
  WHERE deleted_at is NULL
),
OfferSpecs AS (
  SELECT
    s.stock_id,
    MAX(CASE WHEN spec.specification_number = 1 THEN spec.specification_name END) AS p1_name,
    MAX(CASE WHEN spec.specification_number = 1 THEN s.flori_value_name END) AS p1,
    MAX(CASE WHEN spec.specification_number = 2 THEN spec.specification_name END) AS p2_name,
    MAX(CASE WHEN spec.specification_number = 2 THEN s.flori_value_name END) AS p2,
    MAX(CASE WHEN spec.specification_number = 3 THEN spec.specification_name END) AS p3_name,
    MAX(CASE WHEN spec.specification_number = 3 THEN s.flori_value_name END) AS p3,
    MAX(CASE WHEN spec.specification_number = 4 THEN spec.specification_name END) AS p4_name,
    MAX(CASE WHEN spec.specification_number = 4 THEN s.flori_value_name END) AS p4,
  FROM floranow.vendor_portal_prod.specification_values s
  LEFT JOIN floranow.vendor_portal_prod.specifications AS spec ON s.specification_id = spec.id
  GROUP BY s.stock_id
)
SELECT
  o.id AS offer_id,
  g.name AS supplier,
  o.name AS offer_name,
  ot.name AS offer_template,
  a.floranow_account_id,
  CASE
    WHEN ot.name LIKE '%Event%' THEN 'Event'
    WHEN ot.name LIKE '%Regular%' THEN 'Regular'
    WHEN ot.name LIKE '%Avails%' THEN 'Avails'
    ELSE 'others'
  END AS offer_type,
  COUNT(o.id) OVER (PARTITION BY g.name) AS publishing_time_per_supplier,
  st.status AS stocks_status,
  DATE_DIFF(st.created_at, o.created_at, DAY) AS created_at_days_difference,
  DATE_DIFF(st.updated_at, o.updated_at, DAY) AS updated_at_days_difference,
  CONCAT(g.name, DATE(o.created_at)) AS publish_id,
  o.created_at AS offer_created_at,
  o.updated_at AS offer_updated_at,
  o.departure_date_time AS offer_departure_date,
  o.status AS offer_status,
  st.created_at AS stocks_created_at,
  st.updated_at AS stocks_updated_at,
  st.deleted_at AS stocks_deleted_at,
  st.last_published_at AS stocks_last_published_at,
  MAX(o.created_at) OVER (PARTITION BY g.name) AS last_publisheded, --need to update it to be on last (updated_at)
  p.name AS product,
  p.color,
  p.flori_main_group_name AS product_group,
  p.flori_sub_group_name AS product_sub_group,
  st.quantity,
  st.remain_quantity,
  st.minimum_order_quantity,
  COUNT(DISTINCT g.id) OVER () AS registered_suppliers,
  s.account_manager,
  s.supplier_region,
  MAX(DATE(o.departure_date_time)) OVER (PARTITION BY g.name, ot.name) AS last_departure_date,
  DATE_DIFF(MAX(DATE(o.departure_date_time)) OVER (PARTITION BY g.name), CURRENT_DATE(), DAY) AS days_to_next_departure,
  CASE
    WHEN DATE_DIFF(MAX(DATE(o.departure_date_time)) OVER (PARTITION BY g.name), CURRENT_DATE(), DAY) IN (3, 4, 5, 6, 7, 8, 9) THEN 'active'
    ELSE 'inactive'
  END AS supplier_status,
  f.name AS feed_name,

  
  rp.price AS price,
  spec.p1,
  spec.p2,
  spec.p3,
  spec.p4,
  st.packing_method_data.box_type AS box_type,
  st.packing_method_data.volumetric_weight AS volumetric_weight,
  st.packing_method_data.packing_rate AS packing_rate,
  st.packing_method_data.stem_weight AS stem_weight,
  st.supplier_product_id,
  st.last_published_quantity AS last_published_quantity
  
FROM floranow.vendor_portal_prod.stocks AS st
LEFT JOIN floranow.vendor_portal_prod.offers AS o ON st.stockable_id = o.id
LEFT JOIN floranow.vendor_portal_prod.products AS p ON st.product_id = p.id
LEFT JOIN floranow.vendor_portal_prod.growers AS g ON g.id = p.grower_id
LEFT JOIN floranow.vendor_portal_prod.offer_templates AS ot ON ot.id = o.offer_template_id
LEFT JOIN floranow.vendor_portal_prod.quantity_units AS qu ON qu.id = st.quantity_unit_id
LEFT JOIN floranow.vendor_portal_prod.feeds AS f ON f.id = ot.feed_id
LEFT JOIN floranow.vendor_portal_prod.accounts AS a ON g.account_id = a.id
LEFT JOIN floranow.Floranow_ERP.suppliers AS s ON s.floranow_supplier_id = a.floranow_account_id
LEFT JOIN OfferPrices AS rp ON st.id = rp.stock_id AND rp.PriceRank = 1
LEFT JOIN OfferSpecs AS spec ON st.id = spec.stock_id