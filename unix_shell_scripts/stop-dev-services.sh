
#!/bin/bash

echo "🛑 Stopping SmartOutlet POS Services"
echo "===================================="

# Function to stop a service
stop_service() {
    local service_name=$1
    local service_port=$2
    
    if [ -f "logs/${service_name}.pid" ]; then
        local pid=$(cat logs/${service_name}.pid)
        echo "🔧 Stopping $service_name (PID: $pid)..."
        kill -9 $pid 2>/dev/null || true
        rm -f logs/${service_name}.pid
    fi
    
    # Also kill by port
    lsof -ti:$service_port | xargs kill -9 2>/dev/null || true
    echo "✅ $service_name stopped"
}

# Stop all services
stop_service "auth-service" 8081
stop_service "outlet-service" 8083
stop_service "product-service" 8082
stop_service "expense-service" 8084
stop_service "pos-service" 8085

echo ""
echo "✅ All services stopped successfully!"
