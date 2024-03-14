DROP FUNCTION IF EXISTS sliver_layer.check_nulls();

CREATE OR REPLACE FUNCTION sliver_layer.check_nulls()
RETURNS TABLE(table_name_in TEXT, column_name_in TEXT, has_nulls BOOLEAN, null_count INT, null_percentage FLOAT) AS $$
DECLARE
    rec RECORD;
    sql_query TEXT;
    result BOOLEAN;
    total_count INT;
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
        
        sql_query := format(
            'SELECT COUNT(*) FROM %s.%s',
            'bronze_layer',
            rec.table_name
        );

        EXECUTE sql_query INTO total_count;
        
        table_name_in := rec.table_name;
        column_name_in := rec.column_name;
        has_nulls := result;
        null_percentage := CASE WHEN total_count > 0 THEN ROUND(null_count::NUMERIC / total_count::NUMERIC * 100, 2) ELSE 0 END;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sliver_layer.check_nulls() WHERE null_count > 0;
