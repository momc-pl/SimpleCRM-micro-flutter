# Simple CRM Microservices API Specifications

## 🌐 API Gateway Configuration

### Base URL Structure
```
Production: https://api.simplecrm.com
Development: http://localhost:8080
```

### Global Headers
```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
X-Request-ID: <UUID>
X-Client-Version: 1.0.0
```

### Standard Response Format
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation successful",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req-abc123"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "invalid-email"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req-abc123"
}
```

---

## 🔐 Auth Service API (Port 8081)

### Authentication Endpoints

#### POST /auth/login
**Description**: Authenticate user with Google OAuth2
```http
POST /auth/login
Content-Type: application/json

{
  "googleToken": "google_oauth_token_here"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "accessToken": "jwt_token_here",
    "refreshToken": "refresh_token_here",
    "expiresIn": 3600,
    "user": {
      "id": 123,
      "email": "john@example.com",
      "name": "John Doe",
      "roles": ["user"]
    }
  }
}
```

#### POST /auth/refresh
**Description**: Refresh JWT token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "refresh_token_here"
}
```

#### GET /auth/profile
**Description**: Get current user profile
```http
GET /auth/profile
Authorization: Bearer <token>
```

#### POST /auth/logout
**Description**: Invalidate user session
```http
POST /auth/logout
Authorization: Bearer <token>
```

#### GET /auth/validate
**Description**: Validate JWT token (internal service call)
```http
GET /auth/validate?token=jwt_token_here
```

---

## 👥 Customer Service API (Port 8082)

### Customer Management

#### GET /customers
**Description**: List customers with pagination and filtering
```http
GET /customers?page=0&size=20&sort=name,asc&status=ACTIVE&search=john
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "company": "Acme Corp",
        "customerType": "BUSINESS",
        "status": "ACTIVE",
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pageable": {
      "page": 0,
      "size": 20,
      "totalElements": 150,
      "totalPages": 8
    }
  }
}
```

#### POST /customers
**Description**: Create new customer
```http
POST /customers
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "+1987654321",
  "company": "Tech Solutions Inc",
  "customerType": "BUSINESS",
  "notes": "Potential large client"
}
```

#### GET /customers/{id}
**Description**: Get customer details
```http
GET /customers/123
Authorization: Bearer <token>
```

#### PUT /customers/{id}
**Description**: Update customer
```http
PUT /customers/123
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Jane Smith Updated",
  "phone": "+1987654322",
  "notes": "Updated notes"
}
```

#### DELETE /customers/{id}
**Description**: Soft delete customer
```http
DELETE /customers/123
Authorization: Bearer <token>
```

### Address Management

#### GET /customers/{id}/addresses
**Description**: Get customer addresses
```http
GET /customers/123/addresses
Authorization: Bearer <token>
```

#### POST /customers/{id}/addresses
**Description**: Add customer address
```http
POST /customers/123/addresses
Authorization: Bearer <token>
Content-Type: application/json

{
  "type": "BILLING",
  "street": "123 Main St",
  "city": "Anytown",
  "state": "CA",
  "zipCode": "12345",
  "country": "USA"
}
```

---

## 📦 Product Service API (Port 8083)

### Product Catalog

#### GET /products
**Description**: List products with pagination and filtering
```http
GET /products?page=0&size=20&category=electronics&minPrice=10&maxPrice=100
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "name": "Laptop Computer",
        "description": "High-performance laptop",
        "sku": "LAP-001",
        "category": "Electronics",
        "priceNet": 999.99,
        "vatRate": 20.0,
        "priceGross": 1199.99,
        "status": "ACTIVE",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pageable": {
      "page": 0,
      "size": 20,
      "totalElements": 500,
      "totalPages": 25
    }
  }
}
```

#### POST /products
**Description**: Create new product
```http
POST /products
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Wireless Mouse",
  "description": "Ergonomic wireless mouse",
  "sku": "MOUSE-001",
  "category": "Electronics",
  "priceNet": 29.99,
  "vatRate": 20.0
}
```

#### GET /products/{id}
**Description**: Get product details
```http
GET /products/123
Authorization: Bearer <token>
```

#### PUT /products/{id}
**Description**: Update product
```http
PUT /products/123
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Product Name",
  "priceNet": 34.99
}
```

#### GET /products/search
**Description**: Search products
```http
GET /products/search?q=laptop&category=electronics
Authorization: Bearer <token>
```

---

## 🛒 Order Service API (Port 8084)

### Order Management

#### GET /orders
**Description**: List orders with filtering
```http
GET /orders?page=0&size=20&status=PENDING&customerId=123&dateFrom=2024-01-01
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "orderNumber": "ORD-20240115-001",
        "customerId": 123,
        "customerName": "John Doe",
        "status": "PENDING",
        "totalNet": 999.99,
        "totalVat": 200.00,
        "totalGross": 1199.99,
        "createdAt": "2024-01-15T10:30:00Z",
        "orderLines": [
          {
            "id": 1,
            "productId": 456,
            "productName": "Laptop Computer",
            "quantity": 1,
            "unitPriceNet": 999.99,
            "lineVat": 200.00,
            "lineTotalGross": 1199.99
          }
        ]
      }
    ]
  }
}
```

#### POST /orders
**Description**: Create new order
```http
POST /orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "customerId": 123,
  "orderLines": [
    {
      "productId": 456,
      "quantity": 2
    },
    {
      "productId": 789,
      "quantity": 1
    }
  ],
  "notes": "Rush order"
}
```

#### GET /orders/{id}
**Description**: Get order details
```http
GET /orders/123
Authorization: Bearer <token>
```

#### PUT /orders/{id}/status
**Description**: Update order status
```http
PUT /orders/123/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "CONFIRMED",
  "notes": "Order confirmed by customer"
}
```

#### GET /orders/customer/{customerId}
**Description**: Get customer orders
```http
GET /orders/customer/123?status=COMPLETED
Authorization: Bearer <token>
```

---

## 📊 Inventory Service API (Port 8085)

### Stock Management

#### GET /inventory/products/{productId}
**Description**: Get stock level for product
```http
GET /inventory/products/123
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "productId": 123,
    "availableStock": 50,
    "reservedStock": 5,
    "totalStock": 55,
    "reorderLevel": 10,
    "lastUpdated": "2024-01-15T10:30:00Z"
  }
}
```

#### POST /inventory/reserve
**Description**: Reserve stock for order
```http
POST /inventory/reserve
Authorization: Bearer <token>
Content-Type: application/json

{
  "orderId": 789,
  "items": [
    {
      "productId": 123,
      "quantity": 2
    }
  ]
}
```

#### POST /inventory/release
**Description**: Release reserved stock
```http
POST /inventory/release
Authorization: Bearer <token>
Content-Type: application/json

{
  "orderId": 789
}
```

#### PUT /inventory/adjust
**Description**: Adjust stock levels
```http
PUT /inventory/adjust
Authorization: Bearer <token>
Content-Type: application/json

{
  "productId": 123,
  "adjustment": -5,
  "reason": "DAMAGED",
  "notes": "Water damage during storage"
}
```

#### GET /inventory/alerts
**Description**: Get low stock alerts
```http
GET /inventory/alerts?severity=HIGH
Authorization: Bearer <token>
```

---

## 🎯 Sales Pipeline Service API (Port 8086)

### Lead Management

#### GET /leads
**Description**: List leads with filtering
```http
GET /leads?page=0&size=20&status=NEW&source=WEBSITE
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "name": "Potential Customer",
        "email": "lead@example.com",
        "phone": "+1234567890",
        "company": "Future Client Corp",
        "source": "WEBSITE",
        "status": "NEW",
        "score": 75,
        "assignedTo": "sales-rep-123",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

#### POST /leads
**Description**: Create new lead
```http
POST /leads
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "John Prospect",
  "email": "john@prospect.com",
  "phone": "+1987654321",
  "company": "Prospect Industries",
  "source": "REFERRAL",
  "notes": "Interested in premium package"
}
```

#### PUT /leads/{id}/convert
**Description**: Convert lead to customer
```http
PUT /leads/123/convert
Authorization: Bearer <token>
Content-Type: application/json

{
  "customerData": {
    "customerType": "BUSINESS",
    "notes": "Converted from lead"
  }
}
```

### Opportunity Management

#### GET /opportunities
**Description**: List opportunities
```http
GET /opportunities?stage=PROPOSAL&assignedTo=sales-rep-123
Authorization: Bearer <token>
```

#### POST /opportunities
**Description**: Create new opportunity
```http
POST /opportunities
Authorization: Bearer <token>
Content-Type: application/json

{
  "customerId": 123,
  "name": "Q1 Software License Deal",
  "value": 50000.00,
  "stage": "QUALIFICATION",
  "probability": 25,
  "expectedCloseDate": "2024-03-31"
}
```

#### PUT /opportunities/{id}/stage
**Description**: Update opportunity stage
```http
PUT /opportunities/123/stage
Authorization: Bearer <token>
Content-Type: application/json

{
  "stage": "PROPOSAL",
  "probability": 60,
  "notes": "Proposal submitted"
}
```

---

## 📧 Notification Service API (Port 8087)

### Notification Management

#### POST /notifications/email
**Description**: Send email notification
```http
POST /notifications/email
Authorization: Bearer <token>
Content-Type: application/json

{
  "to": ["customer@example.com"],
  "cc": ["manager@company.com"],
  "subject": "Order Confirmation",
  "template": "order-confirmation",
  "variables": {
    "customerName": "John Doe",
    "orderNumber": "ORD-123",
    "total": "$1,199.99"
  },
  "priority": "HIGH"
}
```

#### POST /notifications/sms
**Description**: Send SMS notification
```http
POST /notifications/sms
Authorization: Bearer <token>
Content-Type: application/json

{
  "to": "+1234567890",
  "message": "Your order ORD-123 has been confirmed. Thank you!",
  "priority": "HIGH"
}
```

#### GET /notifications/user/{userId}
**Description**: Get user notifications
```http
GET /notifications/user/123?read=false&limit=20
Authorization: Bearer <token>
```

#### PUT /notifications/{id}/read
**Description**: Mark notification as read
```http
PUT /notifications/456/read
Authorization: Bearer <token>
```

---

## 🔄 Event Schema Definitions

### CustomerCreated Event
```json
{
  "eventType": "CustomerCreated",
  "eventId": "evt-abc123",
  "timestamp": "2024-01-15T10:30:00Z",
  "source": "customer-service",
  "data": {
    "customerId": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "customerType": "BUSINESS"
  }
}
```

### OrderPlaced Event
```json
{
  "eventType": "OrderPlaced",
  "eventId": "evt-def456",
  "timestamp": "2024-01-15T10:30:00Z",
  "source": "order-service",
  "data": {
    "orderId": 789,
    "orderNumber": "ORD-20240115-001",
    "customerId": 123,
    "totalGross": 1199.99,
    "items": [
      {
        "productId": 456,
        "quantity": 1
      }
    ]
  }
}
```

### InventoryLow Event
```json
{
  "eventType": "InventoryLow",
  "eventId": "evt-ghi789",
  "timestamp": "2024-01-15T10:30:00Z",
  "source": "inventory-service",
  "data": {
    "productId": 123,
    "currentStock": 5,
    "reorderLevel": 10,
    "severity": "HIGH"
  }
}
```

---

## 📊 Health Check Endpoints

All services expose standard health check endpoints:

#### GET /actuator/health
**Description**: Service health status
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "redis": {
      "status": "UP"
    }
  }
}
```

#### GET /actuator/info
**Description**: Service information
```json
{
  "build": {
    "version": "1.0.0",
    "timestamp": "2024-01-15T10:00:00Z"
  },
  "git": {
    "commit": "abc123",
    "branch": "main"
  }
}
```

#### GET /actuator/metrics
**Description**: Prometheus metrics endpoint

---

## 🔐 Security Considerations

### Rate Limiting
- **Per User**: 1000 requests per hour
- **Per Service**: 10000 requests per hour
- **Authentication**: 10 attempts per minute

### Input Validation
- All string inputs sanitized
- SQL injection prevention
- XSS protection
- File upload restrictions

### Data Privacy
- PII data encryption
- Audit logging for data access
- GDPR compliance features
- Data retention policies

---

## 🧪 Testing Strategy

### API Testing
- **Unit Tests**: Individual endpoint testing
- **Integration Tests**: Service-to-service communication
- **Contract Tests**: API contract validation
- **Load Tests**: Performance under stress

### Test Data
- Mock data for development
- Sanitized production data for staging
- Synthetic data generation for testing

### Monitoring
- API response time monitoring
- Error rate tracking
- Business metric dashboards
- Real-time alerting

This comprehensive API specification provides the foundation for implementing the microservices architecture with clear contracts, consistent patterns, and robust error handling.