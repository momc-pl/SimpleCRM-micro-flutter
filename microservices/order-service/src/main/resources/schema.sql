-- Order Service Database Schema
-- Database: order_db

-- Drop tables if they exist (for development)
DROP TABLE IF EXISTS order_lines CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- Enum types
CREATE TYPE order_status_enum AS ENUM ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED');
CREATE TYPE payment_status_enum AS ENUM ('PENDING', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'REFUNDED');

-- Orders table
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL, -- Reference to customer-service
    user_id BIGINT NOT NULL,     -- Reference to auth-service
    status order_status_enum DEFAULT 'PENDING',
    payment_status payment_status_enum DEFAULT 'PENDING',
    
    -- Pricing information
    subtotal_net DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_vat DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_gross DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    
    -- Order metadata
    notes TEXT,
    internal_notes TEXT, -- Staff-only notes
    shipping_address JSONB, -- Denormalized shipping address
    billing_address JSONB,  -- Denormalized billing address
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    confirmed_at TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_order_number_format CHECK (order_number ~ '^ORD-[0-9]{8}-[A-Z0-9]{4}$'),
    CONSTRAINT chk_amounts_positive CHECK (
        subtotal_net >= 0 AND 
        total_vat >= 0 AND 
        total_gross >= 0 AND 
        shipping_cost >= 0 AND 
        discount_amount >= 0
    ),
    CONSTRAINT chk_total_calculation CHECK (total_gross = subtotal_net + total_vat + shipping_cost - discount_amount)
);

-- Order lines table
CREATE TABLE order_lines (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Product information (denormalized for performance)
    product_id BIGINT NOT NULL, -- Reference to catalog-service
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    
    -- Pricing and quantity
    quantity INTEGER NOT NULL,
    unit_price_net DECIMAL(10,2) NOT NULL,
    vat_rate DECIMAL(5,4) NOT NULL,
    line_vat DECIMAL(10,2) NOT NULL,
    line_total_gross DECIMAL(10,2) NOT NULL,
    
    -- Additional metadata
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
    CONSTRAINT chk_line_prices_positive CHECK (
        unit_price_net > 0 AND 
        line_vat >= 0 AND 
        line_total_gross > 0
    ),
    CONSTRAINT chk_line_total_calculation CHECK (
        line_total_gross = ROUND((unit_price_net * quantity) * (1 + vat_rate), 2)
    )
);

-- Indexes for performance
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_confirmed_at ON orders(confirmed_at);

CREATE INDEX idx_order_lines_order ON order_lines(order_id);
CREATE INDEX idx_order_lines_product ON order_lines(product_id);
CREATE INDEX idx_order_lines_sku ON order_lines(product_sku);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update order totals when order lines change
CREATE OR REPLACE FUNCTION update_order_totals()
RETURNS TRIGGER AS $$
DECLARE
    order_id_var BIGINT;
BEGIN
    -- Determine which order to update
    IF TG_OP = 'DELETE' THEN
        order_id_var := OLD.order_id;
    ELSE
        order_id_var := NEW.order_id;
    END IF;
    
    -- Update order totals
    UPDATE orders SET 
        subtotal_net = (
            SELECT COALESCE(SUM(unit_price_net * quantity), 0)
            FROM order_lines 
            WHERE order_id = order_id_var
        ),
        total_vat = (
            SELECT COALESCE(SUM(line_vat), 0)
            FROM order_lines 
            WHERE order_id = order_id_var
        ),
        total_gross = (
            SELECT COALESCE(SUM(line_total_gross), 0)
            FROM order_lines 
            WHERE order_id = order_id_var
        ) + shipping_cost - discount_amount,
        updated_at = NOW()
    WHERE id = order_id_var;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_order_totals
    AFTER INSERT OR UPDATE OR DELETE ON order_lines
    FOR EACH ROW EXECUTE FUNCTION update_order_totals();

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
    today_str TEXT;
    sequence_part INTEGER;
    random_suffix TEXT;
BEGIN
    today_str := TO_CHAR(NOW(), 'YYYYMMDD');
    
    -- Get next sequence number for today
    SELECT COALESCE(MAX(CAST(SUBSTRING(order_number FROM 13 FOR 4) AS INTEGER)), 0) + 1
    INTO sequence_part
    FROM orders 
    WHERE order_number LIKE 'ORD-' || today_str || '-%';
    
    -- Generate random suffix
    random_suffix := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));
    
    RETURN 'ORD-' || today_str || '-' || LPAD(sequence_part::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Views for common queries
CREATE VIEW order_summary AS
SELECT 
    o.id,
    o.order_number,
    o.customer_id,
    o.user_id,
    o.status,
    o.payment_status,
    o.total_gross,
    o.created_at,
    o.confirmed_at,
    o.shipped_at,
    o.delivered_at,
    COUNT(ol.id) as line_items_count,
    SUM(ol.quantity) as total_quantity
FROM orders o
LEFT JOIN order_lines ol ON o.id = ol.order_id
GROUP BY o.id, o.order_number, o.customer_id, o.user_id, o.status, 
         o.payment_status, o.total_gross, o.created_at, o.confirmed_at, 
         o.shipped_at, o.delivered_at;

CREATE VIEW pending_orders AS
SELECT 
    o.id,
    o.order_number,
    o.customer_id,
    o.status,
    o.payment_status,
    o.total_gross,
    o.created_at,
    EXTRACT(EPOCH FROM (NOW() - o.created_at))/3600 as hours_pending
FROM orders o
WHERE o.status = 'PENDING'
ORDER BY o.created_at;

CREATE VIEW daily_sales AS
SELECT 
    DATE(created_at) as sale_date,
    COUNT(*) as order_count,
    SUM(total_gross) as total_revenue,
    SUM(total_vat) as total_vat_collected,
    AVG(total_gross) as avg_order_value
FROM orders
WHERE status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY DATE(created_at)
ORDER BY sale_date DESC;

-- Sample data for development
INSERT INTO orders (order_number, customer_id, user_id, status, payment_status, shipping_cost, shipping_address, billing_address, notes) VALUES
(generate_order_number(), 1, 1, 'DELIVERED', 'CAPTURED', 15.00, 
 '{"street": "123 Main St", "city": "New York", "zip": "10001", "country": "USA"}',
 '{"street": "123 Main St", "city": "New York", "zip": "10001", "country": "USA"}',
 'Rush delivery requested'),
(generate_order_number(), 2, 1, 'SHIPPED', 'CAPTURED', 10.00,
 '{"street": "789 Pine Rd", "city": "Los Angeles", "zip": "90210", "country": "USA"}',
 '{"street": "789 Pine Rd", "city": "Los Angeles", "zip": "90210", "country": "USA"}',
 'Standard shipping'),
(generate_order_number(), 3, 2, 'PROCESSING', 'AUTHORIZED', 25.00,
 '{"street": "321 Corporate Blvd", "city": "Chicago", "zip": "60601", "country": "USA"}',
 '{"street": "321 Corporate Blvd", "city": "Chicago", "zip": "60601", "country": "USA"}',
 'Enterprise order - bulk discount applied'),
(generate_order_number(), 1, 1, 'PENDING', 'PENDING', 12.00,
 '{"street": "456 Oak Ave", "city": "New York", "zip": "10002", "country": "USA"}',
 '{"street": "123 Main St", "city": "New York", "zip": "10001", "country": "USA"}',
 'Different shipping address');

-- Sample order lines
INSERT INTO order_lines (order_id, product_id, product_name, product_sku, quantity, unit_price_net, vat_rate, line_vat, line_total_gross) VALUES
-- Order 1
(1, 1, 'Laptop Pro 15"', 'LAP-PRO-15-001', 1, 1200.00, 0.2000, 240.00, 1440.00),
(1, 4, 'Wireless Mouse', 'MOUSE-WL-001', 2, 45.00, 0.2000, 18.00, 108.00),
-- Order 2  
(2, 2, 'Smartphone X1', 'PHONE-X1-001', 1, 800.00, 0.2000, 160.00, 960.00),
(2, 6, 'USB-C Hub', 'HUB-USBC-001', 1, 75.00, 0.2000, 15.00, 90.00),
-- Order 3
(3, 5, 'Standing Desk', 'DESK-STAND-001', 3, 450.00, 0.2000, 270.00, 1620.00),
(3, 7, 'Monitor 27"', 'MON-27-4K-001', 2, 350.00, 0.2000, 140.00, 840.00),
-- Order 4
(4, 3, 'Office Suite Pro', 'SOFT-OFFICE-PRO', 5, 299.99, 0.2000, 299.99, 1799.94);

-- Update confirmed/shipped/delivered timestamps for completed orders
UPDATE orders SET 
    confirmed_at = created_at + INTERVAL '1 hour',
    shipped_at = created_at + INTERVAL '1 day',
    delivered_at = created_at + INTERVAL '3 days'
WHERE status = 'DELIVERED';

UPDATE orders SET 
    confirmed_at = created_at + INTERVAL '1 hour',
    shipped_at = created_at + INTERVAL '1 day'
WHERE status = 'SHIPPED';

UPDATE orders SET 
    confirmed_at = created_at + INTERVAL '1 hour'
WHERE status = 'PROCESSING';