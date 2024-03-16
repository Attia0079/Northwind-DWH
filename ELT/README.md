# ELT Process Documentation

## Environment Setup:

- **Cluster Instantiation:**
  - Two PostgreSQL clusters are instantiated: one for the PUB (Publisher) and one for the SUB (Subscriber).

## Configuring Clusters:

- **Configuration of PUB Cluster:**
  - Uncomment the `wal_level` line in the `postgresql.conf` file and set it to `logical`.
    ```
    wal_level = logical
    ```
  - Change the port to `5435`.
    ```
    port = 5435
    ```

- **Configuration of SUB Cluster:**
  - Change the port to `5436`.
    ```
    port = 5436
    ```

## Starting Instances:

- **Starting PostgreSQL Instances:**
  - Start both PostgreSQL instances.
    ```
    /usr/lib/postgresql/16/bin/pg_ctl -D Publisher_db_name start
    /usr/lib/postgresql/16/bin/pg_ctl -D Subscriber_db_name start
    ```

## Creating Databases and Tables:

- **Creating Database and Tables in PUB Cluster:**
  - Connect to the PUB cluster and create the desired database (`pub_db`).
    ```
    CREATE DATABASE pub_db;
    \c pub_db
    ```
  - Add tables and insert data from SQL files.
    ```
    \i path_to_database_schema
    ```

- **Creating Publication:**
  - Create a publication (`mypub`) for all tables in the PUB database.
    ```
    create publication mypub for all tables;
    ```

## Creating Subscription:

- **Creating Subscription in SUB Cluster:**
  - Connect to the SUB cluster.
  - Create a subscriber database (`sub_db_name`) with tables having the same schema as the PUB database.
  - Create a subscription (`mysub`) specifying the connection string and the publication (`mypub`).
    ```
    create subscription mysub connection 'dbname=northwind_database host=localhost user=attia port=5435' publication mypub;
    ```

## Steps to Create PUB/SUB:

1. **Environment Setup:**
   - Instantiate 2 PostgreSQL clusters.

2. **Configuring Clusters:**
   - Configure the PUB cluster by uncommenting `wal_level` and setting it to `logical`, and change the port to `5435`.
   - Configure the SUB cluster by changing its port to `5436`.

3. **Starting Instances:**
   - Start both PostgreSQL instances.

4. **Creating Databases and Tables:**
   - Connect to the PUB cluster, create the desired database (`pub_db`), add tables, and insert data.
   - Create a publication (`mypub`) for all tables in the PUB database.

5. **Creating Subscription:**
   - Connect to the SUB cluster, create a subscriber database (`sub_db_name`), create tables with the same schema as the PUB database.
   - Create a subscription (`mysub`) specifying the connection string and the publication (`mypub`).
