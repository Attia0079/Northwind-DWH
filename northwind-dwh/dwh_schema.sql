SET lc_time = 'en_US.UTF-8';

BEGIN;

CREATE TABLE IF NOT EXISTS sales_data_mart.customers_dim
(
    cust_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    cust_id bpchar NOT NULL,
    contact_name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    company_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    cust_city character varying(15) COLLATE pg_catalog."default" NOT NULL,
    cust_country character varying(15) COLLATE pg_catalog."default",
    CONSTRAINT customers_dim_pkey PRIMARY KEY (cust_sk)
);

CREATE TABLE sales_data_mart.date_dim
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
  CONSTRAINT d_date_date_dim_id_pk PRIMARY KEY (date_dim_sk)
);


CREATE TABLE IF NOT EXISTS sales_data_mart.employees_dim
(
    emp_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    emp_id smallint NOT NULL,
	emp_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    emp_title character varying(30) COLLATE pg_catalog."default" NOT NULL,
    hire_date date NOT NULL,
    emp_report_to smallint,
    CONSTRAINT employees_dim_pkey PRIMARY KEY (emp_sk),
	CONSTRAINT fk_emp_recursive_mgr FOREIGN KEY (emp_report_to)
    REFERENCES sales_data_mart.employees_dim (emp_sk) MATCH SIMPLE    
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


CREATE TABLE IF NOT EXISTS sales_data_mart.products_dim
(
    product_sk integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    product_id smallint NOT NULL,
    product_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    supplier_id smallint NOT NULL,
    supplier_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    category_id smallint NOT NULL,
    category_name character varying(15) COLLATE pg_catalog."default" NOT NULL,
    quantity_per_unit character varying(20) COLLATE pg_catalog."default" NOT NULL,
    unit_price real NOT NULL,
	previous_unitsInStock smallint DEFAULT NULL,
    current_unitsInStock smallint NOT NULL,
    previous_unitsOnOrder smallint DEFAULT NULL,
	current_unitsOnOrder smallint NOT NULL,
    reorder_level smallint NOT NULL,
    discontinued integer NOT NULL,
	price_start_changeDate date NOT NULL,
	price_end_changeDate date DEFAULT '9999-12-31',
	isCurrent_price BOOLEAN DEFAULT TRUE,
    CONSTRAINT products_dim_pkey PRIMARY KEY (product_sk)
);

CREATE TABLE IF NOT EXISTS sales_data_mart.sales_fact
(
	sales_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    order_id smallint NOT NULL,
    product_sk integer NOT NULL,
    order_date_sk integer NOT NULL,
    required_date_sk integer NOT NULL,
    shipped_date_sk integer NOT NULL,
    emp_sk integer NOT NULL,
    cust_sk integer NOT NULL,
    supplier_company_name character varying(40) COLLATE pg_catalog."default" NOT NULL,
    category_name character varying(15) COLLATE pg_catalog."default" NOT NULL,
    unit_price real NOT NULL,
    quantity_per_product smallint NOT NULL,
    discount real NOT NULL,
    shipper_company_name character varying(40) NOT NULL,
    freight real NOT NULL,
    ship_city character varying(15) COLLATE pg_catalog."default" NOT NULL,
    ship_country character varying(15) COLLATE pg_catalog."default" NOT NULL,
    total_price real NOT NULL,
    CONSTRAINT sales_fact_pkey PRIMARY KEY (sales_id),
	CONSTRAINT sales_fact_cust_sk_fkey FOREIGN KEY (cust_sk)
    REFERENCES sales_data_mart.customers_dim (cust_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_emp_sk_fkey FOREIGN KEY (emp_sk)
    REFERENCES sales_data_mart.employees_dim (emp_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_order_date_sk_fkey FOREIGN KEY (order_date_sk)
    REFERENCES sales_data_mart.date_dim (date_dim_sk ) MATCH SIMPLE,
	CONSTRAINT sales_fact_product_sk_fkey FOREIGN KEY (product_sk)
    REFERENCES sales_data_mart.products_dim (product_sk) MATCH SIMPLE,
	CONSTRAINT sales_fact_required_date_sk_fkey FOREIGN KEY (required_date_sk)
    REFERENCES sales_data_mart.date_dim (date_dim_sk ) MATCH SIMPLE,
	CONSTRAINT sales_fact_shipped_date_sk_fkey FOREIGN KEY (shipped_date_sk)
    REFERENCES sales_data_mart.date_dim (date_dim_sk ) MATCH SIMPLE
);

END;


INSERT INTO sales_data_mart.date_dim
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
       datum AS date_actual,
       EXTRACT(EPOCH FROM datum) AS epoch,
       TO_CHAR(datum, 'fmDDth') AS day_suffix,
       TO_CHAR(datum, 'TMDay') AS day_name,
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       EXTRACT(DAY FROM datum) AS day_of_month,
       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW-') || EXTRACT(ISODOW FROM datum) AS week_of_year_iso,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_actual,
       CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
           END AS quarter_name,
       EXTRACT(YEAR FROM datum) AS year_actual,
       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS weekend_indr
FROM (SELECT '1970-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

COMMIT;

