#!/bin/bash

# Inventory Service Runner Script
# This script builds the common module and runs the inventory service in debug mode with dev profile

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Smart Outlet Inventory Service ===${NC}"

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../inventory-service || { echo "❌ Failed to navigate to inventory-service module"; exit 1; }

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}Maven is not installed. Please install Maven first.${NC}"
    exit 1
fi

# Set default profile if not provided
PROFILE=${1:-dev}
echo -e "${YELLOW}Starting Inventory Service with profile: $PROFILE${NC}"

# Check if port 8086 is already in use
if lsof -Pi :8086 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8086 is already in use!"
    echo "   Stopping existing process..."
    lsof -ti:8086 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if debug port 5011 is already in use
if lsof -Pi :5011 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Debug port 5011 is already in use!"
    echo "   Stopping existing debug process..."
    lsof -ti:5011 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Clean and compile
echo -e "${YELLOW}Cleaning and compiling...${NC}"
mvn clean compile

if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed!${NC}"
    exit 1
fi

echo "✅ Ports cleared, starting inventory service..."

# Run the inventory service with debug mode and dev profile
echo -e "${GREEN}Starting Inventory Service...${NC}"
echo -e "${YELLOW}Service will be available at: http://localhost:8086${NC}"
echo -e "${YELLOW}Swagger UI: http://localhost:8086/api/inventory/swagger-ui.html${NC}"

mvn spring-boot:run \
    -Dspring-boot.run.profiles=dev \
    -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5011"

echo "🏁 Inventory service stopped."