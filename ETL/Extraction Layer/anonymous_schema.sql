CREATE SCHEMA IF NOT EXISTS anonymous_deleted_schema;

DROP TABLE IF EXISTS anonymous_deleted_schema.employee_territories_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.order_details_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.orders_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.customers_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.products_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.shippers_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.suppliers_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.territories_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.categories_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.region_rubbish;
DROP TABLE IF EXISTS anonymous_deleted_schema.employees_rubbish;

CREATE TABLE anonymous_deleted_schema.categories_rubbish (
    category_id smallint NOT NULL PRIMARY KEY,
    category_name character varying(15) NOT NULL,
	description text,
    picture bytea
);

CREATE TABLE anonymous_deleted_schema.customers_rubbish (
    customer_id bpchar NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24)
);

CREATE TABLE anonymous_deleted_schema.employees_rubbish (
    employee_id smallint NOT NULL PRIMARY KEY,
    last_name character varying(20) NOT NULL,
    first_name character varying(10) NOT NULL,
    title character varying(30),
    title_of_courtesy character varying(25),
    birth_date date,
    hire_date date,
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    home_phone character varying(24),
    extension character varying(4),
    photo bytea,
    notes text,
    reports_to smallint,
    photo_path character varying(255)
);

ALTER TABLE anonymous_deleted_schema.employees_rubbish DROP CONSTRAINT employees_rubbish_reports_to_fkey;


CREATE TABLE anonymous_deleted_schema.suppliers_rubbish (
    supplier_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
    contact_name character varying(30),
    contact_title character varying(30),
    address character varying(60),
    city character varying(15),
    region character varying(15),
    postal_code character varying(10),
    country character varying(15),
    phone character varying(24),
    fax character varying(24),
    homepage text
);

CREATE TABLE anonymous_deleted_schema.products_rubbish (
    product_id smallint NOT NULL PRIMARY KEY,
    product_name character varying(40) NOT NULL,
    supplier_id smallint,
    category_id smallint,
    quantity_per_unit character varying(20),
    unit_price real,
    units_in_stock smallint,
    units_on_order smallint,
    reorder_level smallint,
    discontinued integer NOT NULL
);

CREATE TABLE anonymous_deleted_schema.region_rubbish (
    region_id smallint NOT NULL PRIMARY KEY,
    region_description bpchar NOT NULL
);

CREATE TABLE anonymous_deleted_schema.shippers_rubbish (
    shipper_id smallint NOT NULL PRIMARY KEY,
    company_name character varying(40) NOT NULL,
	phone character varying(24)
);

CREATE TABLE anonymous_deleted_schema.orders_rubbish (
    order_id smallint NOT NULL PRIMARY KEY,
    customer_id bpchar,
    employee_id smallint,
    order_date date,
    required_date date,
    shipped_date date,
    ship_via smallint,
    freight real,
    ship_name character varying(40),
    ship_address character varying(60),
    ship_city character varying(15),
    ship_region character varying(15),
    ship_postal_code character varying(10),
    ship_country character varying(15)
);

CREATE TABLE anonymous_deleted_schema.territories_rubbish (
    territory_id character varying(20) NOT NULL PRIMARY KEY,
    territory_description bpchar NOT NULL,
	region_id smallint NOT NULL
);


CREATE TABLE anonymous_deleted_schema.employee_territories_rubbish (
    employee_id smallint NOT NULL,
    territory_id character varying(20) NOT NULL
);

CREATE TABLE anonymous_deleted_schema.order_details_rubbish (
    order_id smallint NOT NULL,
    product_id smallint NOT NULL,
    unit_price real NOT NULL,
    quantity smallint NOT NULL,
    discount real NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES anonymous_deleted_schema.products_rubbish,
    FOREIGN KEY (order_id) REFERENCES anonymous_deleted_schema.orders_rubbish
);
