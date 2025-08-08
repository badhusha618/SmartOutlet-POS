#!/bin/bash

# SmartOutlet POS - Service Stop Script
echo "🛑 Stopping SmartOutlet POS System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Stop Spring Boot services using PID files
services=("auth-service" "outlet-service" "product-service" "inventory-service" "pos-service" "expense-service" "api-gateway")

print_status "Stopping backend services..."
for service in "${services[@]}"; do
    if [ -f "/tmp/smartoutlet-$service.pid" ]; then
        pid=$(cat "/tmp/smartoutlet-$service.pid")
        if kill -0 "$pid" 2>/dev/null; then
            print_status "Stopping $service (PID: $pid)..."
            kill "$pid"
            rm -f "/tmp/smartoutlet-$service.pid"
            print_success "$service stopped"
        else
            print_warning "$service was not running"
            rm -f "/tmp/smartoutlet-$service.pid"
        fi
    else
        print_warning "No PID file found for $service"
    fi
done

# Stop frontend
print_status "Stopping frontend..."
if [ -f "/tmp/smartoutlet-frontend.pid" ]; then
    pid=$(cat "/tmp/smartoutlet-frontend.pid")
    if kill -0 "$pid" 2>/dev/null; then
        print_status "Stopping frontend (PID: $pid)..."
        kill "$pid"
        rm -f "/tmp/smartoutlet-frontend.pid"
        print_success "Frontend stopped"
    else
        print_warning "Frontend was not running"
        rm -f "/tmp/smartoutlet-frontend.pid"
    fi
else
    print_warning "No PID file found for frontend"
fi

# Stop any remaining Java processes related to SmartOutlet
print_status "Cleaning up any remaining Java processes..."
pkill -f "smartoutlet" 2>/dev/null || true
pkill -f "spring-boot:run" 2>/dev/null || true

# Stop Docker containers
print_status "Stopping Docker containers..."
sudo docker stop smartoutlet-postgres smartoutlet-redis 2>/dev/null || print_warning "Some containers were not running"
sudo docker rm smartoutlet-postgres smartoutlet-redis 2>/dev/null || print_warning "Some containers were already removed"

# Remove Docker network
print_status "Cleaning up Docker network..."
sudo docker network rm smartoutlet-network 2>/dev/null || print_warning "Network was already removed"

# Kill any processes on specific ports
print_status "Freeing up ports..."
ports=(3000 8080 8081 8082 8083 8084 8085 8086 5432 6379)
for port in "${ports[@]}"; do
    pid=$(lsof -ti tcp:$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        print_status "Killing process on port $port (PID: $pid)"
        kill -9 "$pid" 2>/dev/null || true
    fi
done

print_success "🎉 All SmartOutlet POS services have been stopped!"
echo ""
print_status "System is now clean and ready for restart"