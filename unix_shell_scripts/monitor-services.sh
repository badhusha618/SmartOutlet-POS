#!/bin/bash
echo "🔍 SmartOutlet Services Status:"
echo ""

services=(
    "auth-service:8081:/auth/health"
    "outlet-service:8082:/outlets/health"
    "product-service:8083:/products/health"
    "inventory-service:8086:/api/inventory/actuator/health"
    "pos-service:8084:/pos/health"
    "expense-service:8085:/expenses/health"
    "api-gateway:8080:/actuator/health"
    "frontend:3000:/"
)

for service in "${services[@]}"; do
    IFS=':' read -r name port path <<< "$service"
    if curl -s -f "http://localhost:$port$path" >/dev/null 2>&1; then
        echo "✅ $name (port $port) - Running"
    else
        echo "❌ $name (port $port) - Not responding"
    fi
done

echo ""
echo "Docker containers:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=smartoutlet"
