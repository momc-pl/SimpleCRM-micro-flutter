-- Create databases for each microservice
CREATE DATABASE auth_db;
CREATE DATABASE customer_db;
CREATE DATABASE product_db;
CREATE DATABASE order_db;
CREATE DATABASE sales_db;

-- Create users for each service
CREATE USER authuser WITH ENCRYPTED PASSWORD 'authsecret';
CREATE USER customeruser WITH ENCRYPTED PASSWORD 'customersecret';
CREATE USER productuser WITH ENCRYPTED PASSWORD 'productsecret';
CREATE USER orderuser WITH ENCRYPTED PASSWORD 'ordersecret';
CREATE USER salesuser WITH ENCRYPTED PASSWORD 'salessecret';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE auth_db TO authuser;
GRANT ALL PRIVILEGES ON DATABASE customer_db TO customeruser;
GRANT ALL PRIVILEGES ON DATABASE product_db TO productuser;
GRANT ALL PRIVILEGES ON DATABASE order_db TO orderuser;
GRANT ALL PRIVILEGES ON DATABASE sales_db TO salesuser;

-- Grant schema privileges
\c auth_db;
GRANT ALL ON SCHEMA public TO authuser;

\c customer_db;
GRANT ALL ON SCHEMA public TO customeruser;

\c product_db;
GRANT ALL ON SCHEMA public TO productuser;

\c order_db;
GRANT ALL ON SCHEMA public TO orderuser;

\c sales_db;
GRANT ALL ON SCHEMA public TO salesuser;