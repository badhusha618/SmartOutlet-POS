#!/bin/bash

# Auth Service Runner Script
# This script builds the common module and runs the auth service in debug mode with dev profile

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../auth-service || { echo "❌ Failed to navigate to auth-service module"; exit 1; }

echo "🚀 Starting Auth Service in Debug Mode..."
echo "=========================================="

# Check if port 8081 is already in use
if lsof -Pi :8081 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8081 is already in use!"
    echo "   Stopping existing process..."
    lsof -ti:8081 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if debug port 5005 is already in use
if lsof -Pi :5005 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Debug port 5005 is already in use!"
    echo "   Stopping existing debug process..."
    lsof -ti:5005 | xargs kill -9 2>/dev/null
    sleep 2
fi

echo "✅ Ports cleared, starting auth service..."

# Run the auth service with debug mode and dev profile
mvn spring-boot:run \
    -Dspring-boot.run.profiles=stage \
    #-Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

echo "🏁 Auth service stopped."
