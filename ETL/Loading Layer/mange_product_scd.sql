SELECT 
    product_id,
    TRIM(LOWER(product_name)) AS product_name,
    supplier_id,
    category_id,
    quantity_per_unit,
    FLOOR(RANDOM() * 121)::INT AS previous_unitsinstock,
    units_in_stock AS current_unitinstock,
    FLOOR(RANDOM() * 121)::INT AS previous_unitsonorder,
    units_on_order AS current_unitsonorder,
    reorder_level,
    discontinued,
    TO_DATE('1998-05-06', 'YYYY-MM-DD') AS price_start_changedate,
    '9999-12-31' AS price_end_changedate,
    1 AS iscurrent_price 
FROM 
    bronze_layer.products_raw;
