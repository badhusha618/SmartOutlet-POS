#!/bin/bash

# SmartOutlet POS - Complete Service Startup Script
echo "🚀 Starting SmartOutlet POS System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker is running
if ! sudo docker ps >/dev/null 2>&1; then
    print_error "Docker is not running. Starting Docker daemon..."
    sudo nohup dockerd >/dev/null 2>&1 &
    sleep 5
    if ! sudo docker ps >/dev/null 2>&1; then
        print_error "Failed to start Docker daemon!"
        exit 1
    fi
fi

print_success "Docker is running"

# Function to check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Function to wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local timeout=${3:-60}
    
    print_status "Waiting for $service_name to be ready..."
    local count=0
    while [ $count -lt $timeout ]; do
        if curl -s -f "$url" >/dev/null 2>&1; then
            print_success "$service_name is ready!"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        echo -n "."
    done
    print_error "$service_name failed to start within $timeout seconds"
    return 1
}

# Start infrastructure services using Docker
print_status "Starting infrastructure services with Docker..."

# Create network if it doesn't exist
sudo docker network create smartoutlet-network 2>/dev/null || true

# Start PostgreSQL
print_status "Starting PostgreSQL..."
sudo docker run -d \
    --name smartoutlet-postgres \
    --network smartoutlet-network \
    -e POSTGRES_DB=smartoutlet_auth \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=smartoutlet123 \
    -p 5432:5432 \
    -v $(pwd)/scripts/init-databases.sql:/docker-entrypoint-initdb.d/init-databases.sql \
    postgres:15 2>/dev/null || print_warning "PostgreSQL container already exists"

# Start Redis
print_status "Starting Redis..."
sudo docker run -d \
    --name smartoutlet-redis \
    --network smartoutlet-network \
    -p 6379:6379 \
    redis:7.2-alpine redis-server --requirepass smartoutlet123 2>/dev/null || print_warning "Redis container already exists"

# Wait for PostgreSQL to be ready
sleep 10

# Start backend services
print_status "Starting backend services..."

# Function to start a Spring Boot service
start_service() {
    local service_name=$1
    local port=$2
    local profile=${3:-"test"}
    
    print_status "Starting $service_name on port $port..."
    
    if check_port $port; then
        cd backend/$service_name
        nohup mvn spring-boot:run -Dspring-boot.run.profiles=$profile -Dserver.port=$port >/dev/null 2>&1 &
        local pid=$!
        echo $pid > /tmp/smartoutlet-$service_name.pid
        cd ../..
        print_success "$service_name started with PID $pid"
    else
        print_warning "Port $port is already in use, skipping $service_name"
    fi
}

# Start backend services in dependency order
start_service "auth-service" 8081 "test"
sleep 5

start_service "outlet-service" 8082 "test"
start_service "product-service" 8083 "test"
start_service "inventory-service" 8086 "test"
start_service "pos-service" 8084 "test"
start_service "expense-service" 8085 "test"
sleep 5

start_service "api-gateway" 8080 "test"
sleep 10

# Start frontend
print_status "Starting React frontend..."
if check_port 3000; then
    cd frontend
    nohup npm run dev >/dev/null 2>&1 &
    local frontend_pid=$!
    echo $frontend_pid > /tmp/smartoutlet-frontend.pid
    cd ..
    print_success "Frontend started with PID $frontend_pid"
else
    print_warning "Port 3000 is already in use, skipping frontend"
fi

# Wait for services to be ready
print_status "Checking service health..."

# Check backend services
wait_for_service "http://localhost:8081/auth/health" "Auth Service" 30
wait_for_service "http://localhost:8082/outlets/health" "Outlet Service" 30
wait_for_service "http://localhost:8083/products/health" "Product Service" 30
wait_for_service "http://localhost:8080/actuator/health" "API Gateway" 30

# Check frontend
sleep 5
if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
    print_success "Frontend is ready!"
else
    print_warning "Frontend may still be starting up"
fi

echo ""
print_success "🎉 SmartOutlet POS System is now running!"
echo ""
echo -e "${BLUE}Service URLs:${NC}"
echo "  🔐 Auth Service:      http://localhost:8081/swagger-ui.html"
echo "  🏪 Outlet Service:    http://localhost:8082/swagger-ui.html"
echo "  📦 Product Service:   http://localhost:8083/swagger-ui.html"
echo "  📊 Inventory Service: http://localhost:8086/swagger-ui.html"
echo "  🛒 POS Service:       http://localhost:8084/swagger-ui.html"
echo "  💰 Expense Service:   http://localhost:8085/swagger-ui.html"
echo "  🌐 API Gateway:       http://localhost:8080/swagger-ui.html"
echo "  🎨 Frontend:          http://localhost:3000"
echo ""
echo -e "${BLUE}Database:${NC}"
echo "  🗄️  PostgreSQL:       localhost:5432 (postgres/smartoutlet123)"
echo "  🔄 Redis:             localhost:6379 (password: smartoutlet123)"
echo ""
echo -e "${BLUE}Management:${NC}"
echo "  📊 Health checks available at /health endpoints"
echo "  📖 API documentation at /swagger-ui.html endpoints"
echo ""
echo -e "${YELLOW}To stop all services, run:${NC} ./stop-all-services.sh"
echo ""

# Create a simple monitoring script
cat > monitor-services.sh << 'EOF'
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
EOF

chmod +x monitor-services.sh
print_success "Created monitoring script: ./monitor-services.sh"