--Check Duplicates
DROP FUNCTION IF EXISTS sliver_layer.check_duplicates();

CREATE OR REPLACE FUNCTION sliver_layer.check_duplicates()
RETURNS TABLE(table_name_in TEXT, has_duplicates BOOLEAN, duplicate_count INT) AS $$
DECLARE
    rec RECORD;
    sql_query TEXT;
    result BOOLEAN;
BEGIN
    FOR rec IN 
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'bronze_layer' 
        AND table_type = 'BASE TABLE'
    LOOP
        sql_query := format(
            'SELECT EXISTS (SELECT * FROM (SELECT COUNT(*) FROM %1$s.%2$s GROUP BY %2$s HAVING COUNT(*) > 1) AS subquery)',
            'bronze_layer',
            rec.table_name
        );

        EXECUTE sql_query INTO result;
        
        sql_query := format(
            'SELECT COUNT(*) FROM (SELECT COUNT(*) FROM %1$s.%2$s GROUP BY %2$s HAVING COUNT(*) > 1) AS subquery',
            'bronze_layer',
            rec.table_name
        );

        EXECUTE sql_query INTO duplicate_count;
        
        table_name_in := rec.table_name;
        has_duplicates := result;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sliver_layer.check_duplicates();
