## ✅ Prompt 1: Environment Setup (Light Local Version)

**Task:** Prepare a full development environment on macOS for building and running a Java Spring Boot web application with a local database.

```prompt
You are a DevOps AI Agent. Your task is to prepare a lightweight local development environment for a Java Spring Boot web application on macOS (Apple Silicon or Intel). 

Requirements:
1. Install and configure the following tools:
   - OpenJDK 17 (or 21 if stable and LTS)
   - Maven (preferred) or Gradle
   - IntelliJ IDEA (Community Edition)
   - Git
   - HTTP client (curl or httpie)
2. Install PostgreSQL database locally without Docker:
   - Create a user `appuser` with password `appsecret`
   - Create a database `appdb` owned by `appuser`
3. Enable PostgreSQL to autostart with macOS
4. Test database accessibility via CLI (e.g., `psql`)
5. Confirm environment setup by compiling a hello-world Spring Boot app
6. Generate a script (`setup_env.sh`) that automates the entire setup process.
```