# Database Decomposition Analysis for Microservices Architecture

## Current Monolithic Database Schema

### Core Entities Identified:
1. **Customer** - Customer information and contact details
2. **User** - System users with Google authentication
3. **Order** - Order transactions linking customers and users
4. **OrderLine** - Individual line items within orders
5. **Product** - Product catalog with pricing
6. **Address** - Customer addresses (1:N with Customer)

### Current Entity Relationships:
- Customer 1:N Address
- Customer 1:N Order  
- User 1:N Order
- Order 1:N OrderLine
- Product 1:N OrderLine

## Proposed Microservice Database Decomposition

### 1. Customer Service Database (`customer_db`)
**Entities:** Customer, Address
**Rationale:** Customer and address data are tightly coupled and accessed together

```sql
-- Customer Service Schema
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    customer_type VARCHAR(20) DEFAULT 'INDIVIDUAL',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    notes TEXT,
    user_id BIGINT, -- Foreign key reference to auth-service
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE addresses (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id) ON DELETE CASCADE,
    street VARCHAR(255),
    city VARCHAR(100),
    zip VARCHAR(20),
    country VARCHAR(100),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Auth Service Database (`auth_db`)
**Entities:** User
**Rationale:** Authentication and user management is a cross-cutting concern

```sql
-- Auth Service Schema
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    google_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

### 3. Product Catalog Service Database (`catalog_db`)
**Entities:** Product
**Rationale:** Product catalog can be managed independently

```sql
-- Product Catalog Service Schema
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_net DECIMAL(10,2) NOT NULL,
    vat_rate DECIMAL(5,4) NOT NULL,
    category VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 4. Order Service Database (`order_db`)
**Entities:** Order, OrderLine
**Rationale:** Orders and order lines are transactional data that belong together

```sql
-- Order Service Schema
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id BIGINT NOT NULL, -- Reference to customer-service
    user_id BIGINT NOT NULL,     -- Reference to auth-service
    total_net DECIMAL(10,2) NOT NULL,
    total_vat DECIMAL(10,2) NOT NULL,
    total_gross DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_lines (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL, -- Reference to catalog-service
    product_name VARCHAR(255), -- Denormalized for performance
    quantity INTEGER NOT NULL,
    unit_price_net DECIMAL(10,2) NOT NULL,
    line_vat DECIMAL(10,2) NOT NULL,
    line_total_gross DECIMAL(10,2) NOT NULL
);
```

### 5. Contact Service Database (`contact_db`)
**Entities:** Contact, ContactActivity
**Rationale:** CRM contact management separate from basic customer data

```sql
-- Contact Service Schema
CREATE TABLE contacts (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL, -- Reference to customer-service
    contact_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    notes TEXT,
    user_id BIGINT NOT NULL, -- Reference to auth-service
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Cross-Service Data Access Patterns

### 1. Reference Data by ID
- Services store foreign key IDs but fetch related data via API calls
- Example: Order service stores `customer_id` but calls Customer API for customer details

### 2. Data Denormalization
- Store frequently accessed data locally to reduce cross-service calls
- Example: Order lines store `product_name` from Product service

### 3. Event-Driven Synchronization
- Use domain events to keep related data synchronized
- Example: Customer email change triggers update events

## Data Consistency Strategies

### 1. Eventual Consistency with Saga Pattern
For cross-service transactions (e.g., order creation):

```
Order Creation Saga:
1. Validate Customer (Customer Service)
2. Reserve Products (Catalog Service) 
3. Create Order (Order Service)
4. Update Customer Stats (Customer Service)
5. Send Notifications (Notification Service)

Compensation Actions:
- Cancel Order → Unreserve Products → Revert Customer Stats
```

### 2. Database-per-Service Pattern
- Each microservice owns its database
- No direct database access between services
- API-only communication

### 3. Event Sourcing for Audit Trail
- Store domain events for critical business transactions
- Enables replay and audit capabilities

## Migration Strategy

### Phase 1: Preparation
1. **Create Service-Specific Databases**
   ```sql
   CREATE DATABASE customer_db;
   CREATE DATABASE auth_db;
   CREATE DATABASE catalog_db;
   CREATE DATABASE order_db;
   CREATE DATABASE contact_db;
   ```

2. **Set Up Database Users**
   ```sql
   -- Service-specific users with limited permissions
   CREATE USER customer_user WITH PASSWORD 'customer_secret';
   GRANT ALL ON DATABASE customer_db TO customer_user;
   ```

### Phase 2: Data Migration Scripts

#### Customer Service Migration
```sql
-- Migrate customer and address data
INSERT INTO customer_db.customers 
SELECT id, name, email, phone, 'INDIVIDUAL' as customer_type, 
       'ACTIVE' as status, '' as notes, NULL as user_id,
       NOW() as created_at, NOW() as updated_at
FROM monolith.customers;

INSERT INTO customer_db.addresses
SELECT id, customer_id, street, city, zip, country, 
       FALSE as is_primary, NOW() as created_at
FROM monolith.addresses;
```

#### Auth Service Migration
```sql
-- Migrate user data
INSERT INTO auth_db.users
SELECT id, google_id, name, email, NOW() as created_at, 
       NOW() as updated_at, NULL as last_login, TRUE as is_active
FROM monolith.users;
```

#### Product Catalog Migration
```sql
-- Migrate product data
INSERT INTO catalog_db.products
SELECT id, name, '' as description, price_net, vat_rate,
       'General' as category, CONCAT('SKU-', id) as sku,
       TRUE as is_active, NOW() as created_at, NOW() as updated_at
FROM monolith.products;
```

#### Order Service Migration
```sql
-- Migrate order data
INSERT INTO order_db.orders
SELECT id, order_number, customer_id, user_id, total_net, 
       total_vat, total_gross, 'COMPLETED' as status,
       created_at, created_at as updated_at
FROM monolith.orders;

INSERT INTO order_db.order_lines
SELECT ol.id, ol.order_id, ol.product_id, p.name as product_name,
       ol.quantity, ol.unit_price_net, ol.line_vat, ol.line_total_gross
FROM monolith.order_lines ol
JOIN monolith.products p ON ol.product_id = p.id;
```

### Phase 3: Data Synchronization Setup

#### Event Publishing Infrastructure
```sql
-- Event outbox pattern for reliable event publishing
CREATE TABLE outbox_events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_id VARCHAR(255),
    event_type VARCHAR(100),
    event_data JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE
);
```

#### Cross-Service API Integration
```yaml
# Customer Service API calls to other services
auth-service:
  base-url: http://auth-service:8080/api/v1
  endpoints:
    user-info: /users/{userId}

order-service:
  base-url: http://order-service:8082/api/v1
  endpoints:
    customer-orders: /orders/customer/{customerId}
```

## Performance Considerations

### 1. Database Connection Pooling
```yaml
# Per-service connection pool configuration
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
```

### 2. Read Replicas
- Set up read replicas for reporting and analytics
- Route read-only queries to replicas

### 3. Caching Strategy
```yaml
# Redis caching configuration
spring:
  cache:
    type: redis
  redis:
    host: redis-cluster
    port: 6379
```

### 4. Database Monitoring
```sql
-- Performance monitoring views
CREATE VIEW service_performance AS
SELECT 
    schemaname,
    tablename,
    n_tup_ins + n_tup_upd + n_tup_del as total_operations,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes
FROM pg_stat_user_tables;
```

## Implementation Checklist

### Database Setup
- [ ] Create service-specific databases
- [ ] Set up database users with minimal permissions
- [ ] Configure connection pooling
- [ ] Set up monitoring and alerting

### Data Migration
- [ ] Execute customer service migration
- [ ] Execute auth service migration  
- [ ] Execute catalog service migration
- [ ] Execute order service migration
- [ ] Validate data integrity post-migration

### API Integration
- [ ] Implement service-to-service authentication
- [ ] Set up circuit breakers for resilience
- [ ] Configure API gateways
- [ ] Implement request/response logging

### Event Infrastructure
- [ ] Set up message broker (RabbitMQ/Kafka)
- [ ] Implement event publishing
- [ ] Set up event handlers
- [ ] Test saga compensation flows

### Monitoring & Operations
- [ ] Database performance monitoring
- [ ] Service health checks
- [ ] Distributed tracing setup
- [ ] Backup and disaster recovery procedures

## Security Considerations

### 1. Network Security
- Database servers isolated in private networks
- Service-to-service communication over TLS
- Database access only from authorized services

### 2. Authentication & Authorization
- Service accounts with minimal required permissions
- JWT tokens for inter-service communication
- API rate limiting and throttling

### 3. Data Protection
- Encryption at rest for sensitive data
- PII data masking in non-production environments
- Regular security audits and vulnerability scans

This decomposition strategy enables independent scaling, development, and deployment of each microservice while maintaining data consistency and system reliability.