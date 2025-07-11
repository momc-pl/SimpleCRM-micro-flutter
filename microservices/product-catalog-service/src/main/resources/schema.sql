-- Product Catalog Service Database Schema
-- Database: catalog_db

-- Drop tables if they exist (for development)
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- Product categories table
CREATE TABLE product_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id BIGINT REFERENCES product_categories(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price_net DECIMAL(10,2) NOT NULL,
    vat_rate DECIMAL(5,4) NOT NULL DEFAULT 0.2000, -- 20% VAT by default
    category_id BIGINT REFERENCES product_categories(id),
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 0,
    weight_kg DECIMAL(8,3), -- Weight in kilograms
    dimensions_cm VARCHAR(50), -- Format: "L x W x H"
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_price_positive CHECK (price_net > 0),
    CONSTRAINT chk_vat_rate CHECK (vat_rate >= 0 AND vat_rate <= 1),
    CONSTRAINT chk_stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT chk_weight_positive CHECK (weight_kg IS NULL OR weight_kg > 0)
);

-- Indexes for performance
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active) WHERE is_active = true;
CREATE INDEX idx_products_featured ON products(is_featured) WHERE is_featured = true;
CREATE INDEX idx_products_price ON products(price_net);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_products_name_search ON products USING gin(to_tsvector('english', name));

CREATE INDEX idx_categories_parent ON product_categories(parent_category_id);
CREATE INDEX idx_categories_active ON product_categories(is_active) WHERE is_active = true;

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at 
    BEFORE UPDATE ON product_categories 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate gross price
CREATE OR REPLACE FUNCTION calculate_gross_price(net_price DECIMAL, vat_rate DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    RETURN ROUND(net_price * (1 + vat_rate), 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Views for common queries
CREATE VIEW product_catalog AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.sku,
    p.price_net,
    p.vat_rate,
    calculate_gross_price(p.price_net, p.vat_rate) as price_gross,
    p.stock_quantity,
    p.weight_kg,
    p.dimensions_cm,
    p.is_featured,
    c.name as category_name,
    p.created_at,
    p.updated_at,
    CASE 
        WHEN p.stock_quantity <= p.min_stock_level THEN 'LOW_STOCK'
        WHEN p.stock_quantity = 0 THEN 'OUT_OF_STOCK'
        ELSE 'IN_STOCK'
    END as stock_status
FROM products p
LEFT JOIN product_categories c ON p.category_id = c.id
WHERE p.is_active = true;

CREATE VIEW low_stock_products AS
SELECT 
    p.id,
    p.name,
    p.sku,
    p.stock_quantity,
    p.min_stock_level,
    c.name as category_name
FROM products p
LEFT JOIN product_categories c ON p.category_id = c.id
WHERE p.is_active = true 
  AND p.stock_quantity <= p.min_stock_level;

-- Sample data for development
INSERT INTO product_categories (name, description, parent_category_id) VALUES
('Electronics', 'Electronic devices and components', NULL),
('Computers', 'Desktop and laptop computers', 1),
('Phones', 'Mobile phones and accessories', 1),
('Software', 'Software products and licenses', NULL),
('Office Supplies', 'General office equipment and supplies', NULL);

INSERT INTO products (name, description, sku, price_net, vat_rate, category_id, stock_quantity, min_stock_level, weight_kg, dimensions_cm, is_featured) VALUES
('Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD', 'LAP-PRO-15-001', 1200.00, 0.2000, 2, 25, 5, 2.1, '35 x 24 x 2', true),
('Smartphone X1', 'Latest smartphone with advanced camera and 5G', 'PHONE-X1-001', 800.00, 0.2000, 3, 50, 10, 0.2, '15 x 7 x 1', true),
('Office Suite Pro', 'Professional office software suite license', 'SOFT-OFFICE-PRO', 299.99, 0.2000, 4, 100, 20, NULL, NULL, false),
('Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 'MOUSE-WL-001', 45.00, 0.2000, 1, 150, 25, 0.1, '12 x 6 x 4', false),
('Standing Desk', 'Adjustable height standing desk for office', 'DESK-STAND-001', 450.00, 0.2000, 5, 15, 3, 25.0, '120 x 60 x 80', true),
('USB-C Hub', 'Multi-port USB-C hub with HDMI and Ethernet', 'HUB-USBC-001', 75.00, 0.2000, 1, 80, 15, 0.3, '10 x 5 x 2', false),
('Monitor 27"', '4K UHD monitor with USB-C connectivity', 'MON-27-4K-001', 350.00, 0.2000, 1, 30, 5, 6.5, '61 x 36 x 5', true),
('Webcam HD', 'HD webcam with built-in microphone', 'WEBCAM-HD-001', 89.99, 0.2000, 1, 75, 15, 0.4, '8 x 3 x 3', false);

-- Update some products to simulate low stock
UPDATE products SET stock_quantity = 2 WHERE sku = 'DESK-STAND-001';
UPDATE products SET stock_quantity = 0 WHERE sku = 'HUB-USBC-001';