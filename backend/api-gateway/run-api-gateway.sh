#!/bin/bash

# API Gateway Runner Script
# This script builds the common module and runs the API gateway service in debug mode with dev profile

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../api-gateway || { echo "❌ Failed to navigate to api-gateway module"; exit 1; }

echo "🚀 Stopping API Gateway if it is running..."
# Stop the API Gateway if it's running on port 8080
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "🔄 Stopping running API Gateway on port 8080..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    sleep 3
    echo "✅ API Gateway stopped."
else
    echo "✅ No API Gateway running on port 8080."
fi

# Check if debug port 5006 is already in use
if lsof -Pi :5006 -sTCP:LISTEN -t >/dev/null ; then
    echo "🔄 Stopping existing debug process on port 5006..."
    lsof -ti:5006 | xargs kill -9 2>/dev/null
    sleep 2
    echo "✅ Debug process stopped."
fi

echo "🚀 Starting API Gateway in Debug Mode..."
echo "========================================"

# Run the API gateway with debug mode and dev profile
mvn spring-boot:run \
    -Dspring-boot.run.profiles=dev \
    #-Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=0.0.0.0:5006"

echo "🏁 API gateway stopped."