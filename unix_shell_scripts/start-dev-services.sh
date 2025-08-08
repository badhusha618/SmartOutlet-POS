
#!/bin/bash

echo "🚀 Starting SmartOutlet POS Services for Development"
echo "===================================================="

# Create logs directory
mkdir -p logs

# Function to start a service
start_service() {
    local service_name=$1
    local service_port=$2
    
    echo "🔧 Starting $service_name on port $service_port..."
    cd $service_name
    
    # Kill any existing process on the port
    lsof -ti:$service_port | xargs kill -9 2>/dev/null || true
    
    # Start the service
    mvn spring-boot:run -Dspring-boot.run.profiles=dev > ../logs/${service_name}.log 2>&1 &
    
    echo $! > ../logs/${service_name}.pid
    cd ..
    sleep 5
    echo "✅ $service_name started (PID: $(cat logs/${service_name}.pid))"
}

# Build common module first
echo "🔨 Building common module..."
cd common-module
mvn clean install -q
cd ..

# Start services
start_service "auth-service" 8081
start_service "outlet-service" 8083
start_service "product-service" 8082
start_service "expense-service" 8084
start_service "pos-service" 8085

echo ""
echo "🎉 All services started successfully!"
echo "======================================"
echo "📊 Service URLs:"
echo "   🔐 Auth Service:      http://localhost:8081/swagger-ui/index.html"
echo "   🏪 Outlet Service:    http://localhost:8083/swagger-ui/index.html"
echo "   📦 Product Service:   http://localhost:8082/swagger-ui/index.html"
echo "   💰 Expense Service:   http://localhost:8084/swagger-ui/index.html"
echo "   🛒 POS Service:       http://localhost:8085/swagger-ui/index.html"
echo ""
echo "📋 Logs are available in: backend/logs/"
echo "⏹️  To stop services: ./stop-dev-services.sh"
