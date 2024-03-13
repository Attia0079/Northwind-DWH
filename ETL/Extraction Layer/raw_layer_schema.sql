--DROP TABLE IF EXISTS bronze_layer.employee_territories_raw;
DROP TABLE IF EXISTS bronze_layer.order_details_raw;
DROP TABLE IF EXISTS bronze_layer.orders_raw;
DROP TABLE IF EXISTS bronze_layer.customers_raw;
DROP TABLE IF EXISTS bronze_layer.products_raw;
DROP TABLE IF EXISTS bronze_layer.shippers_raw;
DROP TABLE IF EXISTS bronze_layer.suppliers_raw;
--DROP TABLE IF EXISTS bronze_layer.territories_raw;
DROP TABLE IF EXISTS bronze_layer.categories_raw;
--DROP TABLE IF EXISTS bronze_layer.region_raw;
DROP TABLE IF EXISTS bronze_layer.employees_raw;

CREATE TABLE bronze_layer.categories_raw (
    category_id smallint NOT NULL PRIMARY KEY,
    category_name character varying(15) NOT NULL
);

CREATE TABLE bronze_layer.customers_raw (
    customer_id bpchar NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
	city character varying(15),
	country character varying(15)
);

CREATE TABLE bronze_layer.employees_raw (
    employee_id smallint NOT NULL PRIMARY KEY,
    last_name character varying(20) NOT NULL,
    first_name character varying(10) NOT NULL,
	title character varying(30),
	hire_date date,
	reports_to smallint,
	FOREIGN KEY (reports_to) REFERENCES bronze_layer.employees_raw
);

CREATE TABLE bronze_layer.suppliers_raw (
    supplier_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
	contact_title character varying(30),
	city character varying(15),
	country character varying(15)
);

CREATE TABLE bronze_layer.products_raw (
    product_id smallint NOT NULL PRIMARY KEY,
    product_name character varying(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit character varying(20),
    unit_price real,
    units_in_stock smallint,
    units_on_order smallint,
    reorder_level smallint,
    discontinued integer NOT NULL,
	FOREIGN KEY (category_id) REFERENCES bronze_layer.categories_raw,
	FOREIGN KEY (supplier_id) REFERENCES bronze_layer.suppliers_raw
);


--CREATE TABLE bronze_layer.region_raw (
--    region_id smallint NOT NULL PRIMARY KEY,
--    region_description bpchar NOT NULL
--);

CREATE TABLE bronze_layer.shippers_raw (
    shipper_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL
);

CREATE TABLE bronze_layer.orders_raw (
    order_id smallint NOT NULL PRIMARY KEY,
    customer_id bpchar,
    employee_id smallint,
    order_date date,
    required_date date,
    shipped_date date,
    ship_via smallint,
    freight real,
    ship_name character varying(40),
    ship_city character varying(15),
    ship_country character varying(15),
    FOREIGN KEY (customer_id) REFERENCES bronze_layer.customers_raw,
    FOREIGN KEY (employee_id) REFERENCES bronze_layer.employees_raw,
    FOREIGN KEY (ship_via) REFERENCES bronze_layer.shippers_raw
);

--CREATE TABLE bronze_layer.territories_raw (
--    territory_id character varying(20) NOT NULL PRIMARY KEY,
--    territory_description bpchar NOT NULL,
--    region_id smallint NOT NULL,
--	FOREIGN KEY (region_id) REFERENCES bronze_layer.region_raw
--);


--CREATE TABLE bronze_layer.employee_territories_raw (
--    employee_id smallint NOT NULL,
--    territory_id character varying(20) NOT NULL,
--    PRIMARY KEY (employee_id, territory_id),
--    FOREIGN KEY (territory_id) REFERENCES bronze_layer.territories_raw,
--    FOREIGN KEY (employee_id) REFERENCES bronze_layer.employees_raw
--);

CREATE TABLE bronze_layer.order_details_raw (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES bronze_layer.products_raw,
    FOREIGN KEY (order_id) REFERENCES bronze_layer.orders_raw
);