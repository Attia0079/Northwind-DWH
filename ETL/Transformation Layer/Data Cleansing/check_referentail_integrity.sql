-- Check Referential Integrity with NULLs in Referencing Columns
SELECT kc.table_name,
       kc.column_name,
       kc.constraint_name,
       ccu.table_name AS referenced_table_name,
       ccu.column_name AS referenced_column_name
FROM information_schema.key_column_usage AS kc
JOIN information_schema.referential_constraints AS rc
    ON kc.constraint_name = rc.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON rc.unique_constraint_name = ccu.constraint_name
LEFT JOIN information_schema.tables AS bl_tables
    ON kc.table_name = bl_tables.table_name AND kc.constraint_schema = bl_tables.table_schema
LEFT JOIN information_schema.columns AS bl_columns
    ON bl_tables.table_schema = bl_columns.table_schema AND bl_tables.table_name = bl_columns.table_name AND kc.column_name = bl_columns.column_name
WHERE kc.constraint_schema = 'bronze_layer'
  AND kc.table_name IN (
      SELECT table_name 
      FROM information_schema.tables
      WHERE table_schema = 'bronze_layer' 
      AND table_type = 'BASE TABLE'
  )
  AND kc.constraint_name != 'PRIMARY'
ORDER BY kc.table_name, kc.constraint_name;
