WITH change_unit_price AS(
SELECT od.product_id, od.unit_price, o.order_date,
    COALESCE(LAG(od.unit_price) OVER(PARTITION BY od.product_id ORDER BY o.order_date), od.unit_price) AS prev_price,
	ROW_NUMBER() OVER(PARTITION BY od.product_id, unit_price ORDER BY o.order_date) AS date_counter
FROM bronze_layer.order_details_raw od 
JOIN bronze_layer.orders_raw o
ON o.order_id = od.order_id
ORDER BY od.product_id, o.order_date
), price_dev AS(
SELECT product_id, unit_price, order_date, next_price, date_counter, ABS(unit_price - next_price) AS price_deviation
	FROM change_unit_price
), get_price_dev AS(
SELECT product_id, unit_price, order_date AS price_change_startDate, date_counter, price_deviation
FROM price_dev
WHERE price_deviation > 0
)
SELECT * FROM price_dev;


SELECT COUNT(DISTINCT ship_city) FROM bronze_layer.orders_raw;
select * from bronze_layer.shippers_raw
--junk Dimension for the ship destination
SELECT DISTINCT ship_via, s.company_name,ship_name, ship_city, ship_country
FROM bronze_layer.orders_raw, bronze_layer.shippers_raw s
WHERE s.shipper_id = ship_via;

SELECT DISTINCT ship_city, ship_country 
FROM bronze_layer.orders_raw;

SELECT DISTINCT ship_name
FROM bronze_layer.orders_raw;


SELECT ship_city, ship_country, ship_name
FROM (
    SELECT DISTINCT ship_city, ship_country
    FROM bronze_layer.orders_raw
) AS cities
CROSS JOIN (
    SELECT DISTINCT ship_name
    FROM bronze_layer.orders_raw
) AS names;


with price_change AS(
SELECT od.product_id, od.unit_price, o.order_date,
    COALESCE(LAG(od.unit_price) OVER(PARTITION BY od.product_id ORDER BY o.order_date), od.unit_price) AS prev_price,
	ROW_NUMBER() OVER(PARTITION BY od.product_id, unit_price ORDER BY o.order_date) AS date_counter
FROM bronze_layer.order_details_raw od 
JOIN bronze_layer.orders_raw o
ON o.order_id = od.order_id
ORDER BY od.product_id, o.order_date
)
SELECT product_id, unit_price, order_date AS start_date,
MAX(order_date) OVER(PARTITION BY product_id, unit_price) AS end_date
FROM price_change
ORDER BY product_id, start_date;