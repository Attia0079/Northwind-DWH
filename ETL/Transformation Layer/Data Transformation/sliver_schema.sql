DROP TABLE IF EXISTS sliver_layer.order_details_transformed;
DROP TABLE IF EXISTS sliver_layer.orders_transformed;
DROP TABLE IF EXISTS sliver_layer.customers_transformed;
DROP TABLE IF EXISTS sliver_layer.products_transformed;
DROP TABLE IF EXISTS sliver_layer.shippers_transformed;
DROP TABLE IF EXISTS sliver_layer.suppliers_transformed;
DROP TABLE IF EXISTS sliver_layer.categories_transformed;
DROP TABLE IF EXISTS sliver_layer.employees_transformed;

CREATE TABLE sliver_layer.customers_transformed (
	customer_sk integer GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    customer_id CHAR(5) NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30) NOT NULL,
	city VARCHAR(15) NOT NULL,
	country VARCHAR(15) NOT NULL
);

CREATE TABLE sliver_layer.categories_transformed (
    category_id smallint NOT NULL PRIMARY KEY,
    category_name VARCHAR(15) NOT NULL
);

CREATE TABLE sliver_layer.employees_transformed (
	employee_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    employee_id smallint NOT NULL PRIMARY KEY,
    emplyee_name VARCHAR(20) NOT NULL,
	title VARCHAR(30),
	hire_date DATE,
	reports_to smallint,
	FOREIGN KEY (reports_to) REFERENCES sliver_layer.employees_transformed
);


CREATE TABLE sliver_layer.suppliers_transformed (
    supplier_id smallint NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
	contact_title VARCHAR(30),
	city VARCHAR(15),
	country VARCHAR(15)
);

CREATE TABLE sliver_layer.products_transformed (
	product_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    product_id smallint NOT NULL PRIMARY KEY,
    product_name VARCHAR(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit VARCHAR(20),
    unit_price real,
    previous_unitsInStock smallint DEFAULT NULL,
    current_unitsInStock smallint NOT NULL,
    previous_unitsOnOrder smallint DEFAULT NULL,
	current_unitsOnOrder smallint NOT NULL,
    reorder_level smallint,
    discontinued smallint NOT NULL,
	price_start_changeDate date NOT NULL,
	price_end_changeDate date DEFAULT '9999-12-31',
	isCurrent_price BOOLEAN DEFAULT TRUE,
	FOREIGN KEY (category_id) REFERENCES sliver_layer.categories_transformed,
	FOREIGN KEY (supplier_id) REFERENCES sliver_layer.suppliers_transformed
);

CREATE TABLE sliver_layer.shippers_transformed (
    shipper_id smallint NOT NULL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL
);

CREATE TABLE sliver_layer.orders_transformed (
    order_id smallint NOT NULL PRIMARY KEY,
    customer_id CHAR(5),
    employee_id smallint,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via smallint,
    freight real,
    ship_name VARCHAR(40),
    ship_city VARCHAR(15),
    ship_country VARCHAR(15),
    FOREIGN KEY (customer_id) REFERENCES sliver_layer.customers_transformed,
    FOREIGN KEY (employee_id) REFERENCES sliver_layer.employees_transformed,
    FOREIGN KEY (ship_via) REFERENCES sliver_layer.shippers_transformed
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








