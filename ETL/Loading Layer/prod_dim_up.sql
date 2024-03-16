
with price_change AS(
SELECT od.product_id, od.unit_price, o.order_date,
    COALESCE(LAG(od.unit_price) OVER(PARTITION BY od.product_id ORDER BY o.order_date), od.unit_price) AS prev_price,
	ROW_NUMBER() OVER(PARTITION BY od.product_id, unit_price ORDER BY o.order_date) AS date_counter
FROM bronze_layer.order_details_raw od 
JOIN bronze_layer.orders_raw o
ON o.order_id = od.order_id
ORDER BY od.product_id, o.order_date
), scd_product AS(
SELECT DISTINCT pc.product_id, p.product_name, c.category_id, c.category_name, s.supplier_id, s.company_name, pc.unit_price, 
MIN(order_date) OVER(PARTITION BY pc.product_id, pc.unit_price) AS start_date,
MAX(order_date) OVER(PARTITION BY pc.product_id, pc.unit_price) AS end_date
FROM price_change pc
JOIN bronze_layer.products_raw p
ON p.product_id = pc.product_Id
JOIN bronze_layer.categories_raw c
ON p.category_id = c.category_id
JOIN bronze_layer.suppliers_raw s
ON p.supplier_id = s.supplier_id
ORDER BY pc.product_id, start_date)

INSERT INTO redesign_sales_datamart.products_dim(
    product_id, 
    product_name, 
    category_id, 
    category_name, 
    supplier_id, 
    supplier_name,
    unit_price, 
    validfrom_date, 
    validto_date, 
    iscurrent
)
SELECT 
    product_id, 
    product_name, 
    category_id, 
    category_name, 
    supplier_id, 
    company_name, 
    unit_price, 
    start_date,
    CASE 
        WHEN end_date = MAX(end_date) OVER(PARTITION BY product_id) THEN '9999-12-31'
        ELSE end_date
    END AS validto_date,
    CASE 
        WHEN end_date = MAX(end_date) OVER(PARTITION BY product_id) THEN 1 
        ELSE 0 
    END AS iscurrent
FROM 
    scd_product;


select * from redesign_sales_datamart.products_dim