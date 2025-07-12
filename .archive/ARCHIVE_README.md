# Archive Directory

This directory contains files from the original **Spring Boot MVC monolith** implementation that are no longer relevant for the current **microservices + Flutter** architecture.

## Archived Files

### **Documentation Files**
- `1_env_setup.md` - Environment setup for monolith
- `2_db_schema_and_data.md` - Original database schema design
- `3_springboot_app.md` - Spring Boot MVC application guide
- `4_tests.md` - Testing instructions for monolith
- `PRESERVE.md` - Original project information
- `monolith-HANDOVER.md` - Azure deployment for monolith

### **Source Code**
- `monolith-src/` - Complete Java source code for Spring Boot MVC app
  - Controllers, Services, Repositories
  - Entities and DTOs
  - Thymeleaf templates
  - Security configuration

### **Configuration Files**
- `monolith-pom.xml` - Maven configuration for monolith
- `monolith-Dockerfile` - Container configuration for monolith
- `Dockerfile.test` - Test container configuration
- `mvnw` / `mvnw.cmd` - Maven wrapper scripts
- `.mvn/` - Maven wrapper configuration

## Why These Were Archived

The project evolved from a **monolithic Spring Boot MVC application** to a modern **microservices architecture with Flutter frontend**:

### **Old Architecture (Archived)**
- Single Spring Boot application
- Thymeleaf templates for frontend
- Single PostgreSQL database
- Monolithic deployment

### **New Architecture (Current)**
- Multiple Spring Boot microservices
- Flutter cross-platform frontend
- Service-specific PostgreSQL databases
- Containerized microservices deployment

## Project Evolution Timeline

1. **Phase 1**: Spring Boot MVC monolith *(archived)*
2. **Phase 2**: Microservices research and design
3. **Phase 3**: Individual service implementation *(current)*
4. **Phase 4**: Flutter frontend integration *(in progress)*
5. **Phase 5**: Full system deployment *(planned)*

## Accessing Archived Code

If you need to reference the original implementation:
- Browse `monolith-src/` for complete Java source code
- Check `monolith-pom.xml` for original dependencies
- Review documentation files for setup instructions

The archived code represents a fully functional CRM system and can serve as reference for business logic patterns that were migrated to the microservices architecture.

---
*Archived on: Session 4 - During microservices completion*
*Reason: Migration to microservices + Flutter architecture*