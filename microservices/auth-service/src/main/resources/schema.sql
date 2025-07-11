-- Auth Service Database Schema
-- Database: auth_db

-- Drop tables if they exist (for development)
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    picture_url VARCHAR(500), -- Google profile picture
    locale VARCHAR(10) DEFAULT 'en_US',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(50) DEFAULT 'USER', -- USER, ADMIN, MANAGER
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_role CHECK (role IN ('USER', 'ADMIN', 'MANAGER'))
);

-- User sessions for tracking active sessions
CREATE TABLE user_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(500) UNIQUE NOT NULL,
    refresh_token VARCHAR(500),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_accessed TIMESTAMP DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes for performance
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active) WHERE is_active = true;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_last_login ON users(last_login);

CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_sessions_active ON user_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM user_sessions WHERE expires_at < NOW();
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Views for common queries
CREATE VIEW active_users AS
SELECT 
    id,
    google_id,
    name,
    email,
    role,
    created_at,
    last_login,
    CASE 
        WHEN last_login > NOW() - INTERVAL '30 days' THEN 'ACTIVE'
        WHEN last_login > NOW() - INTERVAL '90 days' THEN 'INACTIVE'
        ELSE 'DORMANT'
    END as activity_status
FROM users 
WHERE is_active = true;

CREATE VIEW user_session_summary AS
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(s.id) as active_sessions,
    MAX(s.last_accessed) as latest_session,
    MIN(s.created_at) as earliest_session
FROM users u
LEFT JOIN user_sessions s ON u.id = s.user_id AND s.is_active = true
GROUP BY u.id, u.name, u.email;

-- Sample data for development
INSERT INTO users (google_id, name, email, picture_url, role, last_login) VALUES
('google_123456789', 'John Admin', 'john.admin@company.com', 'https://lh3.googleusercontent.com/a/default-user', 'ADMIN', NOW() - INTERVAL '1 hour'),
('google_987654321', 'Jane Manager', 'jane.manager@company.com', 'https://lh3.googleusercontent.com/a/default-user', 'MANAGER', NOW() - INTERVAL '2 hours'),
('google_555666777', 'Bob User', 'bob.user@company.com', 'https://lh3.googleusercontent.com/a/default-user', 'USER', NOW() - INTERVAL '1 day'),
('google_111222333', 'Alice Developer', 'alice.dev@company.com', 'https://lh3.googleusercontent.com/a/default-user', 'USER', NOW() - INTERVAL '3 hours'),
('google_444555666', 'Charlie Sales', 'charlie.sales@company.com', 'https://lh3.googleusercontent.com/a/default-user', 'USER', NOW() - INTERVAL '6 hours');

-- Create some sample active sessions
INSERT INTO user_sessions (user_id, session_token, refresh_token, expires_at, ip_address, user_agent) VALUES
(1, 'session_token_admin_123', 'refresh_token_admin_123', NOW() + INTERVAL '7 days', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'),
(2, 'session_token_manager_456', 'refresh_token_manager_456', NOW() + INTERVAL '7 days', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'),
(3, 'session_token_user_789', 'refresh_token_user_789', NOW() + INTERVAL '7 days', '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36');