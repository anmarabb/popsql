with 
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


select

g.name AS supplier,
  s.account_manager,
  s.supplier_region,

ot.name as offer_template,
CASE
    WHEN ot.name LIKE '%Event%' THEN 'Event'
    WHEN ot.name LIKE '%Regular%' THEN 'Regular'
    WHEN ot.name LIKE '%Avails%' THEN 'Avails'
    ELSE 'others'
  END AS offer_type,
  p.name AS product,
  p.color,
  p.flori_main_group_name AS product_group,
  p.flori_sub_group_name AS product_sub_group,
  spec.p1,
  spec.p2,
  spec.p3,
  spec.p4,



from floranow.vendor_portal_prod.offer_templates AS ot 
LEFT JOIN floranow.vendor_portal_prod.feeds AS f ON f.id = ot.feed_id
left join floranow.vendor_portal_prod.stocks AS st on st.stockable_type = 'OfferTemplate' and st.stockable_id = ot.id
LEFT JOIN floranow.vendor_portal_prod.products AS p ON st.product_id = p.id
LEFT JOIN floranow.vendor_portal_prod.growers AS g ON g.id = p.grower_id
LEFT JOIN floranow.vendor_portal_prod.accounts AS a ON g.account_id = a.id

LEFT JOIN floranow.Floranow_ERP.suppliers AS s ON s.floranow_supplier_id = a.floranow_account_id
LEFT JOIN OfferSpecs AS spec ON st.id = spec.stock_id


where ot.deleted_at is null and st.deleted_at is null

and a.id = '6e4d696b-1601-43dc-aa92-8ea7b6a3abf9'