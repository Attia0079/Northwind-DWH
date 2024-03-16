DROP FUNCTION IF EXISTS sliver_layer.handle_product_data();

CREATE OR REPLACE FUNCTION sliver_layer.handle_product_data()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        -- Check and transform unit_price value
        IF NEW.unit_price < 0 THEN
            NEW.unit_price := NEW.unit_price * -1;
        END IF;

		INSERT INTO sliver_layer.products_transformed(product_id, product_name, supplier_id, category_id, unit_price)
		VALUES(NEW.product_id, TRIM(LOWER(NEW.product_name)), NEW.supplier_id, NEW.category_id, NEW.unit_price);

        UPDATE sliver_layer.products_transformed
        SET 
            product_name = COALESCE(TRIM(LOWER(NEW.product_name)), product_name),
            supplier_id = COALESCE(NEW.supplier_id, supplier_id),
            category_id = COALESCE(NEW.category_id, category_id),
            unit_price = COALESCE(NEW.unit_price, unit_price)
        WHERE product_id = NEW.product_id;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO anonymous_deleted_schema.products_rubbish
        SELECT OLD.*;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_product_changes
AFTER INSERT OR UPDATE OR DELETE ON bronze_layer.products_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.handle_product_data();

SELECT * FROM bronze_layer.products_raws;

INSERT INTO bronze_layer.products_raw (product_id, product_name, supplier_id, category_id, unit_price, units_in_stock, units_on_order, reorder_level, discontinued)
VALUES (79, 'New Product ss', 1, 2, 10.5, 100, 20, 10, 0);

SELECT * FROM sliver_layer.products_transformed;

DELETE FROM bronze_layer.products_raw WHERE product_id = 78;

SELECT * FROM anonymous_deleted_schema.products_rubbish;

