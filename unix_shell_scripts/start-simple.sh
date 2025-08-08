#!/bin/bash

# Initialize SDKMAN for Maven
source "/Users/admin/.sdkman/bin/sdkman-init.sh"

echo "Starting SmartOutlet POS Backend Services (Simple Mode)..."

# Create logs directory
mkdir -p logs

# Function to start a service with better error handling
start_service() {
    local service_name=$1
    local service_port=$2
    
    echo "Starting $service_name on port $service_port..."
    cd $service_name
    
    # Try to compile first
    echo "Compiling $service_name..."
    if mvn clean compile -q; then
        echo "Compilation successful for $service_name"
        # Start the service
        mvn spring-boot:run -Dspring-boot.run.profiles=dev > ../logs/${service_name}.log 2>&1 &
        local pid=$!
        echo $pid > ../logs/${service_name}.pid
        echo "$service_name started with PID $pid"
    else
        echo "Compilation failed for $service_name. Check logs."
        return 1
    fi
    
    cd ..
    return 0
}

# Start services one by one
echo "Starting outlet-service..."
if start_service "outlet-service" 8082; then
    echo "outlet-service started successfully"
    sleep 10
else
    echo "Failed to start outlet-service"
fi

echo "Starting product-service..."
if start_service "product-service" 8084; then
    echo "product-service started successfully"
    sleep 10
else
    echo "Failed to start product-service"
fi

echo "Starting pos-service..."
if start_service "pos-service" 8085; then
    echo "pos-service started successfully"
    sleep 10
else
    echo "Failed to start pos-service"
fi

echo "Starting expense-service..."
if start_service "expense-service" 8083; then
    echo "expense-service started successfully"
    sleep 10
else
    echo "Failed to start expense-service"
fi

echo ""
echo "Services started! Check logs in the 'logs' directory."
echo ""
echo "Service URLs:"
echo "- Outlet Service: http://localhost:8082/swagger-ui.html"
echo "- Product Service: http://localhost:8084/swagger-ui.html"
echo "- POS Service: http://localhost:8085/swagger-ui.html"
echo "- Expense Service: http://localhost:8083/swagger-ui.html"
echo ""
# echo "To stop all services, run: ./stop-services.sh" 