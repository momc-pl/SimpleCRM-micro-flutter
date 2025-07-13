-- Connect to auth database and create default roles
\c auth_db;

-- Create roles table and insert default roles
INSERT INTO roles (name, description, is_active, created_at, updated_at) VALUES
('ROLE_ADMIN', 'Administrator role with full access', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('ROLE_USER', 'Standard user role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('ROLE_SALES', 'Sales team role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('ROLE_MANAGER', 'Manager role with elevated access', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (name) DO NOTHING;