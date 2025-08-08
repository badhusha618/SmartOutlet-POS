#!/bin/bash

# POS Service Runner Script
# This script builds the common module and runs the POS service in debug mode with dev profile

echo "🔧 Building common module..."
cd ../common-module || { echo "❌ Failed to navigate to common module"; exit 1; }

mvn clean install || { echo "❌ Failed to build common module"; exit 1; }

echo "✅ Common module built successfully."
echo "=========================================="

cd ../pos-service || { echo "❌ Failed to navigate to pos-service module"; exit 1; }

echo "🚀 Starting POS Service in Debug Mode..."
echo "=========================================="

# Check if port 8085 is already in use
if lsof -Pi :8085 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8085 is already in use!"
    echo "   Stopping existing process..."
    lsof -ti:8085 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Check if debug port 5010 is already in use
if lsof -Pi :5010 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Debug port 5010 is already in use!"
    echo "   Stopping existing debug process..."
    lsof -ti:5010 | xargs kill -9 2>/dev/null
    sleep 2
fi

echo "✅ Ports cleared, starting POS service..."

# Run the POS service with debug mode and dev profile
mvn spring-boot:run \
    -Dspring-boot.run.profiles=dev \
    -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5010"

echo "🏁 POS service stopped."
