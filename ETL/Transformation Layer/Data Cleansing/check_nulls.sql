--Check Nulls and Missing Values
DROP FUNCTION IF EXISTS sliver_layer.check_nulls();

CREATE OR REPLACE FUNCTION sliver_layer.check_nulls()
RETURNS TABLE(table_name_in TEXT, column_name_in TEXT, has_nulls BOOLEAN, null_count INT) AS $$
DECLARE
    rec RECORD;
    sql_query TEXT;
    result BOOLEAN;
BEGIN
    FOR rec IN 
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = 'bronze_layer'
        AND table_name IN (
            SELECT table_name 
            FROM information_schema.tables
            WHERE table_schema = 'bronze_layer' 
            AND table_type = 'BASE TABLE'
        )
    LOOP
        sql_query := format(
            'SELECT EXISTS (SELECT 1 FROM %s.%s WHERE %s IS NULL)',
            'bronze_layer',
            rec.table_name,
            rec.column_name
        );

        EXECUTE sql_query INTO result;
        
        sql_query := format(
            'SELECT COUNT(*) FROM %s.%s WHERE %s IS NULL',
            'bronze_layer',
            rec.table_name,
            rec.column_name
        );

        EXECUTE sql_query INTO null_count;
        
        table_name_in := rec.table_name;
        column_name_in := rec.column_name;
        has_nulls := result;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sliver_layer.check_nulls();