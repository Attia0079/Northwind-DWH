SELECT DISTINCT country
FROM (
    SELECT LOWER(country) AS country FROM bronze_layer.customers_raw
    UNION ALL
    SELECT LOWER(country) FROM bronze_layer.suppliers_raw
    UNION ALL
    SELECT LOWER(country) FROM bronze_layer.employees_raw
    UNION ALL
    SELECT LOWER(ship_country) FROM bronze_layer.orders_raw
) AS all_countries;

SELECT DISTINCT city
FROM (
    SELECT LOWER(city) AS city FROM bronze_layer.customers_raw
    UNION ALL
    SELECT LOWER(city) FROM bronze_layer.suppliers_raw
    UNION ALL
    SELECT LOWER(city) FROM bronze_layer.employees_raw
    UNION ALL
    SELECT LOWER(ship_city) FROM bronze_layer.orders_raw
) AS all_cities;
