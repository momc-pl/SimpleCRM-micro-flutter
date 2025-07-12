# SimpleCRM - Microservices + Flutter CRM System

A modern Customer Relationship Management system built with **microservices architecture** and **Flutter frontend**, featuring JWT authentication, PostgreSQL databases, and Docker containerization.

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   API Gateway   │
│  (Cross-Platform)│◄──►│   (Port 8090)   │
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
                    │     PostgreSQL DBs      │
                    │   (Service-specific)    │
                    └─────────────────────────┘
```

## ✨ **Features**

### **Backend Microservices**
- **🔐 Auth Service**: JWT authentication and user management
- **👥 Customer Service**: Customer CRUD and relationship management  
- **📦 Product Service**: Product catalog with inventory tracking
- **🛒 Order Service**: Order lifecycle and payment management
- **🎯 Sales Pipeline**: Lead and opportunity tracking *(pending)*
- **🌐 API Gateway**: Single entry point with routing and security

### **Frontend**
- **📱 Flutter App**: Cross-platform (iOS, Android, Web, Desktop)
- **🔄 State Management**: Riverpod with reactive patterns
- **🔒 Secure Storage**: JWT token management
- **🌐 API Integration**: Retrofit REST client with error handling

### **Infrastructure**
- **🐳 Containerized**: Docker Compose orchestration
- **🗄️ Multi-Database**: Service-specific PostgreSQL instances
- **☁️ Cloud Ready**: Azure/AWS deployment support
- **📊 Monitoring**: Health checks and metrics

## 🚀 **Technology Stack**

### **Backend**
- **Framework**: Spring Boot 3.1+ with Java 17
- **Database**: PostgreSQL (service-specific instances)
- **Security**: JWT authentication with Spring Security
- **Communication**: REST APIs with OpenFeign client
- **Build**: Maven with multi-module structure
- **Containerization**: Docker with optimized images

### **Frontend**
- **Framework**: Flutter 3.10+ with Dart
- **State Management**: Riverpod 2.4+
- **HTTP Client**: Dio with Retrofit code generation
- **Authentication**: JWT with Flutter Secure Storage
- **Routing**: Go Router with guards
- **Dependency Injection**: GetIt service locator

## 🏃‍♂️ **Quick Start**

### **Prerequisites**
- **Docker & Docker Compose**
- **Flutter SDK 3.10+** (for frontend development)
- **Java 17+** (for backend development)
- **PostgreSQL** (or use Docker)

### **1. Start Microservices**
```bash
cd microservices
docker-compose up -d
```

### **2. Verify Services**
```bash
# Check all services are running
curl http://localhost:8090/actuator/health

# Test individual services
curl http://localhost:8080/actuator/health  # Auth Service
curl http://localhost:8081/actuator/health  # Customer Service  
curl http://localhost:8082/actuator/health  # Product Service
curl http://localhost:8083/actuator/health  # Order Service
```

### **3. Start Flutter App**
```bash
# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run on desired platform
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run                  # iOS Simulator (default)
```

### **4. Access Application**
- **API Gateway**: http://localhost:8090
- **Flutter Web**: http://localhost:3000 (or auto-assigned)
- **API Documentation**: http://localhost:8090/swagger-ui.html

## 🏗️ **Development Setup**

### **Backend Development**
```bash
# Start individual service for development
cd microservices/customer-service
./mvnw spring-boot:run

# Run tests
./mvnw test

# Build Docker image
docker build -t customer-service .
```

### **Frontend Development**
```bash
# Install Flutter if not present
# Follow: https://docs.flutter.dev/get-started/install

# Setup IDE integration
flutter doctor

# Hot reload development
flutter run --hot
```

## 📊 **Service Status**

| Service | Status | API Port | Features |
|---------|--------|----------|----------|
| **🔐 Auth Service** | ✅ Complete | 8080 | JWT, User Management |
| **👥 Customer Service** | ✅ Complete | 8081 | CRUD, Search, Multi-tenant |
| **📦 Product Service** | ✅ Complete | 8082 | Catalog, Inventory, Categories |
| **🛒 Order Service** | ✅ Complete | 8083 | Lifecycle, Payments, Items |
| **🎯 Sales Pipeline** | ⏳ Pending | 8084 | Leads, Opportunities |
| **🌐 API Gateway** | ✅ Complete | 8090 | Routing, Auth, Rate Limiting |

## 🗂️ **Project Structure**

```
SimpleCRM-micro-flutter/
├── microservices/              # Backend services
│   ├── api-gateway/           # Central routing
│   ├── auth-service/          # Authentication
│   ├── customer-service/      # Customer management
│   ├── product-service/       # Product catalog
│   ├── order-service/         # Order processing
│   ├── sales-pipeline-service/ # CRM pipeline (pending)
│   ├── shared-lib/            # Common utilities
│   └── docker-compose.yml     # Orchestration
├── lib/                       # Flutter application
│   ├── core/                  # Core utilities
│   ├── modules/               # Feature modules
│   │   ├── auth/             # Authentication
│   │   ├── customers/        # Customer management
│   │   ├── products/         # Product catalog
│   │   └── orders/           # Order management
│   └── shared/               # Shared components
├── PROJECT_STATUS.md          # Development progress
├── .archive/                  # Archived monolith files
└── README.md                  # This file
```

## 🔧 **Configuration**

### **Environment Variables**
Create `.env` files in each service directory:

```bash
# Database configuration
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/customer_db
SPRING_DATASOURCE_USERNAME=customer_user
SPRING_DATASOURCE_PASSWORD=customer_pass

# JWT configuration  
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRATION=86400000

# Service discovery
EUREKA_SERVER_URL=http://localhost:8761/eureka
```

### **Flutter Configuration**
```yaml
# pubspec.yaml - main dependencies
dependencies:
  flutter_riverpod: ^2.4.9
  dio: ^5.4.0
  go_router: ^12.1.3
  flutter_secure_storage: ^9.0.0
  get_it: ^7.6.4
```

## 🧪 **Testing**

### **Backend Testing**
```bash
# Run all service tests
cd microservices
./build-all.sh test

# Integration tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

### **Frontend Testing**
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

## 📈 **API Documentation**

Each service provides Swagger documentation:
- **API Gateway**: http://localhost:8090/swagger-ui.html
- **Auth Service**: http://localhost:8080/swagger-ui.html
- **Customer Service**: http://localhost:8081/swagger-ui.html
- **Product Service**: http://localhost:8082/swagger-ui.html
- **Order Service**: http://localhost:8083/swagger-ui.html

## 🚀 **Deployment**

### **Docker Deployment**
```bash
# Build all services
cd microservices
./build-all.sh

# Deploy stack
docker-compose up -d
```

### **Cloud Deployment**
- **Azure**: Container Instances + PostgreSQL Flexible Server
- **AWS**: ECS + RDS PostgreSQL
- **GCP**: Cloud Run + Cloud SQL

## 🔍 **Monitoring & Health**

### **Health Checks**
- **Aggregate**: http://localhost:8090/actuator/health
- **Individual Services**: http://localhost:808X/actuator/health

### **Metrics**
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001

## 🤝 **Contributing**

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Follow microservices patterns**: Use existing service structure
4. **Add tests**: Both unit and integration tests
5. **Update documentation**: README and service-specific docs
6. **Submit PR**: With detailed description

## 📋 **Development Roadmap**

### **Current Sprint** *(80% Complete)*
- ✅ Core microservices (Auth, Customer, Product, Order)
- ✅ Flutter architecture and authentication
- ⏳ Sales Pipeline Service implementation
- ⏳ End-to-end integration testing

### **Next Sprint**
- 🎯 Sales Pipeline Service completion
- 📱 Flutter UI/UX enhancements  
- 🔄 Real-time notifications
- 📊 Analytics dashboard

### **Future Features**
- 🤖 AI-powered lead scoring
- 📧 Email marketing integration
- 📱 Mobile offline mode
- 🔗 Third-party CRM integrations

## 📞 **Support & Documentation**

- **Architecture Details**: `/microservices/README.md`
- **API Documentation**: Swagger UI for each service
- **Development Guide**: Individual service READMEs
- **Deployment Guide**: `/microservices/docker-compose.yml`
- **Project Status**: `/PROJECT_STATUS.md`

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**SimpleCRM**: Modern microservices CRM with Flutter frontend
*Built for scalability, maintainability, and cross-platform excellence*