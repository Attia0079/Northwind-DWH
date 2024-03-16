CREATE OR REPLACE FUNCTION sliver_layer.transform_and_insert_order_details_data()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.unit_price < 0 THEN
        NEW.unit_price := NEW.unit_price * -1;
    END IF;

    IF NEW.discount < 0 THEN
        NEW.discount := NEW.discount * -1;
    END IF;
ord
    IF NEW.quantity < 0 THEN
        NEW.quantity := NEW.quantity * -1;
    END IF;

    INSERT INTO sliver_layer.order_details_transformed (order_id, product_id, unit_price, quantity, discount)
    VALUES (NEW.order_id, NEW.product_id, NEW.unit_price, NEW.quantity, NEW.discount);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_insert_order_details_transform
BEFORE INSERT ON bronze_layer.order_details_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.transform_and_insert_order_details_data();

