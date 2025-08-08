-- V1__init_product_schema.sql for PostgreSQL
-- Create smartoutlet_product database if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'smartoutlet_product') THEN
        PERFORM pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
        WHERE pg_stat_activity.datname = 'smartoutlet_product'
          AND pid <> pg_backend_pid();
        EXECUTE 'CREATE DATABASE smartoutlet_product';
    END IF;
END $$;
-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    parent_id BIGINT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    sku VARCHAR(50) UNIQUE NOT NULL,
    barcode VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    stock_quantity INTEGER DEFAULT 0 NOT NULL,
    min_stock_level INTEGER DEFAULT 5,
    max_stock_level INTEGER DEFAULT 1000,
    category_id BIGINT,
    unit_of_measure VARCHAR(20) DEFAULT 'PIECE',
    weight DECIMAL(8,3),
    dimensions VARCHAR(100),
    brand VARCHAR(100),
    supplier VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    is_taxable BOOLEAN DEFAULT true,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    image_url VARCHAR(500),
    tags VARCHAR(500),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Create stock_movements table
CREATE TABLE IF NOT EXISTS stock_movements (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    movement_type VARCHAR(20) NOT NULL, -- IN, OUT, TRANSFER
    quantity INTEGER NOT NULL,
    previous_stock INTEGER,
    new_stock INTEGER,
    reason VARCHAR(200),
    reference_id VARCHAR(100),
    reference_type VARCHAR(50),
    outlet_id BIGINT,
    user_id BIGINT,
    created_at TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Create error_logs table
CREATE TABLE IF NOT EXISTS error_logs (
    id BIGSERIAL PRIMARY KEY,
    error_message TEXT,
    error_type VARCHAR(100),
    stack_trace TEXT,
    file_name VARCHAR(255),
    line_number INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    user_id BIGINT,
    username VARCHAR(50),
    request_url VARCHAR(255),
    request_method VARCHAR(10),
    request_body TEXT,
    response_status INTEGER,
    action_performed VARCHAR(255),
    occurrence_count INTEGER,
    first_occurrence TIMESTAMP,
    last_occurrence TIMESTAMP,
    is_resolved BOOLEAN,
    resolution_notes TEXT,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255)
);

-- Create indexes for better performance
CREATE INDEX idx_product_sku ON products (sku);
CREATE INDEX idx_product_barcode ON products (barcode);
CREATE INDEX idx_product_category ON products (category_id);
CREATE INDEX idx_product_brand ON products (brand);
CREATE INDEX idx_product_supplier ON products (supplier);
CREATE INDEX idx_product_is_active ON products (is_active);
CREATE INDEX idx_stock_movement_product ON stock_movements (product_id);
CREATE INDEX idx_stock_movement_type ON stock_movements (movement_type);
CREATE INDEX idx_stock_movement_reference ON stock_movements (reference_id);
CREATE INDEX idx_stock_movement_outlet ON stock_movements (outlet_id);
CREATE INDEX idx_error_type ON error_logs (error_type);
CREATE INDEX idx_error_action_performed ON error_logs (action_performed);
CREATE INDEX idx_error_created_at ON error_logs (created_at);
CREATE INDEX idx_error_file_name ON error_logs (file_name);
CREATE INDEX idx_error_line_number ON error_logs (line_number); 