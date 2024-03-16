DROP FUNCTION IF EXISTS sliver_layer.transform_

CREATE OR REPLACE FUNCTION sliver_layer.transform_and_insert_order_data()
RETURNS TRIGGER AS $$
DECLARE
    transformed_ship_id INT;
BEGIN
    IF NEW.freight < 0 THEN
        NEW.freight := NEW.freight * -1;
    END IF;

    SELECT ship_id INTO transformed_ship_id FROM sliver_layer.ship_transformed WHERE ship_name = NEW.ship_name;
	
    IF transformed_ship_id IS NULL THEN
        transformed_ship_id := -1; 
    END IF;

	NEW.shipped_date := COALESCE(NEW.shipped_date, NEW.required_date - interval '3 days');

    INSERT INTO sliver_layer.orders_transformed (order_id, customer_id, employee_id, order_date, required_date, shipped_date, shipper_id, freight, ship_id, region_id)
    VALUES (NEW.order_id, NEW.customer_id, NEW.employee_id, NEW.order_date, NEW.required_date, NEW.shipped_date, NEW.ship_via, NEW.freight, transformed_ship_id, NEW.region_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_order_transform
BEFORE INSERT ON bronze_layer.orders_raw
FOR EACH ROW
EXECUTE FUNCTION sliver_layer.transform_and_insert_order_data();

INSERT INTO sliver_layer.orders_transformed
SELECT 
    order_id, 
    customer_id, 
    employee_id, 
    order_date, 
    required_date, 
    COALESCE(shipped_date, required_date - interval '3 days') as shipped_date,
    ship_via, 
    freight, 
    (SELECT ship_id FROM sliver_layer.ship_transformed ship WHERE ship.ship_name = ord.ship_name), 
    sliver_layer.get_region_id(ship_city, ship_country) as region_id
FROM bronze_layer.orders_raw ord;

SELECT * FROM sliver_layer.orders_transformed;

