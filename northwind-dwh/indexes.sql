CREATE INDEX idx_city_country_btree ON redesign_sales_datamart.customers_dim USING btree (cust_city, cust_country);

CREATE INDEX idx_emp_name ON redesign_sales_datamart.employees_dim USING hash (emp_name);

CREATE INDEX idx_shipper_company_name_hash ON redesign_sales_datamart.shippers_dim USING hash (company_name);

CREATE INDEX idx_product_name_hash ON redesign_sales_datamart.products_dim USING hash (product_name);
CREATE INDEX idx_category_name_hash ON redesign_sales_datamart.products_dim USING hash (category_name);
CREATE INDEX idx_supplier_name_hash ON redesign_sales_datamart.products_dim USING hash (supplier_name);



CREATE INDEX idx_product_name ON redesign_sales_datamart.sales_fact (product_sk);
CREATE INDEX idx_order_date ON redesign_sales_datamart.sales_fact (order_date_sk);
CREATE INDEX idx_supplier ON redesign_sales_datamart.sales_fact (shipper_sk);
CREATE INDEX idx_customer ON redesign_sales_datamart.sales_fact (cust_sk);
CREATE INDEX idx_employee ON redesign_sales_datamart.sales_fact (emp_sk);
CREATE INDEX idx_quantity ON redesign_sales_datamart.sales_fact (quantity_per_product);
CREATE INDEX idx_discount ON redesign_sales_datamart.sales_fact (discount);
CREATE INDEX idx_total_price ON redesign_sales_datamart.sales_fact (total_price);
CREATE INDEX idx_freight ON redesign_sales_datamart.sales_fact (freight);