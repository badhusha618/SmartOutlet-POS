#!/bin/bash

# Product Service Runner Script
# This script builds the common module and runs the product service in debug mode with dev profile

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../product-service || { echo "❌ Failed to navigate to product-service module"; exit 1; }

echo "🚀 Starting Product Service in Debug Mode..."
echo "============================================"

# Check if port 8083 is already in use
if lsof -Pi :8083 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8083 is already in use!"
    echo "   Stopping existing process..."
    lsof -ti:8083 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if debug port 5007 is already in use
if lsof -Pi :5007 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Debug port 5007 is already in use!"
    echo "   Stopping existing debug process..."
    lsof -ti:5007 | xargs kill -9 2>/dev/null
    sleep 2
fi

echo "✅ Ports cleared, starting product service..."

# Run the product service with debug mode and dev profile
mvn spring-boot:run \
    -Dspring-boot.run.profiles=dev \
    -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5007"

echo "🏁 Product service stopped." 