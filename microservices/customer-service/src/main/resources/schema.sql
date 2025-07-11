-- Customer Service Database Schema
-- Database: customer_db

-- Drop tables if they exist (for development)
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- Enum types
CREATE TYPE customer_type_enum AS ENUM ('INDIVIDUAL', 'BUSINESS', 'ENTERPRISE');
CREATE TYPE customer_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'ARCHIVED');

-- Customers table
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    customer_type customer_type_enum DEFAULT 'INDIVIDUAL',
    status customer_status_enum DEFAULT 'ACTIVE',
    notes TEXT,
    user_id BIGINT NOT NULL, -- Foreign key reference to auth-service (user who created this customer)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone IS NULL OR phone ~ '^\+?[0-9\s\-()]+$')
);

-- Addresses table
CREATE TABLE addresses (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    street VARCHAR(255),
    city VARCHAR(100),
    zip VARCHAR(20),
    country VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    address_type VARCHAR(20) DEFAULT 'BILLING', -- BILLING, SHIPPING, OTHER
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_address_type CHECK (address_type IN ('BILLING', 'SHIPPING', 'OTHER'))
);

-- Indexes for performance
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_user_id ON customers(user_id);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_type ON customers(customer_type);
CREATE INDEX idx_customers_created_at ON customers(created_at);

CREATE INDEX idx_addresses_customer_id ON addresses(customer_id);
CREATE INDEX idx_addresses_primary ON addresses(is_primary) WHERE is_primary = true;

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customers_updated_at 
    BEFORE UPDATE ON customers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at 
    BEFORE UPDATE ON addresses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Ensure only one primary address per customer
CREATE UNIQUE INDEX idx_customers_one_primary_address 
    ON addresses(customer_id) WHERE is_primary = true;

-- Views for common queries
CREATE VIEW customer_summary AS
SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.company,
    c.customer_type,
    c.status,
    c.created_at,
    COUNT(a.id) as address_count,
    MAX(CASE WHEN a.is_primary THEN CONCAT(a.street, ', ', a.city, ', ', a.country) END) as primary_address
FROM customers c
LEFT JOIN addresses a ON c.id = a.customer_id
GROUP BY c.id, c.name, c.email, c.phone, c.company, c.customer_type, c.status, c.created_at;

-- Sample data for development
INSERT INTO customers (name, email, phone, company, customer_type, status, user_id, notes) VALUES
('John Smith', 'john.smith@email.com', '+1-555-0101', 'Tech Corp', 'BUSINESS', 'ACTIVE', 1, 'VIP customer'),
('Jane Doe', 'jane.doe@email.com', '+1-555-0102', NULL, 'INDIVIDUAL', 'ACTIVE', 1, 'Regular customer'),
('Bob Johnson', 'bob.johnson@company.com', '+1-555-0103', 'BigCorp Ltd', 'ENTERPRISE', 'ACTIVE', 1, 'Enterprise account'),
('Alice Brown', 'alice.brown@email.com', '+1-555-0104', NULL, 'INDIVIDUAL', 'INACTIVE', 1, 'Former customer'),
('Charlie Wilson', 'charlie.wilson@startup.com', '+1-555-0105', 'StartupXYZ', 'BUSINESS', 'ACTIVE', 1, 'New business customer');

INSERT INTO addresses (customer_id, street, city, zip, country, is_primary, address_type) VALUES
(1, '123 Main St', 'New York', '10001', 'USA', true, 'BILLING'),
(1, '456 Oak Ave', 'New York', '10002', 'USA', false, 'SHIPPING'),
(2, '789 Pine Rd', 'Los Angeles', '90210', 'USA', true, 'BILLING'),
(3, '321 Corporate Blvd', 'Chicago', '60601', 'USA', true, 'BILLING'),
(4, '654 Elm St', 'Houston', '77001', 'USA', true, 'BILLING'),
(5, '987 Start Lane', 'Austin', '78701', 'USA', true, 'BILLING');