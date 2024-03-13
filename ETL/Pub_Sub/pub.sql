--Set replication privileges
GRANT CONNECT ON DATABASE northwinddb_source_system TO etl_user;

ALTER ROLE etl_user WITH REPLICATION;

-- On the source database
ALTER SYSTEM SET wal_level = logical;
ALTER SYSTEM SET max_replication_slots = 5;
ALTER SYSTEM SET max_wal_senders = 5; 


CREATE PUBLICATION pub_northwind FOR ALL TABLES;
