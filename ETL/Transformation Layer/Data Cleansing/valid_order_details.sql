CREATE OR REPLACE FUNCTION sliver_layer.validate_order_details()
RETURNS TABLE(order_id_in INT, validation_result TEXT) AS $$
DECLARE
    rec RECORD;
    attribute_name TEXT;
    result TEXT;
BEGIN
    FOR rec IN 
        SELECT order_id, unit_price, discount, quantity
        FROM bronze_layer.order_details_raw
    LOOP
        result := NULL;

        -- Check unit_price
        IF rec.unit_price < 0 THEN
            attribute_name := 'unit_price';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check discount
        IF rec.discount < 0 THEN
            attribute_name := 'discount';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        -- Check quantity
        IF rec.quantity < 0 THEN
            attribute_name := 'quantity';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
        IF result IS NOT NULL THEN
            order_id_in := rec.order_id;
            validation_result := result;
            RETURN NEXT;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM sliver_layer.validate_order_details();