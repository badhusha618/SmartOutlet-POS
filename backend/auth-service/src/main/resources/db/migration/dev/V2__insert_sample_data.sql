-- Sample data insertion for auth service
-- This file will be automatically executed by Spring Boot

-- Insert sample roles
INSERT INTO roles (name, description, created_at, updated_at) VALUES
('ADMIN', 'System Administrator with full access to all features', NOW(), NOW()),
('MANAGER', 'Outlet Manager with management privileges', NOW(), NOW()),
('CASHIER', 'Cashier with sales and inventory access', NOW(), NOW()),
('INVENTORY', 'Inventory manager with stock management access', NOW(), NOW()),
('ACCOUNTANT', 'Accountant with financial reporting access', NOW(), NOW()),
('SUPPORT', 'Customer support with limited access', NOW(), NOW()),
('STAFF', 'Default staff role for new users', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Insert sample users (password is BCrypt hash of 'password123')
INSERT INTO users (username, email, password, first_name, last_name, phone_number, is_active, is_verified, created_at, updated_at, last_login)
VALUES
('admin', 'admin@example.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoOa5gk5b8pQp1Yy1Q7rS3yY6z1Q7rS3y6', 'Admin', 'User', '1234567890', true, true, NOW(), NOW(), NOW())
ON CONFLICT (username) DO NOTHING;

-- Assign roles to admin user
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r WHERE u.username = 'admin' AND r.name = 'ADMIN' ON CONFLICT DO NOTHING;

-- Insert default permissions
INSERT INTO permissions (name, description, resource, action) VALUES
-- Users permissions
('USERS_READ', 'Read user information', 'USERS', 'READ'),
('USERS_WRITE', 'Create and update users', 'USERS', 'WRITE'),
('USERS_DELETE', 'Delete users', 'USERS', 'DELETE'),
('USERS_ADMIN', 'Administer users', 'USERS', 'ADMIN'),
-- Outlets permissions
('OUTLETS_READ', 'Read outlet information', 'OUTLETS', 'READ'),
('OUTLETS_WRITE', 'Create and update outlets', 'OUTLETS', 'WRITE'),
('OUTLETS_DELETE', 'Delete outlets', 'OUTLETS', 'DELETE'),
('OUTLETS_ADMIN', 'Administer outlets', 'OUTLETS', 'ADMIN'),
-- Products permissions
('PRODUCTS_READ', 'Read product information', 'PRODUCTS', 'READ'),
('PRODUCTS_WRITE', 'Create and update products', 'PRODUCTS', 'WRITE'),
('PRODUCTS_DELETE', 'Delete products', 'PRODUCTS', 'DELETE'),
('PRODUCTS_ADMIN', 'Administer products', 'PRODUCTS', 'ADMIN'),
-- Inventory permissions
('INVENTORY_READ', 'Read inventory information', 'INVENTORY', 'READ'),
('INVENTORY_WRITE', 'Create and update inventory', 'INVENTORY', 'WRITE'),
('INVENTORY_DELETE', 'Delete inventory', 'INVENTORY', 'DELETE'),
('INVENTORY_ADMIN', 'Administer inventory', 'INVENTORY', 'ADMIN'),
-- Transactions permissions
('TRANSACTIONS_READ', 'Read transaction information', 'TRANSACTIONS', 'READ'),
('TRANSACTIONS_WRITE', 'Create and update transactions', 'TRANSACTIONS', 'WRITE'),
('TRANSACTIONS_DELETE', 'Delete transactions', 'TRANSACTIONS', 'DELETE'),
('TRANSACTIONS_ADMIN', 'Administer transactions', 'TRANSACTIONS', 'ADMIN'),
-- Customers permissions
('CUSTOMERS_READ', 'Read customer information', 'CUSTOMERS', 'READ'),
('CUSTOMERS_WRITE', 'Create and update customers', 'CUSTOMERS', 'WRITE'),
('CUSTOMERS_DELETE', 'Delete customers', 'CUSTOMERS', 'DELETE'),
('CUSTOMERS_ADMIN', 'Administer customers', 'CUSTOMERS', 'ADMIN'),
-- Expenses permissions
('EXPENSES_READ', 'Read expense information', 'EXPENSES', 'READ'),
('EXPENSES_WRITE', 'Create and update expenses', 'EXPENSES', 'WRITE'),
('EXPENSES_DELETE', 'Delete expenses', 'EXPENSES', 'DELETE'),
('EXPENSES_ADMIN', 'Administer expenses', 'EXPENSES', 'ADMIN'),
-- Reports permissions
('REPORTS_READ', 'Read reports', 'REPORTS', 'READ'),
('REPORTS_WRITE', 'Create reports', 'REPORTS', 'WRITE'),
('REPORTS_ADMIN', 'Administer reports', 'REPORTS', 'ADMIN'),
-- Audit permissions
('AUDIT_READ', 'Read audit logs', 'AUDIT', 'READ'),
('AUDIT_ADMIN', 'Administer audit logs', 'AUDIT', 'ADMIN'),
-- System permissions
('SYSTEM_READ', 'Read system information', 'SYSTEM', 'READ'),
('SYSTEM_WRITE', 'Update system configuration', 'SYSTEM', 'WRITE'),
('SYSTEM_ADMIN', 'Administer system', 'SYSTEM', 'ADMIN')
ON CONFLICT (name) DO NOTHING;

-- Assign permissions to ADMIN role
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING; 