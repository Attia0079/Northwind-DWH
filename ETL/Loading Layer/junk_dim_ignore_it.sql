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
