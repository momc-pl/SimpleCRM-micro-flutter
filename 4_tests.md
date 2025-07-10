## ✅ Prompt 4: Automated Testing

**Task:** Create automated test suite covering the core functionality.

```prompt
You are a Java QA AI Agent. Your task is to build a complete automated test suite for the Spring Boot web application.

Requirements:
1. Unit tests for:
   - Service layer (order creation, calculations)
   - VAT and gross price calculation logic
2. Integration tests:
   - REST API endpoints (if REST)
   - Controller logic and DB integration
3. Security tests:
   - Google OAuth login flow
   - Unauthorized access redirection
4. UI tests (if Thymeleaf):
   - Selenium or WebDriver-based smoke tests for key flows
5. Provide JUnit 5 test classes with mock data
6. Add Maven profile for test execution and code coverage report (Jacoco)

Deliver all tests in standard Maven structure and output coverage report.
```