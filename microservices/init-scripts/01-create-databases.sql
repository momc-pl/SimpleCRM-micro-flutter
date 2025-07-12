-- Create databases for each microservice
CREATE DATABASE auth_db;
CREATE DATABASE customer_db;
CREATE DATABASE contact_db;
CREATE DATABASE product_db;
CREATE DATABASE order_db;
CREATE DATABASE sales_db;

-- Create users for each service
CREATE USER authuser WITH PASSWORD 'authsecret';
CREATE USER customeruser WITH PASSWORD 'customersecret';
CREATE USER contactuser WITH PASSWORD 'contactsecret';
CREATE USER productuser WITH PASSWORD 'productsecret';
CREATE USER orderuser WITH PASSWORD 'ordersecret';
CREATE USER salesuser WITH PASSWORD 'salessecret';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE auth_db TO authuser;
GRANT ALL PRIVILEGES ON DATABASE customer_db TO customeruser;
GRANT ALL PRIVILEGES ON DATABASE contact_db TO contactuser;
GRANT ALL PRIVILEGES ON DATABASE product_db TO productuser;
GRANT ALL PRIVILEGES ON DATABASE order_db TO orderuser;
GRANT ALL PRIVILEGES ON DATABASE sales_db TO salesuser;