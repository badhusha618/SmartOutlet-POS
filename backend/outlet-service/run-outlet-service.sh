#!/bin/bash

# Outlet Service Runner Script
# This script builds the common module and runs the outlet service in debug mode with dev profile

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../outlet-service || { echo "❌ Failed to navigate to outlet-service module"; exit 1; }

echo "🚀 Starting Outlet Service in Debug Mode..."
echo "==========================================="

# Check if port 8082 is already in use
if lsof -Pi :8082 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8082 is already in use!"
    echo "   Stopping existing process..."
    lsof -ti:8082 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if debug port 5008 is already in use
if lsof -Pi :5008 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Debug port 5008 is already in use!"
    echo "   Stopping existing debug process..."
    lsof -ti:5008 | xargs kill -9 2>/dev/null
    sleep 2
fi

echo "✅ Ports cleared, starting outlet service..."

# Run the outlet service with debug mode and dev profile
mvn spring-boot:run \
    -Dspring-boot.run.profiles=dev \
    -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5008"

echo "🏁 Outlet service stopped." 