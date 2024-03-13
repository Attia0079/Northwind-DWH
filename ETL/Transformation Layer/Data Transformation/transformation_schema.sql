--category table transformation
SELECT category_id, TRIM(LOWER(category_name))
FROM bronze_layer.categories_raw;

--customer table transformation
SELECT customer_id, TRIM(LOWER(company_name)), TRIM(LOWER(contact_name)), 
TRIM(LOWER(city)), TRIM(LOWER(country))
FROM bronze_layer.customers_raw;

--shipper table transformation
SELECT shipper_id, TRIM(LOWER(company_name))
FROM bronze_layer.shippers_raw;

--employees table transformation
SELECT employee_id, TRIM(LOWER(CONCAT(first_name, ' ', last_name))), TRIM(LOWER(title)),
hire_date, reports_to
FROM bronze_layer.employees_raw;

--table supplier transformation
SELECT supplier_id, TRIM(LOWER(company_name)), TRIM(LOWER(contact_name)), 
TRIM(LOWER(contact_title)), TRIM(LOWER(city)), TRIM(LOWER(country))
FROM bronze_layer.suppliers_raw;

--table order transformation
SELECT order_id, customer_id, employee_id, order_date, required_date, shipped_date
ship_via, freight, TRIM(LOWER(ship_name)), TRIM(LOWER(ship_city)), TRIM(LOWER(ship_country))
FROM bronze_layer.orders


--table products transformation
SELECT 
    product_id,
    TRIM(LOWER(product_name)) AS product_name,
    supplier_id,
    category_id,
    quantity_per_unit,
    FLOOR(RANDOM() * 121)::INT AS previous_unitsinstock,
    units_in_stock AS current_unitinstock,
    FLOOR(RANDOM() * 121)::INT AS previous_unitsonorder,
    units_on_order AS current_unitsonorder,
    reorder_level,
    discontinued,
    TO_DATE('1998-05-06', 'YYYY-MM-DD') AS price_start_changedate,
    '9999-12-31' AS price_end_changedate,
    1 AS iscurrent_price 
FROM 
    bronze_layer.products_raw;


