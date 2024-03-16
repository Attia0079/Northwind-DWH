DROP FUNCTION IF EXISTS sliver_layer.handle_customer_operations();

CREATE OR REPLACE FUNCTION sliver_layer.handle_customer_operations()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sliver_layer.customers_transformed (customer_id, company_name, contact_name, region_id)
        VALUES (NEW.customer_id, TRIM(LOWER(NEW.company_name)), TRIM(LOWER(NEW.contact_name)), sliver_layer.get_region_id(NEW.city, NEW.country));
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE sliver_layer.customers_transformed
        SET company_name = COALESCE(TRIM(LOWER(NEW.company_name)), company_name),
            contact_name = COALESCE(TRIM(LOWER(NEW.contact_name)), contact_name),
            region_id = sliver_layer.get_region_id(NEW.city, NEW.country)
        WHERE customer_id = NEW.customer_id;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO anonymous_deleted_schema.customers_rubbish
        SELECT OLD.*;
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER handle_customer_operations_trigger
AFTER INSERT OR UPDATE OR DELETE ON bronze_layer.customers_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.handle_customer_operations();

SELECT * FROM bronze_layer.customers_raw;

INSERT INTO bronze_layer.customers_raw (customer_id, company_name, contact_name, city, country)
VALUES ('C001', 'ABC Company', 'John Smith', 'New York', 'USA');

UPDATE bronze_layer.customers_raw
SET contact_name = 'Jane Doe'
WHERE customer_id = 'C001';

DELETE FROM bronze_layer.customers_raw
WHERE customer_id = 'C001';

SELECT * FROM sliver_layer.customers_transformed;
SELECT * FROM sliver_layer.regions_transformed;
SELECT * FROM anonymous_deleted_schema.customers_rubbish;