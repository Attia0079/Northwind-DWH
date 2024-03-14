DROP FUNCTION IF EXISTS sliver_layer.update_silver_categories(); 
	
CREATE OR REPLACE FUNCTION sliver_layer.update_silver_categories()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO silver_layer.categories_transformed (category_id, category_name)
        SELECT NEW.category_id, TRIM(LOWER(NEW.category_name))
        WHERE NOT EXISTS (
            SELECT 1 FROM silver_layer.categories_transformed WHERE category_id = NEW.category_id
        );
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE silver_layer.categories_transformed
        SET category_name = TRIM(LOWER(NEW.category_name))
        WHERE category_id = NEW.category_id;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO anonymous_deleted_schema.categories_rubbish (category_id, category_name, description, picture)
        VALUES (OLD.category_id, OLD.category_name, OLD.description, OLD.picture);
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_silver_categories
AFTER INSERT ON bronze_layer.categories_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_silver_categories();

CREATE TRIGGER update_silver_categories
AFTER UPDATE ON bronze_layer.categories_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_silver_categories();

CREATE TRIGGER delete_bronze_categories
AFTER DELETE ON bronze_layer.categories_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.update_silver_categories();
