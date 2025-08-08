#!/bin/bash

echo "Stopping SmartOutlet POS Backend Services..."

# Function to stop a service
stop_service() {
    local service_name=$1
    
    if [ -f "logs/${service_name}.pid" ]; then
        local pid=$(cat logs/${service_name}.pid)
        if ps -p $pid > /dev/null; then
            echo "Stopping $service_name (PID: $pid)..."
            kill $pid
            rm logs/${service_name}.pid
            echo "$service_name stopped."
        else
            echo "$service_name was not running."
            rm logs/${service_name}.pid 2>/dev/null
        fi
    else
        echo "No PID file found for $service_name."
    fi
}

# Stop services
stop_service "auth-service"
stop_service "outlet-service" 
stop_service "product-service"
stop_service "pos-service"
stop_service "expense-service"

echo ""
echo "All services stopped!"