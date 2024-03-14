INSERT INTO bronze_layer.categories_raw
SELECT * FROM bronze_layer.categories;

INSERT INTO bronze_layer.customers_raw
SELECT *
FROM bronze_layer.customers

INSERT INTO bronze_layer.employees_raw
SELECT * 
FROM bronze_layer.employees;

INSERT INTO bronze_layer.region_raw
SELECT *
FROM bronze_layer.region;

INSERT INTO bronze_layer.territories_raw
SELECT *
FROM bronze_layer.territories;

INSERT INTO bronze_layer.employee_territories_raw
SELECT *
FROM bronze_layer.employee_territories;

INSERT INTO bronze_layer.suppliers_raw
SELECT  *
FROM bronze_layer.suppliers;

INSERT INTO bronze_layer.products_raw
SELECT *
FROM bronze_layer.products
ORDER BY product_id;

INSERT INTO bronze_layer.shippers_raw
SELECT *
FROM bronze_layer.shippers;

INSERT INTO bronze_layer.orders_raw
SELECT *
FROM bronze_layer.orders;

INSERT INTO bronze_layer.order_details_raw
SELECT *
FROM bronze_layer.order_details;
