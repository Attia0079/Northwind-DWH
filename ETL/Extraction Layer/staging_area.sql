INSERT INTO bronze_layer.categories_raw
SELECT category_id, category_name FROM bronze_layer.categories;

INSERT INTO bronze_layer.customers_raw
SELECT customer_id, company_name, contact_name, city, country
FROM bronze_layer.customers

INSERT INTO bronze_layer.employees_raw
SELECT employee_id, last_name, first_name, title, hire_date, reports_to 
FROM bronze_layer.employees;

INSERT INTO bronze_layer.region_raw
SELECT region_id, region_description 
FROM bronze_layer.region;

INSERT INTO bronze_layer.territories_raw
SELECT territory_id, territory_description, region_id
FROM bronze_layer.territories;

INSERT INTO bronze_layer.employee_territories_raw
SELECT employee_id, territory_id
FROM bronze_layer.employee_territories;

INSERT INTO bronze_layer.suppliers_raw
SELECT  supplier_id, company_name, contact_name,
contact_title, city, country
FROM bronze_layer.suppliers;

INSERT INTO bronze_layer.products_raw
SELECT product_id, product_name, supplier_Id, category_id, quantity_per_unit,
unit_price, units_in_stock, units_on_order, reorder_level, discontinued
FROM bronze_layer.products
ORDER BY product_id;

INSERT INTO bronze_layer.shippers_raw
SELECT shipper_id, company_name
FROM bronze_layer.shippers;

INSERT INTO bronze_layer.orders_raw
SELECT order_id, customer_id, employee_id, order_date, required_date, 
shipped_date, ship_via, freight, ship_name, ship_city, ship_country
FROM bronze_layer.orders;

INSERT INTO bronze_layer.order_details_raw
SELECT order_id, product_id, unit_price, quantity, discount
FROM bronze_layer.order_details;
