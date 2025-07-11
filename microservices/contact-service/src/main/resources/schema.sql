-- Contact Service Database Schema
-- Database: contact_db

-- Drop tables if they exist (for development)
DROP TABLE IF EXISTS contact_interactions CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;

-- Enum types
CREATE TYPE contact_type_enum AS ENUM ('PHONE', 'EMAIL', 'MEETING', 'NOTE', 'TASK', 'FOLLOW_UP');
CREATE TYPE contact_status_enum AS ENUM ('COMPLETED', 'PENDING', 'CANCELLED', 'SCHEDULED');
CREATE TYPE priority_enum AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- Contacts table - CRM contact management
CREATE TABLE contacts (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL, -- Reference to customer-service
    user_id BIGINT NOT NULL,     -- Reference to auth-service (who created the contact)
    contact_type contact_type_enum NOT NULL,
    status contact_status_enum DEFAULT 'PENDING',
    priority priority_enum DEFAULT 'MEDIUM',
    
    -- Contact details
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    notes TEXT,
    
    -- Scheduling
    scheduled_at TIMESTAMP,
    duration_minutes INTEGER,
    location VARCHAR(255), -- For meetings
    
    -- Communication details
    phone_number VARCHAR(20), -- For phone contacts
    email_address VARCHAR(255), -- For email contacts
    
    -- Metadata
    tags TEXT[], -- Array of tags for categorization
    external_reference VARCHAR(100), -- External system reference
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_phone_format CHECK (phone_number IS NULL OR phone_number ~ '^\+?[0-9\s\-()]+$'),
    CONSTRAINT chk_email_format CHECK (email_address IS NULL OR email_address ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_duration_positive CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    CONSTRAINT chk_scheduled_future CHECK (scheduled_at IS NULL OR scheduled_at >= created_at)
);

-- Contact interactions table - Track follow-ups and related activities
CREATE TABLE contact_interactions (
    id BIGSERIAL PRIMARY KEY,
    contact_id BIGINT NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL, -- Reference to auth-service (who performed the interaction)
    interaction_type contact_type_enum NOT NULL,
    
    -- Interaction details
    summary VARCHAR(255) NOT NULL,
    details TEXT,
    outcome TEXT,
    
    -- Next steps
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date TIMESTAMP,
    follow_up_notes TEXT,
    
    -- Metadata
    duration_minutes INTEGER,
    interaction_date TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT chk_interaction_duration_positive CHECK (duration_minutes IS NULL OR duration_minutes > 0)
);

-- Indexes for performance
CREATE INDEX idx_contacts_customer ON contacts(customer_id);
CREATE INDEX idx_contacts_user ON contacts(user_id);
CREATE INDEX idx_contacts_type ON contacts(contact_type);
CREATE INDEX idx_contacts_status ON contacts(status);
CREATE INDEX idx_contacts_priority ON contacts(priority);
CREATE INDEX idx_contacts_scheduled ON contacts(scheduled_at) WHERE scheduled_at IS NOT NULL;
CREATE INDEX idx_contacts_created_at ON contacts(created_at);
CREATE INDEX idx_contacts_tags ON contacts USING gin(tags);

CREATE INDEX idx_interactions_contact ON contact_interactions(contact_id);
CREATE INDEX idx_interactions_user ON contact_interactions(user_id);
CREATE INDEX idx_interactions_type ON contact_interactions(interaction_type);
CREATE INDEX idx_interactions_date ON contact_interactions(interaction_date);
CREATE INDEX idx_interactions_follow_up ON contact_interactions(follow_up_required) WHERE follow_up_required = true;

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_contacts_updated_at 
    BEFORE UPDATE ON contacts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to set completed_at when status changes to COMPLETED
CREATE OR REPLACE FUNCTION update_completed_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'COMPLETED' AND OLD.status != 'COMPLETED' THEN
        NEW.completed_at = NOW();
    ELSIF NEW.status != 'COMPLETED' THEN
        NEW.completed_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_completed_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_completed_at();

-- Views for common queries
CREATE VIEW contact_summary AS
SELECT 
    c.id,
    c.customer_id,
    c.user_id,
    c.contact_type,
    c.status,
    c.priority,
    c.subject,
    c.scheduled_at,
    c.created_at,
    c.completed_at,
    COUNT(ci.id) as interaction_count,
    MAX(ci.interaction_date) as last_interaction_date,
    SUM(CASE WHEN ci.follow_up_required THEN 1 ELSE 0 END) as pending_follow_ups
FROM contacts c
LEFT JOIN contact_interactions ci ON c.id = ci.contact_id
GROUP BY c.id, c.customer_id, c.user_id, c.contact_type, c.status, 
         c.priority, c.subject, c.scheduled_at, c.created_at, c.completed_at;

CREATE VIEW pending_contacts AS
SELECT 
    c.id,
    c.customer_id,
    c.user_id,
    c.contact_type,
    c.priority,
    c.subject,
    c.scheduled_at,
    c.created_at,
    CASE 
        WHEN c.scheduled_at < NOW() THEN 'OVERDUE'
        WHEN c.scheduled_at < NOW() + INTERVAL '1 day' THEN 'DUE_TODAY'
        WHEN c.scheduled_at < NOW() + INTERVAL '3 days' THEN 'DUE_SOON'
        ELSE 'SCHEDULED'
    END as urgency_status,
    EXTRACT(EPOCH FROM (NOW() - c.created_at))/3600 as hours_since_created
FROM contacts c
WHERE c.status IN ('PENDING', 'SCHEDULED')
ORDER BY 
    CASE c.priority 
        WHEN 'URGENT' THEN 1 
        WHEN 'HIGH' THEN 2 
        WHEN 'MEDIUM' THEN 3 
        ELSE 4 
    END,
    c.scheduled_at NULLS LAST,
    c.created_at;

CREATE VIEW contact_activity_timeline AS
SELECT 
    'CONTACT' as activity_type,
    c.id as activity_id,
    c.customer_id,
    c.user_id,
    c.contact_type::TEXT as type_detail,
    c.subject as activity_summary,
    c.description as activity_details,
    c.created_at as activity_date
FROM contacts c
UNION ALL
SELECT 
    'INTERACTION' as activity_type,
    ci.id as activity_id,
    c.customer_id,
    ci.user_id,
    ci.interaction_type::TEXT as type_detail,
    ci.summary as activity_summary,
    ci.details as activity_details,
    ci.interaction_date as activity_date
FROM contact_interactions ci
JOIN contacts c ON ci.contact_id = c.id
ORDER BY activity_date DESC;

CREATE VIEW customer_contact_stats AS
SELECT 
    customer_id,
    COUNT(*) as total_contacts,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_contacts,
    COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pending_contacts,
    COUNT(CASE WHEN priority = 'HIGH' OR priority = 'URGENT' THEN 1 END) as high_priority_contacts,
    MAX(created_at) as last_contact_date,
    AVG(EXTRACT(EPOCH FROM (completed_at - created_at))/3600) as avg_completion_hours
FROM contacts
GROUP BY customer_id;

-- Sample data for development
INSERT INTO contacts (customer_id, user_id, contact_type, status, priority, subject, description, scheduled_at, phone_number, email_address, tags) VALUES
(1, 1, 'PHONE', 'COMPLETED', 'HIGH', 'Follow up on laptop purchase', 'Customer called about laptop delivery status', NOW() - INTERVAL '2 days', '+1-555-0101', NULL, ARRAY['sales', 'follow-up']),
(1, 1, 'EMAIL', 'PENDING', 'MEDIUM', 'Product recommendation', 'Send recommendations for accessories', NOW() + INTERVAL '1 day', NULL, 'john.smith@email.com', ARRAY['sales', 'upsell']),
(2, 2, 'MEETING', 'SCHEDULED', 'HIGH', 'Product demo', 'Schedule product demonstration for new features', NOW() + INTERVAL '3 days', NULL, 'jane.doe@email.com', ARRAY['demo', 'sales']),
(3, 1, 'TASK', 'PENDING', 'URGENT', 'Contract renewal', 'Prepare contract renewal documents for enterprise client', NOW() + INTERVAL '1 hour', NULL, NULL, ARRAY['contract', 'enterprise']),
(2, 2, 'NOTE', 'COMPLETED', 'LOW', 'Customer feedback', 'Customer provided positive feedback on recent purchase', NOW() - INTERVAL '1 day', NULL, NULL, ARRAY['feedback', 'satisfaction']),
(4, 1, 'FOLLOW_UP', 'PENDING', 'MEDIUM', 'Reactivation campaign', 'Follow up with inactive customer to understand needs', NOW() + INTERVAL '2 days', '+1-555-0104', 'alice.brown@email.com', ARRAY['reactivation', 'retention']),
(5, 2, 'PHONE', 'COMPLETED', 'HIGH', 'Technical support', 'Resolved software installation issue', NOW() - INTERVAL '3 hours', '+1-555-0105', NULL, ARRAY['support', 'technical']);

-- Sample contact interactions
INSERT INTO contact_interactions (contact_id, user_id, interaction_type, summary, details, outcome, follow_up_required, follow_up_date, follow_up_notes, duration_minutes) VALUES
(1, 1, 'PHONE', 'Initial customer call', 'Customer called asking about laptop delivery', 'Provided tracking information, customer satisfied', FALSE, NULL, NULL, 15),
(1, 1, 'EMAIL', 'Sent tracking details', 'Emailed detailed tracking information and delivery schedule', 'Customer acknowledged receipt', TRUE, NOW() + INTERVAL '1 week', 'Follow up to ensure delivery was successful', 5),
(3, 2, 'EMAIL', 'Demo scheduling', 'Sent calendar invite for product demonstration', 'Meeting scheduled for next week', FALSE, NULL, NULL, 10),
(4, 1, 'NOTE', 'Document preparation', 'Started preparing contract renewal documents', 'Documents 50% complete', TRUE, NOW() + INTERVAL '1 day', 'Complete contract documents and send for review', NULL),
(5, 2, 'NOTE', 'Feedback collection', 'Recorded customer feedback during phone call', 'Very positive feedback, customer highly satisfied', FALSE, NULL, NULL, NULL),
(7, 2, 'PHONE', 'Technical support call', 'Customer called with software installation problems', 'Issue resolved, software working correctly', TRUE, NOW() + INTERVAL '1 week', 'Check in to ensure no further issues', 45);

-- Update completed_at for completed contacts
UPDATE contacts SET completed_at = created_at + INTERVAL '2 hours' WHERE status = 'COMPLETED';