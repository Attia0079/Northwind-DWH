DROP TABLE IF EXISTS sliver_layer.regions_transformed;
DROP TABLE IF EXISTS sliver_layer.ship_transformed;
DROP TABLE IF EXISTS sliver_layer.order_details_transformed;
DROP TABLE IF EXISTS sliver_layer.orders_transformed;
DROP TABLE IF EXISTS sliver_layer.customers_transformed;
DROP TABLE IF EXISTS sliver_layer.products_transformed;
DROP TABLE IF EXISTS sliver_layer.shippers_transformed;
DROP TABLE IF EXISTS sliver_layer.suppliers_transformed;
DROP TABLE IF EXISTS sliver_layer.categories_transformed;
DROP TABLE IF EXISTS sliver_layer.employees_transformed;

CREATE TABLE sliver_layer.regions_transformed (
    region_id INT GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ) PRIMARY KEY,
    city VARCHAR(15) NOT NULL,
    country VARCHAR(15) NOT NULL
);
	
CREATE TABLE sliver_layer.customers_transformed (
    customer_id CHAR(5) NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30) NOT NULL,
	region_id SERIAL,
    CONSTRAINT fk_region_id FOREIGN KEY (region_id)
    REFERENCES sliver_layer.regions_transformed(region_id)
);

CREATE TABLE sliver_layer.categories_transformed (
    category_id smallint NOT NULL PRIMARY KEY,
    category_name VARCHAR(15) NOT NULL
);

CREATE TABLE sliver_layer.employees_transformed (
    employee_id smallint NOT NULL PRIMARY KEY,
    emplyee_name VARCHAR(20) NOT NULL,
	title VARCHAR(30) NOT NULL,
	hire_date DATE DEFAULT '9999-12-31',
	reports_to smallint,
	FOREIGN KEY (reports_to) REFERENCES sliver_layer.employees_transformed
);

CREATE TABLE sliver_layer.suppliers_transformed (
    supplier_id smallint NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30) NOT NULL,
	contact_title VARCHAR(30) NOT NULL,
	region_id SERIAL NOT NULL,
	CONSTRAINT supplier_region_fk FOREIGN KEY (region_id)
	REFERENCES sliver_layer.regions_transformed(region_id)
);

CREATE TABLE sliver_layer.products_transformed (
    product_id smallint NOT NULL PRIMARY KEY,
    product_name VARCHAR(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    unit_price real,
    FOREIGN KEY (category_id) REFERENCES sliver_layer.categories_transformed,
	FOREIGN KEY (supplier_id) REFERENCES sliver_layer.suppliers_transformed
);

CREATE TABLE sliver_layer.shippers_transformed (
    shipper_id smallint NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL
);

CREATE TABLE sliver_layer.ship_transformed(
	ship_id INT GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ) PRIMARY KEY,
	ship_name VARCHAR(100),
	shipper_id smallint NOT NULL,
	FOREIGN KEY (shipper_id) REFERENCES sliver_layer.shipperS_transformed
);

CREATE TABLE sliver_layer.orders_transformed (
    order_id smallint NOT NULL PRIMARY KEY,
    customer_id CHAR(5) NOT NULL,
    employee_id smallint NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE NOT NULL,
    shipper_id smallint NOT NULL,
    freight real NOT NULL,
	ship_id serial NOT NULL,
	region_id serial NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES sliver_layer.customers_transformed,
    FOREIGN KEY (employee_id) REFERENCES sliver_layer.employees_transformed,
    FOREIGN KEY (shipper_id) REFERENCES sliver_layer.shippers_transformed,
	FOREIGN KEY (ship_id) REFERENCES sliver_layer.ship_transformed,
	FOREIGN KEY (region_id) REFERENCES sliver_layer.regions_transformed
);

CREATE TABLE sliver_layer.order_details_transformed (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price smallint NOT NULL,
    quantity smallint NOT NULL,
    discount smallint NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES sliver_layer.products_transformed,
    FOREIGN KEY (order_id) REFERENCES sliver_layer.orders_transformed
);








