INSERT INTO sliver_layer.regions_transformed (city, country)
SELECT DISTINCT LOWER(TRIM(city)), TRIM(country)
FROM (
    SELECT city, country FROM bronze_layer.customers_raw
    UNION
    SELECT city, country FROM bronze_layer.employees_raw
    UNION
    SELECT city, country FROM bronze_layer.suppliers_raw
    UNION
    SELECT ship_city AS city, ship_country AS country FROM bronze_layer.orders_raw
) AS all_regions
WHERE CONCAT(LOWER(TRIM(city)), ' ', TRIM(country)) 
		NOT IN (SELECT CONCAT(LOWER(TRIM(city)), ' ', TRIM(country))
				FROM sliver_layer.regions_transformed);

DROP FUNCTION IF EXISTS sliver_layer.update_sliver_region();

CREATE OR REPLACE FUNCTION sliver_layer.update_sliver_region()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.city IS NOT NULL AND NEW.country IS NOT NULL THEN
        INSERT INTO sliver_layer.regions_transformed (city, country)
        SELECT LOWER(TRIM(NEW.city)), TRIM(NEW.country)
        WHERE NOT EXISTS (
            SELECT 1 FROM sliver_layer.regions_transformed
            WHERE city = LOWER(TRIM(NEW.city)) AND country = TRIM(NEW.country)
        );
        
        -- Update if there's an update operation
        IF TG_OP = 'UPDATE' THEN
            UPDATE sliver_layer.regions_transformed
            SET city = LOWER(TRIM(NEW.city)), country = TRIM(NEW.country)
            WHERE city = OLD.city AND country = OLD.country;
        END IF;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_sliver_region_customers
AFTER INSERT OR UPDATE ON bronze_layer.customers_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_sliver_region();

CREATE TRIGGER update_sliver_region_employees
AFTER INSERT OR UPDATE ON bronze_layer.employees_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_sliver_region();

CREATE TRIGGER update_sliver_region_suppliers
AFTER INSERT OR UPDATE ON bronze_layer.suppliers_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_sliver_region();

CREATE TRIGGER update_sliver_region_orders
AFTER INSERT OR UPDATE ON bronze_layer.orders_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_sliver_region();

select * from bronze_layer.suppliers_raw;

INSERT INTO bronze_layer.suppliers_raw (supplier_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, homepage)
VALUES (31, 'New Supplier', 'John Doe', 'Manager', '123 Main St', 'Cairo', NULL, '12345', 'Egypt', '123-456-7890', NULL, 'http://www.newsupplier.com');

UPDATE bronze_layer.suppliers_raw
SET city = 'cairo', country = 'Egypt'
WHERE supplier_id = 31;

SELECT * FROM sliver_layer.regions_transformed;

