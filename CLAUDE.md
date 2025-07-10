## 🔰 Master Prompt – Full Context Overview for AI Agents

You are an AI Engineering Agent collaborating on a demo project that showcases the development of a complete Java Spring Boot web application with local database and Google-based authentication. This project will be executed in stages, and each stage is defined in a separate detailed prompt.

The purpose of this exercise is to demonstrate the capabilities of AI agents (e.g., via Gemini CLI) to generate a complete application architecture, codebase, environment setup, and test suite—starting from scratch and using only natural language input.

### 🔍 Context of the Application

This is a business-oriented order management system with the following domain entities:

- **Customers** (with contact and address details)
- **Addresses** (linked to customers)
- **Products** (with net price and VAT rate)
- **Orders** (linked to customers and containing multiple lines)
- **OrderLines** (each representing a product and quantity in the order)
- **Users** (authenticated via Google OAuth, stored in DB for reuse)

### 💡 Application Features

- Google Sign-in integration via OAuth2
- Main dashboard with list of customers and products
- Ability to create new orders by selecting a product or customer (or none)
- Master-detail order creation screen with VAT and gross/net calculations
- Views for:
  - Customer details with related orders
  - Product details with related orders
  - Full navigation between orders, customers, and products
- Clear separation using Spring MVC: Controllers, Services, Repositories, DTOs, Entities

### 🧪 Testing

A complete test suite should be provided:
- Unit tests for business logic
- Integration tests for service/database interaction
- UI tests (if using Thymeleaf)
- Security/OAuth tests
- Coverage reports

---

### 📂 The following prompts contain detailed instructions for each phase:

1. `1_env_setup.md` – Development environment setup on macOS with PostgreSQL
2. `2_db_schema_and_data.md` – Database schema definition and demo data generation
3. `3_springboot_app.md` – Building the Spring Boot application (MVC with Google Login)
4. `4_tests.md` – Writing automated tests for all core functionalities

Each prompt is self-contained but refers to the shared application context defined here.

Your goal as an agent is to execute each step autonomously or with minimal guidance, and to ensure that the output is executable, complete, and ready for human verification and iteration.