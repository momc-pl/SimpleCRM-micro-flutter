# SimpleCRM Microservices Architecture

## Overview

This directory contains the microservices implementation of SimpleCRM, featuring a modern, scalable architecture with Spring Boot services and a React/Flutter frontend.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   API Gateway   │
│  (Flutter/Web)  │◄──►│   (Port 8090)   │
└─────────────────┘    └─────────┬───────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
    ┌─────────▼───────┐ ┌────────▼────────┐ ┌──────▼──────┐
    │  Auth Service   │ │ Customer Service│ │Product Svc  │
    │   (Port 8080)   │ │  (Port 8081)    │ │(Port 8082)  │
    └─────────────────┘ └─────────────────┘ └─────────────┘
              │                  │                  │
              └──────────────────┼──────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     PostgreSQL DB       │
                    │     (Port 5432)         │
                    └─────────────────────────┘
```

## Services

### 1. API Gateway (Port 8090)
- **Technology**: Spring Cloud Gateway
- **Purpose**: Single entry point for all client requests
- **Features**:
  - Request routing to appropriate microservices
  - JWT authentication and authorization
  - Rate limiting and load balancing
  - CORS configuration
  - Circuit breaker pattern

### 2. Auth Service (Port 8080)
- **Technology**: Spring Boot + Spring Security + JWT
- **Purpose**: User authentication and authorization
- **Features**:
  - User registration and login
  - JWT token generation and validation
  - Role-based access control
  - Password management
  - Token refresh mechanism

### 3. Customer Service (Port 8081)
- **Technology**: Spring Boot + Spring Data JPA
- **Purpose**: Customer relationship management
- **Features**:
  - Customer CRUD operations
  - Customer search and filtering
  - Customer status management
  - Audit trail for customer changes

### 4. Product Service (Port 8082)
- **Technology**: Spring Boot + Spring Data JPA
- **Purpose**: Product catalog management
- **Features**:
  - Product CRUD operations
  - Category management
  - Inventory tracking
  - Product search and filtering

### 5. Order Service (Port 8083) *[Planned]*
- **Technology**: Spring Boot + Spring Data JPA
- **Purpose**: Order processing and management
- **Features**:
  - Order creation and management
  - Order status tracking
  - Integration with customer and product services

### 6. Sales Pipeline Service (Port 8084) *[Planned]*
- **Technology**: Spring Boot + Spring Data JPA
- **Purpose**: Sales process management
- **Features**:
  - Deal and opportunity tracking
  - Sales pipeline management
  - Lead qualification
  - Sales analytics

### 7. Shared Library
- **Purpose**: Common components and utilities
- **Features**:
  - Base entities with audit fields
  - Common DTOs and response models
  - Global exception handling
  - Utility classes

## Database Design

Each service has its own database following the database-per-service pattern:

- `auth_db`: User accounts, roles, and permissions
- `customer_db`: Customer information and relationships
- `product_db`: Product catalog and inventory
- `order_db`: Orders and order items *[Planned]*
- `sales_db`: Deals, opportunities, and pipeline data *[Planned]*

## Getting Started

### Prerequisites
- Java 11 or higher
- Maven 3.6+
- Docker and Docker Compose
- PostgreSQL (if running locally)

### Quick Start with Docker

1. **Build all services**:
   ```bash
   chmod +x build-all.sh
   ./build-all.sh --docker
   ```

2. **Start all services**:
   ```bash
   docker-compose up -d
   ```

3. **Check service health**:
   ```bash
   curl http://localhost:8090/actuator/health
   ```

### Manual Setup

1. **Build shared library**:
   ```bash
   cd shared-lib
   mvn clean install
   cd ..
   ```

2. **Build and run each service**:
   ```bash
   # Auth Service
   cd auth-service
   mvn spring-boot:run
   
   # Customer Service (in new terminal)
   cd customer-service
   mvn spring-boot:run
   
   # Product Service (in new terminal)
   cd product-service
   mvn spring-boot:run
   
   # API Gateway (in new terminal)
   cd api-gateway
   mvn spring-boot:run
   ```

## API Documentation

### Authentication Endpoints
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `GET /api/v1/auth/me` - Get current user info

### Customer Endpoints
- `GET /api/v1/customers` - List customers
- `POST /api/v1/customers` - Create customer
- `GET /api/v1/customers/{id}` - Get customer by ID
- `PUT /api/v1/customers/{id}` - Update customer
- `DELETE /api/v1/customers/{id}` - Delete customer

### Product Endpoints
- `GET /api/v1/products` - List products
- `POST /api/v1/products` - Create product
- `GET /api/v1/products/{id}` - Get product by ID
- `PUT /api/v1/products/{id}` - Update product
- `DELETE /api/v1/products/{id}` - Delete product

## Testing

### Run All Tests
```bash
./build-all.sh --test
```

### Run Tests for Specific Service
```bash
cd auth-service
mvn test
```

### Integration Testing
```bash
# Start services in test mode
docker-compose -f docker-compose.test.yml up -d

# Run integration tests
mvn verify -Pintegration-tests
```

## Configuration

### Environment Variables

Common environment variables for all services:

```bash
# Database Configuration
DB_URL=jdbc:postgresql://localhost:5432/database_name
DB_USERNAME=username
DB_PASSWORD=password

# JWT Configuration
JWT_SECRET=your-secret-key
JWT_EXPIRATION=86400

# Service URLs
AUTH_SERVICE_URL=http://localhost:8080/api/v1
CUSTOMER_SERVICE_URL=http://localhost:8081/api/v1
PRODUCT_SERVICE_URL=http://localhost:8082/api/v1
```

### Production Configuration

For production deployment, update the following:

1. **Security**: Use strong JWT secrets and database passwords
2. **Database**: Use managed database services (AWS RDS, etc.)
3. **Monitoring**: Add application monitoring (Prometheus, Grafana)
4. **Logging**: Configure centralized logging (ELK stack)
5. **Load Balancing**: Use external load balancers

## Monitoring and Health Checks

Each service exposes health check and metrics endpoints:

- Health: `GET /actuator/health`
- Metrics: `GET /actuator/metrics`
- Info: `GET /actuator/info`

## Development Guidelines

### Code Style
- Follow standard Java naming conventions
- Use meaningful variable and method names
- Add comprehensive JavaDoc for public APIs
- Implement proper exception handling

### Testing
- Write unit tests for all business logic
- Add integration tests for API endpoints
- Maintain minimum 80% code coverage
- Test both happy path and error scenarios

### Security
- Never commit secrets or credentials
- Use environment variables for configuration
- Implement proper input validation
- Follow OWASP security guidelines

## Troubleshooting

### Common Issues

1. **Service won't start**:
   - Check if required ports are available
   - Verify database connectivity
   - Check application logs

2. **Authentication errors**:
   - Verify JWT secret consistency across services
   - Check token expiration settings
   - Validate user permissions

3. **Database connection issues**:
   - Ensure PostgreSQL is running
   - Verify database credentials
   - Check network connectivity

### Useful Commands

```bash
# View service logs
docker-compose logs -f [service-name]

# Check service status
docker-compose ps

# Restart specific service
docker-compose restart [service-name]

# Clean up Docker resources
docker-compose down -v
docker system prune
```

## Contributing

1. Create feature branches from `main`
2. Follow the existing code style and patterns
3. Add tests for new functionality
4. Update documentation as needed
5. Submit pull requests for review

## License

This project is licensed under the MIT License - see the LICENSE file for details.