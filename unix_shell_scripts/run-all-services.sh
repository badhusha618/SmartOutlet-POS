#!/bin/bash

# SmartOutlet POS - All Services Runner Script
# This script runs all services in debug mode with dev profile

echo "🚀 Starting SmartOutlet POS - All Services in Debug Mode..."
echo "=========================================================="

# Function to check and kill processes on a port
check_and_kill_port() {
    local port=$1
    local service_name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo "❌ Port $port ($service_name) is already in use!"
        echo "   Stopping existing process..."
        lsof -ti:$port | xargs kill -9 2>/dev/null
        sleep 2
    fi
}

# Check and kill all service ports
echo "🔍 Checking and clearing ports..."
check_and_kill_port 8080 "API Gateway"
check_and_kill_port 8081 "Auth Service"
check_and_kill_port 8082 "Product Service"
check_and_kill_port 8083 "Outlet Service"
check_and_kill_port 8084 "Expense Service"

# Check and kill all debug ports
check_and_kill_port 5005 "Auth Debug"
check_and_kill_port 5006 "API Gateway Debug"
check_and_kill_port 5007 "Product Debug"
check_and_kill_port 5008 "Outlet Debug"
check_and_kill_port 5009 "Expense Debug"

echo "✅ All ports cleared!"

# Function to start a service in background
start_service() {
    local service_dir=$1
    local service_name=$2
    local port=$3
    local debug_port=$4
    
    echo "🚀 Starting $service_name on port $port (debug: $debug_port)..."
    
    cd "$service_dir" || exit 1
    
    # Start service in background
    mvn spring-boot:run \
        -Dspring-boot.run.profiles=dev \
        -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=$debug_port" \
        > "../logs/${service_name}-service.log" 2>&1 &
    
    local pid=$!
    echo "✅ $service_name started with PID: $pid"
    
    # Wait a bit for service to start
    sleep 5
    
    cd - > /dev/null || exit 1
}

# Create logs directory if it doesn't exist
mkdir -p logs

echo "📁 Starting all services..."

# Start all services
start_service "auth-service" "Auth" 8081 5005
start_service "api-gateway" "API Gateway" 8080 5006
start_service "product-service" "Product" 8082 5007
start_service "outlet-service" "Outlet" 8083 5008
start_service "expense-service" "Expense" 8084 5009

echo ""
echo "🎉 All services started successfully!"
echo "====================================="
echo "📊 Service Status:"
echo "   🔐 Auth Service:      http://localhost:8081 (debug: 5005)"
echo "   🌐 API Gateway:       http://localhost:8080 (debug: 5006)"
echo "   📦 Product Service:   http://localhost:8082 (debug: 5007)"
echo "   🏪 Outlet Service:    http://localhost:8083 (debug: 5008)"
echo "   💰 Expense Service:   http://localhost:8084 (debug: 5009)"
echo ""
echo "🔍 Debug Ports:"
echo "   Auth: 5005, API Gateway: 5006, Product: 5007, Outlet: 5008, Expense: 5009"
echo ""
echo "📋 Logs are available in: backend/logs/"
echo ""
echo "⏹️  To stop all services, run: ./stop-all-services.sh"
echo "🔄 To restart all services, run: ./restart-all-services.sh"

# Wait for user input to stop
echo ""
echo "Press Ctrl+C to stop all services..."
wait 