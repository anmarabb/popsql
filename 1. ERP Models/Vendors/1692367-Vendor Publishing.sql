create or replace view `floranow.Floranow_ERP.vendor_publishing` as 

SELECT
 Offers.name,
  Offers.departure_date_time as Departure_Date,
  Offers.status,
  stock.approved_quantity,
  stock.stockable_type,
  stock.minimum_order_quantity,
  stock.supplier_product_id,
  stock.remain_quantity,
  stock.product_id,
  Products.name as ItemName,
  Products.color as color,
  ARRAY_AGG(Struct(specification.specification_name as spec_name, sp_Values.flori_value_name as spec_Value)) as Spec
FROM
  `floranow.vendor_portal_prod.stocks` as stock
  join `floranow.vendor_portal_prod.offers` AS Offers on  stock.stockable_type='Offer' and stock.stockable_id=Offers.ID
  left join `floranow.vendor_portal_prod.products` as Products on stock.product_id = Products.id
  left outer join `floranow.vendor_portal_prod.specification_values` as sp_Values on Stock.id=sp_Values.stock_id
 left outer join `floranow.vendor_portal_prod.specifications` as specification on sp_Values.specification_id=specification.id
 group by  Offers.name,
  Offers.departure_date_time,
  Offers.status,
  stock.approved_quantity,
  stock.stockable_type,
  stock.minimum_order_quantity,
  stock.supplier_product_id,
  stock.remain_quantity,
  stock.product_id,
  Products.name,
  Products.color