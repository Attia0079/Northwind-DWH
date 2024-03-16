DROP FUNCTION IF EXISTS sliver_layer.transform_shipper_data();

CREATE OR REPLACE FUNCTION sliver_layer.transform_shipper_data()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO sliver_layer.shippers_transformed (shipper_id, company_name)
        VALUES (
            NEW.shipper_id,
            TRIM(LOWER(NEW.company_name))
        );
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE sliver_layer.shippers_transformed
        SET company_name = COALESCE(TRIM(LOWER(NEW.company_name)), company_name)
        WHERE shipper_id = NEW.shipper_id;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO anonymous_deleted_schema.shippers_rubbish
        SELECT OLD.*;
    END IF;
	
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_insert_shipper_transform
BEFORE INSERT OR UPDATE OR DELETE ON bronze_layer.shippers_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.transform_shipper_data();

SELECT * FROM bronze_layer.shippers_raw;

INSERT INTO bronze_layer.shippers_raw (shipper_id, company_name, phone)
VALUES (7, 'Example Shipper', '123-456-7890');

SELECT * FROM sliver_layer.shippers_transformed;

UPDATE bronze_layer.shippers_raw
SET company_name = 'Updated Shipper Name'
WHERE shipper_id = 7;

DELETE FROM bronze_layer.shippers_raw
WHERE shipper_id = 7;

SELECT * FROM anonymous_deleted_schema.shippers_rubbish;