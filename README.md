# PostgreSQL Multi-Tenancy with Row-Level Security (RLS)

This repository provides a complete SQL script to set up a multi-tenant database in PostgreSQL using **Row-Level Security (RLS)**. It demonstrates how RLS enforces tenant isolation at the database level, ensuring that each tenant can only access their own data. This approach is ideal for SaaS applications, as it centralizes security, reduces the risk of data leaks, and simplifies application code.
Read the [full article](http://ricofritzsche.me).

## Why Use Row-Level Security for Multi-Tenancy?

In multi-tenant applications, ensuring that tenants cannot access each other's data is critical. Traditionally, developers rely on application code to filter queries by `tenant_id`, but this is error-prone. A single mistake can expose sensitive data.

**Row-Level Security (RLS)** in PostgreSQL solves this by enforcing tenant isolation directly in the database. With RLS:

- Every query is automatically filtered to show only the current tenant's data.
- Developers can focus on business logic without worrying about tenant filters.
- The database acts as a secure-by-default layer, preventing cross-tenant data access.

This repository includes a ready-to-use script that sets up:
- A multi-tenant table (`assets`) with RLS policies.
- A custom role (`app`) for application access.
- A view (`active_assets`) that respects RLS.
- Sample data for two tenants to test isolation.

## Key Features

- **Centralized Tenant Isolation**: RLS policies ensure that all queries are automatically filtered by `tenant_id`.
- **Secure-by-Default**: Even if application code misses a filter, the database prevents data leaks.
- **Simple Setup**: Use a custom GUC variable (`app.current_tenant`) to set the tenant context per session or transaction.
- **Views and Procedures**: Demonstrates how to configure views to respect RLS using `security_invoker`.

## Setup Instructions

### Prerequisites

- PostgreSQL 15+ installed and running.
- Basic knowledge of SQL and PostgreSQL.

### Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ricofritzsche/multi-tenant-rls-demo.git
   cd multi-tenant-rls-demo
   ```

2. **Run the SQL Script**:
    - Open a terminal and connect to PostgreSQL as a superuser (e.g., `postgres`):
      ```bash
      psql -U postgres
      ```
    - Execute the script:
      ```sql
      \i setup.sql
      ```

3. **Verify the Setup**:
    - The script creates a database `multi_tenant_db`, sets up the `assets` table, inserts sample data, and configures RLS.
    - To test, connect to the database:
      ```bash
      psql -U postgres -d multi_tenant_db
      ```
    - Run the demonstration queries (see below).

## Usage Example

The script includes demonstration queries to show RLS in action:

1. **Set the Tenant Context**:
    - Switch to the `app` role and set the tenant context:
      ```sql
      SET ROLE app;
      SET app.current_tenant TO '11111111-1111-1111-1111-111111111111';
      ```

2. **Query Assets**:
    - Run a query to see only the current tenant's assets:
      ```sql
      SELECT * FROM assets;
      ```
    - Switch to another tenant and query again:
      ```sql
      SET app.current_tenant TO '22222222-2222-2222-2222-222222222222';
      SELECT * FROM assets;
      ```

3. **Query the View**:
    - The `active_assets` view respects RLS and shows only active assets for the current tenant:
      ```sql
      SELECT * FROM active_assets;
      ```

## Important Notes

- **Connection Pooling**: Use `SET LOCAL` within transactions to ensure the tenant context is reset after each request.
- **Performance**: Index the `tenant_id` column for optimal query performance.
- **Security**: Ensure the application role (`app`) does not have `BYPASSRLS` privileges.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.

## Feedback

If you have questions or suggestions, feel free to open an issue or submit a pull request. Your feedback is welcome!

Please visit [my blog](http://ricofritzsche.me).
---

*Keywords: PostgreSQL, Row-Level Security, Multi-Tenancy, SaaS, Database Security, Tenant Isolation*
