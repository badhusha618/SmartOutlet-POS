#!/bin/bash

# Initialize SDKMAN for Maven
source "/Users/admin/.sdkman/bin/sdkman-init.sh"

echo "Starting SmartOutlet POS Backend Services..."

# Function to start a service
start_service() {
    local service_name=$1
    local service_port=$2
    
    echo "Starting $service_name on port $service_port..."
    cd $service_name
    
    # Check if Maven wrapper exists, otherwise use maven
    if [ -f "./mvnw" ]; then
        ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev > ../logs/${service_name}.log 2>&1 &
    else
        mvn spring-boot:run -Dspring-boot.run.profiles=dev > ../logs/${service_name}.log 2>&1 &
    fi
    
    echo $! > ../logs/${service_name}.pid
    cd ..
    echo "$service_name started with PID $(cat logs/${service_name}.pid)"
}

# Create logs directory
mkdir -p logs

# Start services in order
start_service "auth-service" 8081
sleep 10

start_service "outlet-service" 8082
sleep 5

start_service "product-service" 8084
sleep 5

start_service "pos-service" 8085
sleep 5

start_service "expense-service" 8083

echo ""
echo "All services started! Check logs in the 'logs' directory."
echo ""
echo "Service URLs:"
echo "- Auth Service: http://localhost:8081/swagger-ui.html"
echo "- Outlet Service: http://localhost:8082/swagger-ui.html"
echo "- Product Service: http://localhost:8084/swagger-ui.html"
echo "- POS Service: http://localhost:8085/swagger-ui.html"
echo "- Expense Service: http://localhost:8083/swagger-ui.html"
echo ""
echo "To stop all services, run: ./stop-services.sh"