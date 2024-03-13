--extension <==> package
--this like import statement
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

--check extentsion exist
SELECT * FROM pg_extension;

--Create foreign server(establishing connection with the source system)
CREATE SERVER northwinddbss_fdw 
FOREIGN DATA WRAPPER postgres_fdw 
OPTIONS (host '127.0.0.1', port '5432', dbname 'northwinddb_source_system');

--Create user mapping with the etl_user
CREATE USER MAPPING FOR postgres 
SERVER northwinddbss_fdw 
OPTIONS (user 'etl_user', password '1234');

--check user mapping
SELECT * FROM pg_user_mapping;

--Grant usage on the foreign server for the postgres user
GRANT USAGE ON FOREIGN SERVER northwinddbss_fdw TO postgres;

--Import the foregin schema of the foreign servrer into a schema(create schema before)
IMPORT FOREIGN SCHEMA public 
FROM SERVER northwinddbss_fdw INTO bronze_layer;

