#!/bin/bash

echo "=== SmartOutlet POS Backend Services Startup ==="
echo "Creating databases and starting all services..."

# Function to create database
create_database() {
    local db_name=$1
    echo "Creating database: $db_name"
    psql -U postgres -c "CREATE DATABASE $db_name;" 2>/dev/null || echo "Database $db_name might already exist"
}

# Function to start service
start_service() {
    local service_name=$1
    local service_path=$2
    echo "Starting $service_name..."
    cd "$service_path" && mvn spring-boot:run -Dspring-boot.run.profiles=dev &
    sleep 10
}

# Create all databases
echo "=== Creating Databases ==="
create_database "smartoutlet_auth"
create_database "smartoutlet_product"
create_database "smartoutlet_outlet"
create_database "smartoutlet_expense"

echo "=== Starting Services ==="

# Start auth service first
start_service "Auth Service" "auth-service"

# Start product service
start_service "Product Service" "product-service"

# Start outlet service
start_service "Outlet Service" "outlet-service"

# Start expense service
start_service "Expense Service" "expense-service"

# Start API Gateway last
start_service "API Gateway" "api-gateway"

echo "=== All Services Started ==="
echo "Waiting for services to be ready..."

# Wait for services to start
sleep 60

echo "=== Service Status ==="
ps aux | grep "spring-boot:run" | grep -v grep

echo "=== Port Status ==="
for port in 8080 8081 8082 8083 8084; do
    echo "Port $port:"
    lsof -i :$port 2>/dev/null | head -1 || echo "  Not listening"
done

echo "=== Swagger URLs ==="
echo "API Gateway: http://localhost:8080/swagger-ui.html"
echo "Auth Service: http://localhost:8081/swagger-ui/index.html"
echo "Product Service: http://localhost:8082/swagger-ui/index.html"
echo "Outlet Service: http://localhost:8083/swagger-ui/index.html"
echo "Expense Service: http://localhost:8084/swagger-ui/index.html"

echo "=== Startup Complete ==="
echo "All services should be running now. Check the URLs above for Swagger documentation." 