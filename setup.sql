-- Create a new database for the multi-tenant example
CREATE DATABASE multi_tenant_db;

-- Connect to the newly created database
\c multi_tenant_db

-- Create the 'app' role with login capability and a default tenant setting
CREATE ROLE app LOGIN PASSWORD 'p@ssw0rd' NOINHERIT;
ALTER ROLE app SET app.current_tenant TO '';

-- Create the assets table with necessary columns
CREATE TABLE assets (
                        id           UUID PRIMARY KEY,
                        tenant_id    UUID NOT NULL,
                        name         TEXT NOT NULL,
                        description  TEXT,
                        status       TEXT NOT NULL,
                        created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
                        updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
                        retired_at   TIMESTAMPTZ
);

-- Enable Row-Level Security (RLS) on the assets table
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

-- Create RLS policy for tenant isolation (limits visibility to current tenant)
CREATE POLICY assets_tenant_isolation ON assets
    USING (tenant_id = current_setting('app.current_tenant')::UUID);

-- Create RLS policy for insert operations (ensures tenant_id matches current tenant)
CREATE POLICY assets_tenant_insert ON assets
    FOR INSERT
    WITH CHECK (tenant_id = current_setting('app.current_tenant')::UUID);

-- Insert sample data for two tenants
INSERT INTO assets (id, tenant_id, name, description, status, retired_at)
VALUES
    ('f47ac10b-58cc-4372-a567-000000000001', '11111111-1111-1111-1111-111111111111', 'Forklift FL-100', '15-ton capacity', 'active', NULL),
    ('f47ac10b-58cc-4372-a567-000000000002', '11111111-1111-1111-1111-111111111111', 'Truck TR-200', 'GPS-enabled heavy-duty truck', 'active', NULL),
    ('f47ac10b-58cc-4372-a567-000000000003', '11111111-1111-1111-1111-111111111111', 'Container CT-300', 'Refrigerated shipping container', 'active', NULL),
    ('f47ac10b-58cc-4372-a567-000000000004', '11111111-1111-1111-1111-111111111111', 'Pallet Jack PJ-400', 'Manual pallet jack', 'retired', '2025-03-15T10:00:00Z'),
    ('f47ac10b-58cc-4372-a567-000000000005', '11111111-1111-1111-1111-111111111111', 'Drone DR-500', 'Aerial inventory drone', 'active', NULL),
    ('f47ac10b-58cc-4372-a567-000000000006', '11111111-1111-1111-1111-111111111111', 'AGV AG-600', 'Automated guided vehicle', 'retired', '2025-04-01T12:00:00Z'),
    ('f47ac10b-58cc-4372-a567-000000000007', '22222222-2222-2222-2222-222222222222', 'Delivery Van DV-110', 'Electric delivery van', 'active', NULL),
    ('f47ac10b-58cc-4372-a567-000000000008', '22222222-2222-2222-2222-222222222222', 'Pallet Jack PJ-210', 'Electric pallet jack', 'active', NULL);

-- Create a view to show only active assets, with security invoker enabled
CREATE VIEW active_assets AS
SELECT id, tenant_id, name, status
FROM assets
WHERE status = 'active';

ALTER VIEW active_assets SET (security_invoker = true);

-- Set up permissions for the 'app' role
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app;
GRANT SELECT, INSERT, UPDATE, DELETE ON assets TO app;
GRANT SELECT ON active_assets TO app;

-- Demonstration queries to show RLS in action
SET ROLE app;

-- Set tenant context to tenant 1 and query assets
SET app.current_tenant TO '11111111-1111-1111-1111-111111111111';
SELECT * FROM assets;

-- Set tenant context to tenant 2 and query assets
SET app.current_tenant TO '22222222-2222-2222-2222-222222222222';
SELECT * FROM assets;

-- Query the active_assets view (still under tenant 2 context)
SELECT * FROM active_assets;

-- Reset the role for further operations if needed
RESET ROLE;
