INSERT INTO redesign_sales_datamart.customers_dim(cust_id, company_name, cust_city, cust_country)
SELECT customer_id, company_name, city, country
FROM sliver_layer.customers_transformed c
JOIN sliver_layer.regions_transformed s
ON s.region_id = c.region_id;

INSERT INTO redesign_sales_datamart.employees_dim(emp_id, emp_name, emp_title, hire_date, emp_report_to)
SELECT employee_id, emplyee_name, title, hire_date, reports_to
FROM sliver_layer.employees_transformed;

INSERT INTO redesign_sales_datamart.shippers_dim(shipper_id, company_name)
SELECT shipper_id, company_name
FROM sliver_layer.shippers_transformed;

SET lc_time = 'en_US.UTF-8';

INSERT INTO redesign_sales_datamart.date_dim
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
FROM (SELECT '1990-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 14609) AS SEQUENCE (DAY) 
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;



INSERT INTO redesign_sales_datamart.sales_fact(order_id, product_sk, order_date_sk, required_date_sk, shipped_date_sk, 
			emp_sk, cust_sk, shipper_sk, unit_price, quantity_per_product, discount, freight, total_price)
SELECT 
    o.order_id,
	(SELECT product_sk FROM redesign_sales_datamart.products_dim WHERE product_id = od.product_id AND unit_price = od.unit_price) AS prod_sk,
    (SELECT date_dim_sk FROM redesign_sales_datamart.date_dim WHERE date_actual = o.order_date) AS order_date_sk,
    (SELECT date_dim_sk FROM redesign_sales_datamart.date_dim WHERE date_actual = o.required_date) AS required_date_sk,
    (SELECT date_dim_sk FROM redesign_sales_datamart.date_dim WHERE date_actual = o.shipped_date) AS shipped_date_sk,
	(SELECT emp_sk FROM redesign_sales_datamart.employees_dim WHERE emp_id = o.employee_id) AS emp_sk,
	(SELECT cust_sk FROM redesign_sales_datamart.customers_dim WHERE cust_id = o.customer_id) AS cust_sk,
	(SELECT shipper_sk FROM redesign_sales_datamart.shippers_dim WHERE shipper_id = o.shipper_id) AS shipper_id,
	od.unit_price,
	od.quantity AS quantity_per_product,
	od.discount,
	FREIGHT_ALLOCATION(o.order_id) AS freight,
	calculate_total_price(od.unit_price, od.quantity, discount, FREIGHT_ALLOCATION(o.order_id)) AS total_price
FROM sliver_layer.orders_transformed o 
JOIN sliver_layer.order_details_transformed od
ON od.order_id = o.order_id;