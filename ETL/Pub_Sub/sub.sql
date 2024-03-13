CREATE SUBSCRIPTION my_subscription
CONNECTION 'host=127.0.0.1 dbname=northwinddb_source_system user=etl_user password=1234'
PUBLICATION my_publication;
