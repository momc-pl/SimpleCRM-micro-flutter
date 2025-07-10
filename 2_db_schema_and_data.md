## ✅ Prompt 2: Database Schema and Demo Data

**Task:** Define and initialize the relational database model for the app and populate it with demo data.

```prompt
You are a Database AI Agent. Your task is to design and initialize a PostgreSQL schema for a Spring Boot application managing orders.

Entities:
1. `Customer` – name, email, phone
2. `Address` – customer_id, street, city, zip, country
3. `Product` – name, price_net, vat_rate
4. `Order` – customer_id, user_id, created_at, total_net, total_vat, total_gross, order_number
5. `OrderLine` – order_id, product_id, quantity, unit_price_net, line_total_net, line_vat, line_total_gross
6. `User` – google_id, name, email, created_at

Requirements:
- Use foreign key constraints appropriately
- Define SQL DDL scripts for schema creation
- Create demo data (INSERT statements) for each table
- Generate an ERD (Entity Relationship Diagram) and export it as text or PlantUML
- Package everything as a ready-to-run SQL file (`init_db.sql`)
```

### ✨ Updates to Schema and Demo Data:

To support user-specific order tracking, the `Order` entity has been updated to include a `user_id` foreign key, linking orders to the `User` table. The `init_db.sql` script has been modified accordingly:

*   **DDL Change:** Added `user_id INTEGER REFERENCES users(id) ON DELETE SET NULL` to the `orders` table definition.
*   **DML Change:** Existing `INSERT` statements for the `orders` table now include a `user_id` value to associate demo orders with a specific user.
*   **ERD Update:** The PlantUML diagram within `init_db.sql` has been updated to reflect the new relationship between `users` and `orders`.
