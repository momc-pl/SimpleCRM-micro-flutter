-- Database Migration Scripts for Microservices Decomposition
-- From Monolithic SimpleCRM to Microservices Architecture

-- =============================================
-- STEP 1: CREATE SERVICE-SPECIFIC DATABASES
-- =============================================

-- Create databases for each microservice
CREATE DATABASE customer_db;
CREATE DATABASE auth_db;
CREATE DATABASE catalog_db;
CREATE DATABASE order_db;
CREATE DATABASE contact_db;

-- Create service-specific database users
CREATE USER customer_user WITH PASSWORD 'customer_secret';
CREATE USER auth_user WITH PASSWORD 'auth_secret';
CREATE USER catalog_user WITH PASSWORD 'catalog_secret';
CREATE USER order_user WITH PASSWORD 'order_secret';
CREATE USER contact_user WITH PASSWORD 'contact_secret';

-- Grant database permissions
GRANT ALL PRIVILEGES ON DATABASE customer_db TO customer_user;
GRANT ALL PRIVILEGES ON DATABASE auth_db TO auth_user;
GRANT ALL PRIVILEGES ON DATABASE catalog_db TO catalog_user;
GRANT ALL PRIVILEGES ON DATABASE order_db TO order_user;
GRANT ALL PRIVILEGES ON DATABASE contact_db TO contact_user;

-- =============================================
-- STEP 2: BACKUP ORIGINAL DATA
-- =============================================

-- Create backup schema in original database
CREATE SCHEMA IF NOT EXISTS migration_backup;

-- Backup original tables
CREATE TABLE migration_backup.customers_backup AS SELECT * FROM customers;
CREATE TABLE migration_backup.addresses_backup AS SELECT * FROM addresses;
CREATE TABLE migration_backup.users_backup AS SELECT * FROM users;
CREATE TABLE migration_backup.products_backup AS SELECT * FROM products;
CREATE TABLE migration_backup.orders_backup AS SELECT * FROM orders;
CREATE TABLE migration_backup.order_lines_backup AS SELECT * FROM order_lines;

-- =============================================
-- STEP 3: DATA MIGRATION SCRIPTS
-- =============================================

-- CUSTOMER SERVICE MIGRATION
-- Connect to customer_db and run customer schema.sql first, then:

\c customer_db;

-- Migrate customer data (assuming improved customer entity structure)
INSERT INTO customers (name, email, phone, company, customer_type, status, notes, user_id, created_at, updated_at)
SELECT 
    c.name,
    c.email,
    c.phone,
    CASE 
        WHEN c.name LIKE '%Corp%' OR c.name LIKE '%Ltd%' OR c.name LIKE '%Inc%' THEN c.name
        ELSE NULL 
    END as company,
    CASE 
        WHEN c.name LIKE '%Corp%' OR c.name LIKE '%Ltd%' OR c.name LIKE '%Inc%' THEN 'BUSINESS'::customer_type_enum
        ELSE 'INDIVIDUAL'::customer_type_enum
    END as customer_type,
    'ACTIVE'::customer_status_enum as status,
    '' as notes,
    1 as user_id, -- Default to first user, update as needed
    NOW() as created_at,
    NOW() as updated_at
FROM source_db.customers c;

-- Migrate address data
INSERT INTO addresses (customer_id, street, city, zip, country, is_primary, address_type, created_at, updated_at)
SELECT 
    a.customer_id,
    a.street,
    a.city,
    a.zip,
    a.country,
    TRUE as is_primary, -- Mark first address as primary
    'BILLING' as address_type,
    NOW() as created_at,
    NOW() as updated_at
FROM source_db.addresses a;

-- AUTH SERVICE MIGRATION
-- Connect to auth_db and run auth schema.sql first, then:

\c auth_db;

INSERT INTO users (google_id, name, email, picture_url, role, created_at, updated_at, last_login, is_active)
SELECT 
    u.google_id,
    u.name,
    u.email,
    'https://lh3.googleusercontent.com/a/default-user' as picture_url,
    'USER' as role,
    COALESCE(u.created_at, NOW()) as created_at,
    NOW() as updated_at,
    NULL as last_login,
    TRUE as is_active
FROM source_db.users u;

-- PRODUCT CATALOG MIGRATION
-- Connect to catalog_db and run catalog schema.sql first, then:

\c catalog_db;

-- Create default category first
INSERT INTO product_categories (name, description) VALUES ('General', 'General products category');

-- Migrate product data
INSERT INTO products (name, description, sku, price_net, vat_rate, category_id, stock_quantity, min_stock_level, is_active, created_at, updated_at)
SELECT 
    p.name,
    COALESCE('Product: ' || p.name, '') as description,
    COALESCE('SKU-' || p.id::TEXT, 'SKU-UNKNOWN-' || p.id::TEXT) as sku,
    p.price_net,
    p.vat_rate,
    1 as category_id, -- Default to 'General' category
    50 as stock_quantity, -- Default stock
    10 as min_stock_level, -- Default minimum
    TRUE as is_active,
    NOW() as created_at,
    NOW() as updated_at
FROM source_db.products p;

-- ORDER SERVICE MIGRATION
-- Connect to order_db and run order schema.sql first, then:

\c order_db;

-- Migrate order data
INSERT INTO orders (order_number, customer_id, user_id, status, payment_status, subtotal_net, total_vat, total_gross, 
                   shipping_cost, discount_amount, notes, created_at, updated_at, confirmed_at)
SELECT 
    COALESCE(o.order_number, 'ORD-' || TO_CHAR(o.created_at, 'YYYYMMDD') || '-' || LPAD(o.id::TEXT, 4, '0')) as order_number,
    o.customer_id,
    o.user_id,
    'DELIVERED'::order_status_enum as status, -- Assume old orders are delivered
    'CAPTURED'::payment_status_enum as payment_status,
    o.total_net as subtotal_net,
    o.total_vat,
    o.total_gross,
    0.00 as shipping_cost, -- Default shipping cost
    0.00 as discount_amount, -- Default discount
    '' as notes,
    o.created_at,
    NOW() as updated_at,
    o.created_at + INTERVAL '1 hour' as confirmed_at
FROM source_db.orders o;

-- Migrate order lines with denormalized product data
INSERT INTO order_lines (order_id, product_id, product_name, product_sku, quantity, unit_price_net, vat_rate, line_vat, line_total_gross)
SELECT 
    ol.order_id,
    ol.product_id,
    COALESCE(p.name, 'Unknown Product') as product_name,
    COALESCE('SKU-' || ol.product_id::TEXT, 'SKU-UNKNOWN') as product_sku,
    ol.quantity,
    ol.unit_price_net,
    COALESCE(p.vat_rate, 0.20) as vat_rate,
    ol.line_vat,
    ol.line_total_gross
FROM source_db.order_lines ol
LEFT JOIN source_db.products p ON ol.product_id = p.id;

-- =============================================
-- STEP 4: DATA VALIDATION SCRIPTS
-- =============================================

-- Validate customer migration
\c customer_db;
SELECT 
    'Customers' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.customers) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.customers) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM customers;

-- Validate addresses migration
SELECT 
    'Addresses' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.addresses) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.addresses) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM addresses;

-- Validate users migration
\c auth_db;
SELECT 
    'Users' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.users) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.users) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM users;

-- Validate products migration
\c catalog_db;
SELECT 
    'Products' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.products) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.products) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM products;

-- Validate orders migration
\c order_db;
SELECT 
    'Orders' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.orders) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.orders) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM orders;

SELECT 
    'Order Lines' as table_name,
    COUNT(*) as migrated_count,
    (SELECT COUNT(*) FROM source_db.order_lines) as original_count,
    CASE 
        WHEN COUNT(*) = (SELECT COUNT(*) FROM source_db.order_lines) THEN 'SUCCESS'
        ELSE 'FAILED'
    END as migration_status
FROM order_lines;

-- =============================================
-- STEP 5: DATA SYNCHRONIZATION SETUP
-- =============================================

-- Create event outbox tables for each service
\c customer_db;
CREATE TABLE IF NOT EXISTS outbox_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP
);

\c auth_db;
CREATE TABLE IF NOT EXISTS outbox_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP
);

\c catalog_db;
CREATE TABLE IF NOT EXISTS outbox_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP
);

\c order_db;
CREATE TABLE IF NOT EXISTS outbox_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id VARCHAR(255) NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP
);

-- =============================================
-- STEP 6: CLEANUP AND POST-MIGRATION TASKS
-- =============================================

-- Update sequences to continue from correct values
\c customer_db;
SELECT setval('customers_id_seq', (SELECT MAX(id) FROM customers));
SELECT setval('addresses_id_seq', (SELECT MAX(id) FROM addresses));

\c auth_db;
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

\c catalog_db;
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
SELECT setval('product_categories_id_seq', (SELECT MAX(id) FROM product_categories));

\c order_db;
SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders));
SELECT setval('order_lines_id_seq', (SELECT MAX(id) FROM order_lines));

-- Create migration completion log
\c source_db;
CREATE TABLE IF NOT EXISTS migration_log (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100),
    migration_type VARCHAR(100),
    status VARCHAR(20),
    record_count INTEGER,
    completed_at TIMESTAMP DEFAULT NOW(),
    notes TEXT
);

INSERT INTO migration_log (service_name, migration_type, status, record_count, notes) VALUES
('customer-service', 'DATA_MIGRATION', 'COMPLETED', (SELECT COUNT(*) FROM customer_db.customers), 'Customer and address data migrated successfully'),
('auth-service', 'DATA_MIGRATION', 'COMPLETED', (SELECT COUNT(*) FROM auth_db.users), 'User authentication data migrated successfully'),
('catalog-service', 'DATA_MIGRATION', 'COMPLETED', (SELECT COUNT(*) FROM catalog_db.products), 'Product catalog data migrated successfully'),
('order-service', 'DATA_MIGRATION', 'COMPLETED', (SELECT COUNT(*) FROM order_db.orders), 'Order and order line data migrated successfully');

-- =============================================
-- ROLLBACK SCRIPTS (USE ONLY IF MIGRATION FAILS)
-- =============================================

/*
-- TO ROLLBACK MIGRATION IF NEEDED:

-- Drop service databases
DROP DATABASE IF EXISTS customer_db;
DROP DATABASE IF EXISTS auth_db;
DROP DATABASE IF EXISTS catalog_db;
DROP DATABASE IF EXISTS order_db;
DROP DATABASE IF EXISTS contact_db;

-- Drop service users
DROP USER IF EXISTS customer_user;
DROP USER IF EXISTS auth_user;
DROP USER IF EXISTS catalog_user;
DROP USER IF EXISTS order_user;
DROP USER IF EXISTS contact_user;

-- Restore original tables from backup
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_lines CASCADE;

CREATE TABLE customers AS SELECT * FROM migration_backup.customers_backup;
CREATE TABLE addresses AS SELECT * FROM migration_backup.addresses_backup;
CREATE TABLE users AS SELECT * FROM migration_backup.users_backup;
CREATE TABLE products AS SELECT * FROM migration_backup.products_backup;
CREATE TABLE orders AS SELECT * FROM migration_backup.orders_backup;
CREATE TABLE order_lines AS SELECT * FROM migration_backup.order_lines_backup;

-- Recreate original constraints and indexes
-- (Add original DDL here)
*/