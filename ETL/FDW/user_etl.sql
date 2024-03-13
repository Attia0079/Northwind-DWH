--Create a user or role within the postgresql server
CREATE USER etl_user WITH PASSWORD '1234';

--Grant usage of the (public)schema's objects in specified db for this user 
GRANT USAGE ON SCHEMA PUBLIC TO etl_user;

--Set privileges for select on tables of public 
GRANT SELECT ON ALL TABLES IN SCHEMA public TO etl_user;


