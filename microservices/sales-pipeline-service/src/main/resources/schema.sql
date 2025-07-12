-- Sales Pipeline Service Database Schema

-- Create leads table
CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    company VARCHAR(255),
    job_title VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'NEW',
    source VARCHAR(50),
    estimated_value DECIMAL(19,2),
    notes TEXT,
    assigned_to BIGINT,
    qualification_score INTEGER,
    conversion_probability INTEGER,
    last_contact_date TIMESTAMP,
    next_follow_up_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create pipelines table
CREATE TABLE IF NOT EXISTS pipelines (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create pipeline_stages table
CREATE TABLE IF NOT EXISTS pipeline_stages (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    stage_order INTEGER NOT NULL,
    default_probability INTEGER,
    pipeline_id BIGINT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pipeline_id) REFERENCES pipelines(id) ON DELETE CASCADE
);

-- Create opportunities table
CREATE TABLE IF NOT EXISTS opportunities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    customer_id BIGINT NOT NULL,
    lead_id BIGINT,
    value DECIMAL(19,2) NOT NULL,
    stage VARCHAR(50) NOT NULL DEFAULT 'PROSPECTING',
    probability INTEGER,
    expected_close_date TIMESTAMP,
    actual_close_date TIMESTAMP,
    assigned_to BIGINT,
    priority VARCHAR(50) DEFAULT 'MEDIUM',
    next_step VARCHAR(500),
    competitor VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE SET NULL
);

-- Create sales_activities table
CREATE TABLE IF NOT EXISTS sales_activities (
    id BIGSERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    lead_id BIGINT,
    opportunity_id BIGINT,
    customer_id BIGINT,
    assigned_to BIGINT,
    activity_date TIMESTAMP NOT NULL,
    duration_minutes INTEGER,
    status VARCHAR(50) DEFAULT 'PLANNED',
    outcome VARCHAR(500),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE,
    FOREIGN KEY (opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_assigned_to ON leads(assigned_to);
CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_company ON leads(company);
CREATE INDEX IF NOT EXISTS idx_leads_next_follow_up ON leads(next_follow_up_date);

CREATE INDEX IF NOT EXISTS idx_opportunities_stage ON opportunities(stage);
CREATE INDEX IF NOT EXISTS idx_opportunities_customer_id ON opportunities(customer_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_assigned_to ON opportunities(assigned_to);
CREATE INDEX IF NOT EXISTS idx_opportunities_expected_close ON opportunities(expected_close_date);
CREATE INDEX IF NOT EXISTS idx_opportunities_value ON opportunities(value);

CREATE INDEX IF NOT EXISTS idx_activities_type ON sales_activities(type);
CREATE INDEX IF NOT EXISTS idx_activities_status ON sales_activities(status);
CREATE INDEX IF NOT EXISTS idx_activities_assigned_to ON sales_activities(assigned_to);
CREATE INDEX IF NOT EXISTS idx_activities_date ON sales_activities(activity_date);
CREATE INDEX IF NOT EXISTS idx_activities_lead_id ON sales_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_activities_opportunity_id ON sales_activities(opportunity_id);

-- Insert default pipeline and stages
INSERT INTO pipelines (name, description, is_default, is_active) 
VALUES ('Standard Sales Pipeline', 'Default sales pipeline for opportunities', TRUE, TRUE)
ON CONFLICT DO NOTHING;

-- Get the pipeline ID (assuming it's the first one)
DO $$
DECLARE
    pipeline_id BIGINT;
BEGIN
    SELECT id INTO pipeline_id FROM pipelines WHERE is_default = TRUE LIMIT 1;
    
    IF pipeline_id IS NOT NULL THEN
        INSERT INTO pipeline_stages (name, description, stage_order, default_probability, pipeline_id) VALUES
        ('Prospecting', 'Initial research and lead identification', 1, 10, pipeline_id),
        ('Qualification', 'Lead qualification and initial contact', 2, 25, pipeline_id),
        ('Needs Analysis', 'Understanding customer needs and requirements', 3, 40, pipeline_id),
        ('Proposal', 'Presenting solution and proposal', 4, 60, pipeline_id),
        ('Negotiation', 'Negotiating terms and conditions', 5, 80, pipeline_id),
        ('Closing', 'Final closing activities', 6, 90, pipeline_id),
        ('Won', 'Successfully closed deal', 7, 100, pipeline_id),
        ('Lost', 'Lost opportunity', 8, 0, pipeline_id)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;