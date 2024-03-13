--order table validation
CREATE OR REPLACE FUNCTION sliver_layer.validate_orders()
RETURNS TABLE(order_id_in INT, validation_result TEXT) AS $$
DECLARE
    rec RECORD;
    attribute_name TEXT;
    result TEXT;
BEGIN
    FOR rec IN 
        SELECT order_id, freight
        FROM bronze_layer.orders_raw
    LOOP
        result := NULL;

        -- Check freight
        IF rec.freight < 0 THEN
            attribute_name := 'freight';
            result := 'Invalid value found in ' || attribute_name;
        END IF;
        
       IF result IS NOT NULL THEN
            order_id_in := rec.product_id;
            validation_result := result;
            RETURN NEXT;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sliver_layer.validate_orders();
