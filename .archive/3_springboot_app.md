## ✅ Prompt 3: Java Spring Boot MVC Application

**Task:** Build the application in Spring Boot using MVC pattern with Google Sign-In.

```prompt
You are a Spring Boot Fullstack AI Agent. Your task is to build a Java Spring Boot web application using MVC architecture, implementing the following features:

General:
- Use Spring Boot 3.x with Maven
- Use Spring Web, Spring Data JPA, Spring Security (with OAuth2), PostgreSQL driver

Functionality:
1. Google OAuth2 login (Spring Security + OAuth2 Client)
   - On login, store the user in the `User` table (google_id, email, name)
2. Main dashboard view:
   - List all customers and products with search bar
   - Allow starting new order: from product, from customer, or blank
3. Order view (master-detail):
   - Auto-generate order number
   - Search and select customer
   - Add order lines: select product, set quantity, calculate net, VAT, gross per line
   - Display totals for the entire order
4. Navigation and views:
   - Customer detail view with list of orders
   - Product detail view with list of related orders
   - Order view with drill-down to products and customers
   - Navigation between entities

Structure:
- Clear separation: Controller, Service, Repository, DTOs, Entities
- Use Thymeleaf or REST+React (pick one and explain)
```

### ✨ Enhancements and Refinements Implemented:

Beyond the initial specifications, the following improvements have been integrated into the application:

1.  **Custom Login Page:** A dedicated login page with a "Login with Google" button has been implemented, replacing the default Spring Security login form.

2.  **Enhanced Security Configuration:**
    *   All application pages (dashboard, orders, customers, products) are now secured and require successful user authentication.
    *   Only the `/login` and `/error` endpoints are publicly accessible without authentication.
    *   Proper logout management has been configured, including CSRF protection for logout requests, ensuring a clean and secure logout process.

3.  **Interactive Order Form:**
    *   The order creation screen now features real-time, interactive calculations.
    *   As products and quantities are selected for individual order lines, their respective net, VAT, and gross totals are immediately calculated and displayed.
    *   The overall order header (Total Net, Total VAT, Total Gross) dynamically updates to reflect changes in the order lines.
    *   Users can dynamically add new order lines to the form using JavaScript, enhancing usability.

4.  **Modern UI with Bootstrap:**
    *   The application's user interface has been significantly improved by integrating Bootstrap 5 via CDN.
    *   Bootstrap classes have been applied extensively to tables (`table table-striped table-hover`), forms (`form-label`, `form-control`, `form-select`, `btn`, `btn-primary`, `btn-secondary`), and navigation elements (`navbar`, `navbar-expand-lg`, `navbar-light`, `bg-light`, `mb-4`, `navbar-brand`, `nav-item`, `nav-link`).
    *   Font Awesome has been included for modern iconography.
    *   **Bootstrap JavaScript Bundle:** Added Bootstrap JavaScript bundle to enable interactive components like modals and dropdowns.

5.  **Development Environment Improvements:**
    *   The `spring-boot-devtools` dependency has been added to enable hot-reloading, significantly speeding up the development feedback loop for code and template changes.

6.  **Custom Error Page:** A user-friendly custom error page has been implemented to handle unexpected application errors gracefully, replacing Spring Boot's default Whitelabel Error Page.

7.  **User Information Display:** The authenticated user's name is now displayed prominently in the navigation bar across all application screens, providing a personalized user experience. This was achieved by:
    *   Retrieving the `Authentication` object from `SecurityContextHolder` in each relevant controller.
    *   Extracting the user's name from the `Principal` (handling both `OAuth2User` and `UserDetails` types) and adding it as a `userName` attribute to the `Model`.
    *   Updating the `fragments/nav.html` to display this `userName` attribute.

8.  **User-Specific Order Listing:** Implemented a dedicated "My Orders" screen, accessible from the navigation bar, which displays only the orders created by the currently logged-in user.

9.  **User Management and Order History:** Added a "Users" screen, also accessible from the navigation bar, listing all registered users. Clicking on a user navigates to a detailed view showing all orders associated with that specific user.

10. **Product Search Modal:** Replaced the dropdown product selection in order forms with a searchable modal popup:
    *   **Search Functionality:** Users can search for products by name using a text input field.
    *   **REST API Endpoint:** Added `/api/products/search` endpoint that returns JSON results for product searches.
    *   **Modal Interface:** Products are displayed in a table format within a Bootstrap modal, making selection more user-friendly.
    *   **JavaScript Integration:** Product selection updates the order line form fields and closes the modal automatically.

11. **Enhanced Entity Relationships:**
    *   **Fixed OrderLine Entity:** Resolved JPA column mapping conflicts by properly configuring the `@ManyToOne` relationship between OrderLine and Product entities.
    *   **User-Order Association:** Every order is now properly linked to the user who created it, enabling user-specific order filtering and "Created by" information.
    *   **Lazy Loading Optimization:** Added explicit lazy loading handling to prevent Hibernate session issues when accessing related entities.

12. **Order Detail Enhancements:**
    *   **Created By Information:** Order detail pages now display "Created by" information with a clickable link to the user's order history.
    *   **Template Error Handling:** Fixed template rendering issues by properly calculating missing fields (e.g., `lineTotalNet` calculated as `lineTotalGross - lineVat`).
    *   **Comprehensive Order Information:** Order details show complete information including customer details, order lines with product information, and financial totals.

13. **Debugging and Error Handling:**
    *   **Enhanced Logging:** Added comprehensive debugging logs throughout the application to track order creation, user authentication, and entity relationships.
    *   **Template Error Prevention:** Implemented defensive programming in controllers to prevent template rendering errors when entities are not found.
    *   **User Creation Handling:** Added proper handling for OAuth2 user creation to ensure users are properly stored in the database upon first login.

14. **Database Integrity:**
    *   **Manual User Creation:** Implemented database queries to manually create missing OAuth2 users when automatic creation fails.
    *   **Relationship Consistency:** Ensured all orders are properly linked to their creating users through database relationship validation.

### 🔧 Technical Improvements:

1. **Frontend JavaScript Enhancements:**
   - Fixed product selection logic using DOM traversal (`closest('tr')` and `Array.from().indexOf()`) for reliable row index calculation.
   - Added Bootstrap modal functionality for product search and selection.
   - Implemented dynamic form updates and real-time calculations.

2. **Backend Service Layer:**
   - Enhanced `OrderService` with comprehensive debugging and lazy loading handling.
   - Added proper error handling and null checks throughout service methods.
   - Implemented user lookup and order filtering based on authenticated user context.

3. **Template Engine Optimizations:**
   - Fixed Thymeleaf template syntax issues and added proper error handling.
   - Implemented calculated fields in templates to handle missing entity properties.
   - Added proper null safety checks in template expressions.

4. **Database Query Optimization:**
   - Added efficient product search queries with case-insensitive matching.
   - Implemented proper JPA relationships to avoid N+1 query problems.
   - Added database constraints and foreign key relationships for data integrity.

### 🏗️ Current Application Architecture:

**Technology Stack:**
- **Framework:** Spring Boot 3.1.0 with Java 17
- **Database:** PostgreSQL with JPA/Hibernate
- **Security:** Spring Security with OAuth2 Google authentication
- **Template Engine:** Thymeleaf
- **Frontend:** Bootstrap 5.3.2 with JavaScript
- **Build Tool:** Maven

**Core Entities:**
1. **User Entity:** Manages OAuth2 users with Google ID, name, and email
2. **Customer Entity:** Business customers with company information
3. **Product Entity:** Product catalog with pricing and VAT information
4. **Order Entity:** Order headers with customer and user associations
5. **OrderLine Entity:** Order line items with product, quantity, and pricing details

**Key Features Currently Working:**
- ✅ Google OAuth2 authentication and user management
- ✅ Product search modal with real-time filtering
- ✅ Interactive order creation with dynamic calculations
- ✅ Order detail views with "Created by" information and user links
- ✅ User-specific order filtering ("My Orders")
- ✅ User management with order history views
- ✅ Bootstrap-based responsive UI
- ✅ Comprehensive error handling and debugging

**API Endpoints:**
- `/api/products/search` - Product search with query parameter
- `/orders/my-orders` - User-specific order listing
- `/users/{id}/orders` - User order history
- `/orders/{id}` - Order detail view
- Standard CRUD operations for all entities

**Security Configuration:**
- All endpoints require authentication except `/login` and `/error`
- OAuth2 integration with Google Identity Provider
- CSRF protection enabled
- Session-based authentication with proper logout handling

**Known Issues Resolved:**
- ✅ Fixed Bootstrap modal functionality
- ✅ Resolved JPA column mapping conflicts
- ✅ Fixed template rendering errors
- ✅ Corrected user-order relationship mapping
- ✅ Implemented proper lazy loading handling
- ✅ Fixed product selection JavaScript logic

15. **Customer and Product Editing Functionality:**
    *   **Customer Editing**: Full CRUD operations for customer information including name, email, and phone
    *   **Address Management**: Complete address management system with add, edit, and delete functionality via Bootstrap modals
    *   **Product Editing**: Product information editing with real-time gross price calculation
    *   **Enhanced Detail Pages**: Improved customer and product detail pages with edit buttons and better visual layout
    *   **Form Validation**: Proper form validation and error handling for all edit operations
    *   **Success Messages**: Flash messages to confirm successful operations

16. **Repository Layer Extensions:**
    *   **AddressRepository**: New repository for address CRUD operations
    *   **Enhanced Controllers**: Extended CustomerController and ProductController with full editing capabilities
    *   **Proper Entity Relationships**: Correct handling of customer-address relationships with cascade operations

17. **Template Security and Performance:**
    *   **Thymeleaf Security**: Fixed template security issues by using data attributes instead of string concatenation in event handlers
    *   **JavaScript Optimization**: Improved JavaScript functions for modal handling and form interactions
    *   **Responsive Design**: Enhanced Bootstrap layouts for better mobile and desktop experience

**Current State:**
The application is fully functional with comprehensive CRUD operations for all major entities. Users can:
- Authenticate via Google OAuth2
- Create and manage orders with searchable product selection
- Edit customer information and manage multiple addresses
- Edit product details with real-time price calculations
- View detailed information with proper navigation between entities
- Track order creation and user associations

The application demonstrates proper MVC architecture with clear separation of concerns, robust error handling, and modern responsive UI design. All major business operations are supported with proper validation and user feedback.