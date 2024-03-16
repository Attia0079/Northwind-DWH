DROP FUNCTION IF EXISTS sliver_layer.transform_supplier_data();

CREATE OR REPLACE FUNCTION sliver_layer.transform_supplier_data()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO sliver_layer.suppliers_transformed
        VALUES (
            NEW.supplier_id,
            TRIM(LOWER(NEW.company_name)),
            TRIM(LOWER(NEW.contact_name)),
            TRIM(LOWER(NEW.contact_title)),
            sliver_layer.get_region_id(NEW.city, NEW.country)
        );
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE sliver_layer.suppliers_transformed
        SET company_name = COALESCE(TRIM(LOWER(NEW.company_name)), company_name),
            contact_name = COALESCE(TRIM(LOWER(NEW.contact_name)), contact_name),
            contact_title = COALESCE(TRIM(LOWER(NEW.contact_title)), contact_title),
            region_id = sliver_layer.get_region_id(NEW.city, NEW.country)
        WHERE supplier_id = NEW.supplier_id;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO anonymous_deleted_schema.suppliers_rubbish
        SELECT OLD.*;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_insert_supplier_transform
BEFORE INSERT OR UPDATE OR DELETE ON bronze_layer.suppliers_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.transform_supplier_data();

SELECT * FROM bronze_layer.suppliers_raw;

INSERT INTO bronze_layer.suppliers_raw (supplier_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, homepage)
VALUES (32, 'Example Company', 'John Doe', 'CEO', '123 Main Street', 'Giza', 'AnyRegion', '12345', 'Egypt', '123-456-7890', '123-456-7890', 'example.com');

SELECT * FROM sliver_layer.suppliers_transformed;
SELECT * FROM sliver_layer.regions_transformed;

UPDATE bronze_layer.suppliers_raw
SET company_name = 'Updated Company Name'
WHERE supplier_id = 32;

DELETE FROM bronze_layer.suppliers_raw
WHERE supplier_id = 32;

SELECT * FROM anonymous_deleted_schema.suppliers_rubbish
