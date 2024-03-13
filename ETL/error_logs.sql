
CREATE TABLE bronze_layer.bronze_error_log (
    error_id SERIAL PRIMARY KEY,
    error_message TEXT,
    error_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE sliver_layer.sliver_error_log (
    error_id SERIAL PRIMARY KEY,
    error_message TEXT,
    error_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
