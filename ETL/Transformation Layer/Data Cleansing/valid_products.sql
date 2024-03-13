--Check invalid numeric values like price, quantity, discount, units..etc
--table products
DROP FUNCTION IF EXISTS sliver_layer.validate_products();

CREATE OR REPLACE FUNCTION sliver_layer.validate_products()
RETURNS TABLE(product_id_in INT, validation_result TEXT) AS $$
DECLARE
    rec RECORD;
    attribute_name TEXT;
    result TEXT;
BEGIN
    FOR rec IN 
        SELECT product_id, unit_price, units_in_stock, units_on_order, reorder_level, discontinued
        FROM bronze_layer.products_raw
    LOOP
        result := NULL;

        -- Check unit_price
        IF rec.unit_price < 0 THEN
            attribute_name := 'unit_price';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check units_in_stock
        IF rec.units_in_stock < 0 THEN
            attribute_name := 'units_in_stock';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check units_on_order
        IF rec.units_on_order < 0 THEN
            attribute_name := 'units_on_order';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check reorder_level
        IF rec.reorder_level < 0 THEN
            attribute_name := 'reorder_level';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check discontinued
        IF rec.discontinued < 0 THEN
            attribute_name := 'discontinued';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
         IF result IS NOT NULL THEN
            product_id_in := rec.product_id;
            validation_result := result;
            RETURN NEXT;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM sliver_layer.validate_products();




