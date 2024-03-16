DROP TABLE IF EXISTS redesign_sales_datamart.customers_dim;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.customers_dim
(
    cust_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    cust_id bpchar NOT NULL,
    company_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    cust_city character varying(15) COLLATE pg_catalog."default" NOT NULL,
    cust_country character varying(15) COLLATE pg_catalog."default",
	CONSTRAINT unique_cust_id UNIQUE (cust_id),
    CONSTRAINT customers_sales_dim_pkey PRIMARY KEY (cust_sk)
);

DROP TABLE IF EXISTS redesign_sales_datamart.date_dim;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.date_dim
(
  date_dim_sk              INT NOT NULL,
  date_actual              DATE NOT NULL,
  epoch                    BIGINT NOT NULL,
  day_suffix               VARCHAR(4) NOT NULL,
  day_name                 VARCHAR(9) NOT NULL,
  day_of_week              INT NOT NULL,
  day_of_month             INT NOT NULL,
  day_of_quarter           INT NOT NULL,
  day_of_year              INT NOT NULL,
  week_of_month            INT NOT NULL,
  week_of_year             INT NOT NULL,
  week_of_year_iso         CHAR(10) NOT NULL,
  month_actual             INT NOT NULL,
  month_name               VARCHAR(9) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  quarter_actual           INT NOT NULL,
  quarter_name             VARCHAR(9) NOT NULL,
  year_actual              INT NOT NULL,
  first_day_of_week        DATE NOT NULL,
  last_day_of_week         DATE NOT NULL,
  first_day_of_month       DATE NOT NULL,
  last_day_of_month        DATE NOT NULL,
  first_day_of_quarter     DATE NOT NULL,
  last_day_of_quarter      DATE NOT NULL,
  first_day_of_year        DATE NOT NULL,
  last_day_of_year         DATE NOT NULL,
  weekend_indr             BOOLEAN NOT NULL,
  CONSTRAINT date_dim_pk PRIMARY KEY (date_dim_sk)
);

DROP TABLE IF EXISTS redesign_sales_datamart.employees_dim;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.employees_dim
(
    emp_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    emp_id smallint NOT NULL,
	emp_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    emp_title character varying(30) COLLATE pg_catalog."default" NOT NULL,
    hire_date date NOT NULL,
    emp_report_to smallint,
    CONSTRAINT employees_sales_dim_pkey PRIMARY KEY (emp_sk),
	CONSTRAINT unique_emp_id UNIQUE (emp_id),
	CONSTRAINT fk_emp_recursive_mgr FOREIGN KEY (emp_report_to)
    REFERENCES redesign_sales_datamart.employees_dim (emp_id) MATCH SIMPLE    
);

DROP TABLE IF EXISTS redesign_sales_datamart.shippers_dim;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.shippers_dim (
	shipper_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    shipper_id smallint NOT NULL,
    company_name character varying(40) NOT NULL,
	CONSTRAINT shipper_sales_dim_pkey PRIMARY KEY (shipper_sk), 
	CONSTRAINT unique_shipper_id UNIQUE (shipper_id)
);

DROP TABLE IF EXISTS redesign_sales_datamart.products_dim;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.products_dim(
	product_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    product_id smallint NOT NULL,
    product_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    category_id smallint NOT NULL,
    category_name character varying(15) COLLATE pg_catalog."default" NOT NULL,
	supplier_id smallint NOT NULL,
    supplier_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    unit_price real NOT NULL,
	validfrom_date DATE NOT NULL,
	validto_date DATE NOT NULL DEFAULT '9999-12-31',
	iscurrent INT NOT NULL DEFAULT 1,
	CONSTRAINT products_dim_pkey PRIMARY KEY (product_sk)
)

DROP TABLE IF EXISTS redesign_sales_datamart.sales_fact;

CREATE TABLE IF NOT EXISTS redesign_sales_datamart.sales_fact(
	order_id smallint NOT NULL,
    product_sk integer NOT NULL,
    order_date_sk integer NOT NULL,
    required_date_sk integer NOT NULL,
    shipped_date_sk integer NOT NULL,
    emp_sk integer NOT NULL,
    cust_sk integer NOT NULL,
	shipper_sk integer NOT NULL,
    unit_price real NOT NULL,
    quantity_per_product smallint NOT NULL,
    discount real NOT NULL,
    freight real NOT NULL,
	total_price real NOT NULL,
	PRIMARY KEY (order_id, product_sk),
	CONSTRAINT sales_fact_cust_sk_fkey FOREIGN KEY (cust_sk)
    REFERENCES redesign_sales_datamart.customers_dim (cust_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_emp_sk_fkey FOREIGN KEY (emp_sk)
    REFERENCES redesign_sales_datamart.employees_dim (emp_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_ship_sk_fkey FOREIGN KEY (shipper_sk)
	REFERENCES redesign_sales_datamart.shippers_dim (shipper_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_order_date_sk_fkey FOREIGN KEY (order_date_sk)
    REFERENCES redesign_sales_datamart.date_dim (date_dim_sk ) MATCH SIMPLE,
	CONSTRAINT sales_fact_product_sk_fkey FOREIGN KEY (product_sk)
    REFERENCES redesign_sales_datamart.products_dim (product_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_required_date_sk_fkey FOREIGN KEY (required_date_sk)
    REFERENCES redesign_sales_datamart.date_dim (date_dim_sk ) MATCH SIMPLE,
	CONSTRAINT sales_fact_shipped_date_sk_fkey FOREIGN KEY (shipped_date_sk)
    REFERENCES redesign_sales_datamart.date_dim (date_dim_sk ) MATCH SIMPLE
);




