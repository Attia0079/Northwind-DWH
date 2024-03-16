--category table transformation
INSERT INTO sliver_layer.categories_transformed
SELECT category_id, TRIM(LOWER(category_name))
FROM bronze_layer.categories_raw
WHERE category_id NOT IN (SELECT category_id 
										FROM sliver_layer.categories_transformed);

DROP FUNCTION IF EXISTS sliver_layer.get_region_id(city_name VARCHAR, 
														country_name VARCHAR);

CREATE OR REPLACE FUNCTION sliver_layer.get_region_id(city_name VARCHAR, country_name VARCHAR)
RETURNS INT AS
$$
DECLARE
    res_region_id INT;
BEGIN
    SELECT region_id INTO res_region_id
    FROM sliver_layer.regions_transformed
    WHERE city = LOWER(TRIM(city_name)) AND country = TRIM(country_name);

    IF res_region_id IS NULL THEN
        INSERT INTO sliver_layer.regions_transformed (city, country)
        VALUES (LOWER(TRIM(city_name)), TRIM(country_name))
        RETURNING region_id INTO res_region_id;
    END IF;

    RETURN res_region_id;
END;
$$
LANGUAGE plpgsql;


--customer table transformation
INSERT INTO sliver_layer.customers_transformed
SELECT customer_id, TRIM(LOWER(company_name)), TRIM(LOWER(contact_name)),
	sliver_layer.get_region_id(city, country)
FROM bronze_layer.customers_raw
WHERE customer_id NOT IN (SELECT customer_id FROM sliver_layer.customers_transformed);

--shipper table transformation
INSERT INTO sliver_layer.shippers_transformed
SELECT shipper_id, TRIM(LOWER(company_name))
FROM bronze_layer.shippers_raw;

--employees table transformation
INSERT INTO sliver_layer.employees_transformed
SELECT employee_id, TRIM(LOWER(CONCAT(first_name, ' ', last_name))), TRIM(LOWER(title)),
hire_date, reports_to
FROM bronze_layer.employees_raw
WHERE employee_id NOT IN (SELECT employee_id FROM sliver_layer.employees_transformed);

--table supplier transformation
INSERT INTO sliver_layer.suppliers_transformed
SELECT supplier_id, TRIM(LOWER(company_name)), TRIM(LOWER(contact_name)), 
TRIM(LOWER(contact_title)), sliver_layer.get_region_id(city, country)
FROM bronze_layer.suppliers_raw;

--table ship transformed
INSERT INTO sliver_layer.ship_transformed(ship_name)
SELECT DISTINCT ship_name
FROM bronze_layer.orders_raw;

--table products transformation
INSERT INTO sliver_layer.products_transformed
SELECT product_id, TRIM(LOWER(product_name)) AS product_name, supplier_id, 
	category_id, unit_price
FROM bronze_layer.products_raw;


INSERT INTO sliver_layer.order_details_transformed
SELECT * FROM bronze_layer.order_details_raw;



