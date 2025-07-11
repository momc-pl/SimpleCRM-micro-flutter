# Simple CRM Microservices Architecture Design

## 🎯 Executive Summary

This document outlines the complete microservices decomposition strategy for the Simple CRM system, transforming the existing monolith into a distributed, scalable architecture with 8 core services.

## 📊 Current State Analysis

### Monolith Structure
- **Entities**: Customer, Order, Product, User, Address, OrderLine
- **Controllers**: CustomerController, DashboardController, LoginController
- **Services**: OrderService, UserService
- **Authentication**: OAuth2 with Google
- **Database**: Single PostgreSQL database with JPA/Hibernate
- **UI**: Thymeleaf server-side templates

### Identified Issues
1. **Tight Coupling**: All business logic in single application
2. **Single Database**: All entities share same database
3. **Deployment Complexity**: Single deployment unit
4. **Scaling Limitations**: Cannot scale individual components
5. **Technology Lock-in**: All services must use same tech stack

## 🏗️ Microservices Architecture Overview

### Service Decomposition Strategy

The system will be decomposed into **8 core microservices** based on Domain-Driven Design principles:

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway                               │
│                    (Load Balancer, Auth, Routing)               │
└──────────────┬──────────────┬──────────────┬──────────────────┘
               │              │              │
        ┌──────▼────┐  ┌──────▼────┐  ┌──────▼────┐
        │   Auth    │  │ Customer  │  │   Order   │
        │ Service   │  │ Service   │  │ Service   │
        └───────────┘  └───────────┘  └───────────┘
               │              │              │
        ┌──────▼────┐  ┌──────▼────┐  ┌──────▼────┐
        │ Product   │  │ Inventory │  │   Sales   │
        │ Service   │  │ Service   │  │ Pipeline  │
        └───────────┘  └───────────┘  └───────────┘
               │
        ┌──────▼────┐
        │Notification│
        │ Service   │
        └───────────┘
```

## 🎯 Service Boundaries and Responsibilities

### 1. API Gateway Service
**Port**: 8080
**Database**: Configuration DB (Redis)
**Responsibilities**:
- Request routing and load balancing
- Authentication and authorization
- Rate limiting and throttling
- Request/response transformation
- Service discovery integration
- CORS handling
- API versioning

**Key Features**:
- JWT token validation
- Circuit breaker pattern
- Request logging and monitoring
- Dynamic routing based on service health

### 2. Auth Service
**Port**: 8081
**Database**: User DB (PostgreSQL)
**Responsibilities**:
- User authentication and authorization
- OAuth2 integration with Google
- JWT token generation and validation
- User profile management
- Role-based access control (RBAC)
- Session management

**APIs**:
- `POST /auth/login` - Authenticate user
- `POST /auth/logout` - Invalidate session
- `GET /auth/profile` - Get user profile
- `POST /auth/refresh` - Refresh JWT token
- `GET /auth/validate` - Validate token

### 3. Customer Service
**Port**: 8082
**Database**: Customer DB (PostgreSQL)
**Responsibilities**:
- Customer CRUD operations
- Customer profile management
- Address management
- Customer segmentation
- Customer search and filtering
- Data validation and business rules

**APIs**:
- `GET /customers` - List customers with pagination
- `POST /customers` - Create new customer
- `GET /customers/{id}` - Get customer details
- `PUT /customers/{id}` - Update customer
- `DELETE /customers/{id}` - Soft delete customer
- `GET /customers/{id}/addresses` - Get customer addresses
- `POST /customers/{id}/addresses` - Add customer address

### 4. Product Service
**Port**: 8083
**Database**: Product DB (PostgreSQL)
**Responsibilities**:
- Product catalog management
- Pricing and VAT calculation
- Product categories and attributes
- Inventory tracking integration
- Product search and filtering
- Discount and promotion rules

**APIs**:
- `GET /products` - List products with pagination
- `POST /products` - Create new product
- `GET /products/{id}` - Get product details
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Soft delete product
- `GET /products/search` - Search products

### 5. Order Service
**Port**: 8084
**Database**: Order DB (PostgreSQL)
**Responsibilities**:
- Order lifecycle management
- Order calculation (totals, VAT, discounts)
- Order line item management
- Order status tracking
- Integration with Customer and Product services
- Order history and reporting

**APIs**:
- `GET /orders` - List orders with filters
- `POST /orders` - Create new order
- `GET /orders/{id}` - Get order details
- `PUT /orders/{id}` - Update order
- `GET /orders/customer/{customerId}` - Get customer orders
- `PUT /orders/{id}/status` - Update order status

### 6. Inventory Service
**Port**: 8085
**Database**: Inventory DB (PostgreSQL)
**Responsibilities**:
- Stock level management
- Inventory tracking and updates
- Stock alerts and notifications
- Warehouse management
- Stock reservation for orders
- Inventory reporting and analytics

**APIs**:
- `GET /inventory/products/{productId}` - Get stock level
- `POST /inventory/reserve` - Reserve stock for order
- `POST /inventory/release` - Release reserved stock
- `PUT /inventory/adjust` - Adjust stock levels
- `GET /inventory/alerts` - Get low stock alerts

### 7. Sales Pipeline Service
**Port**: 8086
**Database**: Sales DB (PostgreSQL)
**Responsibilities**:
- Lead management
- Opportunity tracking
- Sales funnel analytics
- Contact management
- Task and activity tracking
- Sales reporting and forecasting

**APIs**:
- `GET /leads` - List leads
- `POST /leads` - Create new lead
- `PUT /leads/{id}/convert` - Convert lead to customer
- `GET /opportunities` - List opportunities
- `POST /opportunities` - Create opportunity
- `PUT /opportunities/{id}/stage` - Update opportunity stage

### 8. Notification Service
**Port**: 8087
**Database**: Notification DB (PostgreSQL) + Redis Cache
**Responsibilities**:
- Email notifications
- SMS notifications
- In-app notifications
- Notification templates
- Delivery tracking
- Event-driven notifications

**APIs**:
- `POST /notifications/email` - Send email
- `POST /notifications/sms` - Send SMS
- `GET /notifications/user/{userId}` - Get user notifications
- `PUT /notifications/{id}/read` - Mark as read

## 🔗 Inter-Service Communication Patterns

### 1. Synchronous Communication (REST APIs)
**When to Use**: Real-time data requirements, immediate consistency needed

**Patterns**:
- **Service-to-Service**: Direct HTTP calls with circuit breakers
- **API Gateway**: Routes external requests to appropriate services
- **Authentication**: JWT tokens passed between services

**Example Flow**:
```
Client → API Gateway → Order Service → Product Service (get pricing)
                    ↓
                 Customer Service (validate customer)
```

### 2. Asynchronous Communication (Events)
**When to Use**: Eventual consistency acceptable, loose coupling required

**Event Types**:
- **CustomerCreated**: When new customer is registered
- **OrderPlaced**: When order is successfully created
- **ProductUpdated**: When product information changes
- **InventoryLow**: When stock falls below threshold
- **PaymentProcessed**: When payment is completed

**Event Bus**: Apache Kafka or RabbitMQ

**Example Event Flow**:
```
Order Service → OrderPlaced Event → Inventory Service (update stock)
                                 → Notification Service (send confirmation)
                                 → Sales Service (update metrics)
```

### 3. Data Consistency Patterns

#### Saga Pattern for Distributed Transactions
**Order Creation Saga**:
1. Validate customer (Customer Service)
2. Check product availability (Product Service)
3. Reserve inventory (Inventory Service)
4. Create order (Order Service)
5. Send confirmation (Notification Service)

If any step fails, compensating actions are triggered.

#### Event Sourcing for Audit Trail
- Order Service maintains event log
- All order changes stored as events
- Current state rebuilt from events
- Complete audit trail available

## 🗄️ Data Separation and Database Strategy

### Database per Service Pattern

Each microservice owns its data and database:

```
Auth Service     → PostgreSQL (Users, Roles, Sessions)
Customer Service → PostgreSQL (Customers, Addresses)
Product Service  → PostgreSQL (Products, Categories, Pricing)
Order Service    → PostgreSQL (Orders, OrderLines)
Inventory Service→ PostgreSQL (Stock, Warehouses, Movements)
Sales Service    → PostgreSQL (Leads, Opportunities, Activities)
Notification Service → PostgreSQL (Templates, Logs) + Redis (Cache)
API Gateway     → Redis (Configuration, Rate Limiting)
```

### Data Migration Strategy

**Phase 1: Extract Services with Shared Database**
- Create microservices but keep shared database
- Validate service boundaries and APIs
- Test inter-service communication

**Phase 2: Database Separation**
- Create separate databases for each service
- Migrate data using ETL processes
- Update connection strings and configurations

**Phase 3: Data Synchronization**
- Implement event-driven synchronization
- Remove direct database access between services
- Implement eventual consistency patterns

### Data Duplication Strategy

**Read Models**: Each service maintains read-only copies of frequently accessed data from other services

**Example**:
- Order Service maintains customer name/email (from Customer Service)
- Product Service maintains basic inventory count (from Inventory Service)
- Customer Service maintains order count (from Order Service)

## 🚪 API Gateway Design

### Routing Configuration
```yaml
routes:
  - path: /api/auth/**
    service: auth-service
    port: 8081
    
  - path: /api/customers/**
    service: customer-service
    port: 8082
    auth: required
    
  - path: /api/products/**
    service: product-service
    port: 8083
    auth: required
    
  - path: /api/orders/**
    service: order-service
    port: 8084
    auth: required
    
  - path: /api/inventory/**
    service: inventory-service
    port: 8085
    auth: required
    roles: [admin, manager]
    
  - path: /api/sales/**
    service: sales-pipeline-service
    port: 8086
    auth: required
    
  - path: /api/notifications/**
    service: notification-service
    port: 8087
    auth: required
```

### Security Configuration
- **JWT Validation**: Validate tokens before routing
- **RBAC**: Role-based access control
- **Rate Limiting**: Per-user and per-service limits
- **CORS**: Cross-origin resource sharing configuration
- **SSL Termination**: Handle HTTPS certificates

### Load Balancing
- **Round Robin**: Default for most services
- **Weighted**: Based on service capacity
- **Health Checks**: Remove unhealthy instances
- **Circuit Breaker**: Prevent cascade failures

## 🔍 Service Discovery and Configuration

### Service Registry Pattern
**Implementation**: Netflix Eureka or Consul

**Service Registration**:
```yaml
service:
  name: customer-service
  port: 8082
  health-check: /actuator/health
  metadata:
    version: 1.0.0
    environment: production
```

**Service Discovery**:
- Services register themselves on startup
- API Gateway queries registry for service locations
- Automatic failover to healthy instances
- Load balancing across multiple instances

### Configuration Management
**Implementation**: Spring Cloud Config Server or Consul KV

**Configuration Hierarchy**:
```
application-default.yml     # Default settings
application-{service}.yml   # Service-specific settings
application-{env}.yml       # Environment-specific settings
```

**Dynamic Configuration**:
- Hot reload of configuration changes
- Feature flags for A/B testing
- Circuit breaker thresholds
- Database connection settings

## 🚀 Deployment and Orchestration Strategy

### Containerization
**Docker Images**: Each service packaged as Docker container

**Base Image Structure**:
```dockerfile
FROM openjdk:11-jre-slim
COPY target/service.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Kubernetes Orchestration
**Deployment Strategy**:
- **Rolling Updates**: Zero-downtime deployments
- **Blue-Green**: For critical services
- **Canary**: For testing new features

**Resource Management**:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Scaling Strategy**:
- **Horizontal Pod Autoscaler**: Scale based on CPU/memory
- **Vertical Pod Autoscaler**: Adjust resource requests
- **Custom Metrics**: Scale based on business metrics

### Service Mesh (Optional)
**Implementation**: Istio or Linkerd

**Features**:
- **Traffic Management**: Advanced routing and load balancing
- **Security**: mTLS between services
- **Observability**: Distributed tracing and metrics
- **Policy Enforcement**: Rate limiting and access control

## 📊 Monitoring and Logging Architecture

### Observability Stack
**Metrics**: Prometheus + Grafana
**Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
**Tracing**: Jaeger or Zipkin
**Alerting**: Prometheus Alertmanager

### Application Metrics
**Business Metrics**:
- Orders per minute
- Customer registration rate
- Product catalog updates
- Revenue per service

**Technical Metrics**:
- Response times (p50, p95, p99)
- Error rates by service
- Database connection pool usage
- Memory and CPU utilization

### Centralized Logging
**Log Aggregation**:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "service": "order-service",
  "level": "INFO",
  "traceId": "abc123",
  "spanId": "def456",
  "message": "Order created successfully",
  "orderId": "ORD-12345",
  "customerId": "CUST-67890"
}
```

**Log Correlation**:
- Correlation IDs across service calls
- User session tracking
- Request journey visualization

### Distributed Tracing
**Trace Flow Example**:
```
Client Request → API Gateway → Order Service → Customer Service
                            ↓
                         Product Service → Inventory Service
```

Each hop tracked with timing and status information.

### Health Checks and Circuit Breakers
**Health Check Endpoints**:
- `/actuator/health` - Service health status
- `/actuator/info` - Service information
- `/actuator/metrics` - Prometheus metrics

**Circuit Breaker Pattern**:
- Fail fast when downstream service is down
- Automatic recovery when service is healthy
- Fallback responses for graceful degradation

## 📈 Performance and Scalability Considerations

### Caching Strategy
**Redis Distributed Cache**:
- Product catalog cache (TTL: 1 hour)
- Customer profile cache (TTL: 30 minutes)
- Authentication token cache (TTL: 15 minutes)
- Configuration cache (TTL: 5 minutes)

**Cache Patterns**:
- **Cache-Aside**: Application manages cache
- **Write-Through**: Update cache on write
- **Write-Behind**: Asynchronous cache updates

### Database Optimization
**Connection Pooling**:
```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```

**Read Replicas**:
- Read operations on replica databases
- Write operations on primary database
- Eventual consistency for read models

### Asynchronous Processing
**Message Queues**:
- Order processing queue
- Notification delivery queue
- Inventory update queue
- Reporting and analytics queue

**Event Processing**:
- Apache Kafka for high-throughput events
- RabbitMQ for reliable message delivery
- Dead letter queues for failed messages

## 🔒 Security Architecture

### Authentication and Authorization
**JWT Token Structure**:
```json
{
  "sub": "user123",
  "name": "John Doe",
  "email": "john@example.com",
  "roles": ["user", "manager"],
  "iat": 1640995200,
  "exp": 1641081600
}
```

**OAuth2 Flow**:
1. User authenticates with Google OAuth2
2. Auth Service validates with Google
3. Auth Service generates JWT token
4. Client includes JWT in requests
5. API Gateway validates JWT
6. Request forwarded to target service

### Service-to-Service Security
**Mutual TLS (mTLS)**:
- Encrypted communication between services
- Certificate-based authentication
- Automatic certificate rotation

**API Keys**:
- Internal service authentication
- Rate limiting per service
- Audit trail for service access

### Data Protection
**Encryption**:
- Data at rest: Database encryption
- Data in transit: TLS 1.3
- Sensitive data: Application-level encryption

**Data Privacy**:
- PII data anonymization
- GDPR compliance features
- Data retention policies
- Right to be forgotten implementation

## 🏃‍♂️ Migration Strategy

### Phase 1: Strangler Fig Pattern (Month 1-2)
- Deploy microservices alongside monolith
- Route new features to microservices
- Keep existing features in monolith
- Validate service boundaries

### Phase 2: Gradual Migration (Month 3-4)
- Migrate customer management to Customer Service
- Migrate product catalog to Product Service
- Update UI to call microservice APIs
- Implement event-driven communication

### Phase 3: Data Separation (Month 5-6)
- Extract customer data to Customer Service DB
- Extract product data to Product Service DB
- Implement data synchronization
- Remove shared database dependencies

### Phase 4: Complete Decomposition (Month 7-8)
- Migrate all remaining features
- Decommission monolith
- Optimize service interactions
- Complete monitoring and alerting setup

### Rollback Strategy
**Feature Flags**:
- Toggle between monolith and microservice
- Gradual traffic migration
- Immediate rollback capability

**Database Rollback**:
- Database backup before migration
- Data synchronization verification
- Rollback scripts for emergency recovery

## 📊 Success Metrics

### Technical Metrics
- **Service Availability**: 99.9% uptime per service
- **Response Time**: p95 < 200ms for API calls
- **Error Rate**: < 0.1% for all services
- **Deployment Frequency**: Daily deployments
- **Mean Time to Recovery**: < 10 minutes

### Business Metrics
- **Development Velocity**: 50% faster feature delivery
- **Scalability**: 10x traffic capacity
- **Cost Efficiency**: 30% reduction in infrastructure costs
- **Team Autonomy**: Independent service teams

## 🎯 Conclusion

This microservices architecture design provides:

1. **Scalability**: Independent scaling of services based on demand
2. **Resilience**: Fault isolation and graceful degradation
3. **Development Velocity**: Independent team development and deployment
4. **Technology Diversity**: Freedom to choose optimal technology per service
5. **Maintainability**: Clear service boundaries and responsibilities

The migration strategy ensures minimal disruption while providing immediate benefits and a clear path to full microservices architecture.

---

**Next Steps**:
1. Review and approve architecture design
2. Set up development environment
3. Implement API Gateway and Auth Service
4. Begin Customer Service migration
5. Establish monitoring and deployment pipelines