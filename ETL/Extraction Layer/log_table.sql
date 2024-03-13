--change_log table for capture data change in the source system with FDW connection
CREATE TABLE bronze_layer.change_log (
    change_id SERIAL PRIMARY KEY,
    table_name TEXT,
    operation TEXT, -- INSERT, UPDATE, DELETE
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--triggers function to observe the change in the source system on the bronze_layer
CREATE OR REPLACE FUNCTION bronze_layer.change_data_capture()
RETURNS TRIGGER AS $$
BEGIN
   EXECUTE format('INSERT INTO bronze_layer.change_log (table_name, operation) VALUES (%L, %L)', TG_TABLE_NAME, TG_OP);
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Get Foregin tables from the bronze schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'bronze_layer'
AND table_type = 'FOREIGN';

--Stored Procdure for reflect CDC on the source system
CREATE OR REPLACE PROCEDURE bronze_layer.create_triggers_for_bronze_schema()
LANGUAGE plpgsql
AS $$
DECLARE
    table_record RECORD;
BEGIN
    FOR table_record IN
        SELECT table_name
		FROM information_schema.tables
		WHERE table_schema = 'bronze_layer'
		AND table_type = 'FOREIGN'
    LOOP
        EXECUTE format('CREATE TRIGGER bronze_layer.trigger_%I AFTER INSERT OR UPDATE OR DELETE ON bronze_layer.%I FOR EACH ROW EXECUTE FUNCTION bronze_layer.change_data_capture()', table_record.table_name, table_record.table_name);
    END LOOP;
END;
$$;




