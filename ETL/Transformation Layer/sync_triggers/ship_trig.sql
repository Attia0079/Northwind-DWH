DROP FUNCTION IF EXISTS sliver_layer.handle_new_ship_name();

CREATE OR REPLACE FUNCTION sliver_layer.handle_new_ship_name()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sliver_layer.ship_transformed WHERE ship_name = NEW.ship_name) THEN
        INSERT INTO sliver_layer.ship_transformed (ship_name) VALUES (NEW.ship_name);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_order_handle_ship_name
BEFORE INSERT ON bronze_layer.orders_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.handle_new_ship_name();




