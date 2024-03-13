CREATE OR REPLACE FUNCTION freight_allocation(order_id_in SMALLINT)
RETURNS REAL AS $$
DECLARE
	res_freight REAL;
BEGIN
	SELECT o.freight / q.order_quantity
	INTO res_freight
	FROM bronze_layer.orders_raw o
	JOIN (
		SELECT order_id, COUNT(*) AS order_quantity
		FROM bronze_layer.order_details_raw
		GROUP BY order_id
	) q ON o.order_id = q.order_id
	WHERE o.order_id = order_id_in;	
	RETURN res_freight;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_total_price(unit_price REAL, quantity SMALLINT, discount REAL, freight REAL)
RETURNS REAL AS $$
BEGIN
    RETURN (unit_price * quantity * (1 - discount) - freight);
END;
$$ LANGUAGE plpgsql;

WITH products_supplier_cte AS(
	SELECT p.product_id AS prod_id, p.supplier_id, s.company_name AS supplier_company_name
	FROM bronze_layer.products_raw p, bronze_layer.suppliers_raw S
	WHERE p.supplier_id = s.supplier_id
), products_category_cte AS(
	SELECT p.product_id AS prod_id, c.category_name AS cat_name
	FROM bronze_layer.products_raw p, bronze_layer.categories c
	WHERE p.category_id = c.category_id
), shippers_order_cte AS(
	SELECT o.order_id AS ord_id, s.company_name AS shipper_company_name
	FROM bronze_layer.orders_raw o, bronze_layer.shippers_raw s
	WHERE o.ship_via = s.shipper_id 
)

SELECT 
    o.order_id,
	od.product_id,
    (SELECT date_dim_sk FROM sales_data_mart.date_dim WHERE date_actual = o.order_date) AS order_date_sk,
    (SELECT date_dim_sk FROM sales_data_mart.date_dim WHERE date_actual = o.required_date) AS required_date_sk,
    (SELECT date_dim_sk FROM sales_data_mart.date_dim WHERE date_actual = o.shipped_date) AS shipped_date_sk,
	o.employee_id,
	o.customer_id,
	(SELECT supplier_company_name FROM products_supplier_cte WHERE prod_id = od.product_id) AS supplier_company_name,
	(SELECT cat_name FROM products_category_cte WHERE prod_id = od.product_id) AS category_name,
	od.unit_price,
	od.quantity AS quantity_per_product,
	od.discount,
	(SELECT shipper_company_name FROM shippers_order_cte WHERE ord_id = o.order_id) AS shipper_company_name,
	FREIGHT_ALLOCATION(o.order_id) AS freight,
	o.ship_city,
	o.ship_country,
	calculate_total_price(od.unit_price, od.quantity, discount, FREIGHT_ALLOCATION(o.order_id)) AS total_price
FROM bronze_layer.orders_raw o 
JOIN bronze_layer.order_details_raw od
ON od.order_id = o.order_id;