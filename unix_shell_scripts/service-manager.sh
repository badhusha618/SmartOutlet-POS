#!/bin/bash

# SmartOutlet POS - Service Manager Script
# This script provides a menu-driven interface to manage all services

echo "🎛️  SmartOutlet POS - Service Manager"
echo "====================================="

# Function to check service status
check_service_status() {
    local port=$1
    local service_name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo "🟢 $service_name (Port $port) - RUNNING"
    else
        echo "🔴 $service_name (Port $port) - STOPPED"
    fi
}

# Function to show service status
show_status() {
    echo ""
    echo "📊 Service Status:"
    echo "=================="
    check_service_status 8080 "API Gateway"
    check_service_status 8081 "Auth Service"
    check_service_status 8082 "Product Service"
    check_service_status 8083 "Outlet Service"
    check_service_status 8084 "Expense Service"
    echo ""
    echo "🔍 Debug Ports:"
    echo "==============="
    check_service_status 5005 "Auth Debug"
    check_service_status 5006 "API Gateway Debug"
    check_service_status 5007 "Product Debug"
    check_service_status 5008 "Outlet Debug"
    check_service_status 5009 "Expense Debug"
    echo ""
}

# Function to show menu
show_menu() {
    echo ""
    echo "📋 Available Actions:"
    echo "===================="
    echo "1️⃣  Start All Services"
    echo "2️⃣  Stop All Services"
    echo "3️⃣  Restart All Services"
    echo "4️⃣  Show Service Status"
    echo "5️⃣  Start Individual Service"
    echo "6️⃣  Stop Individual Service"
    echo "7️⃣  View Service Logs"
    echo "8️⃣  Clear All Logs"
    echo "9️⃣  Exit"
    echo ""
    echo "Enter your choice (1-9): "
}

# Function to start individual service
start_individual_service() {
    echo ""
    echo "🚀 Start Individual Service:"
    echo "============================"
    echo "1. Auth Service (Port 8081, Debug 5005)"
    echo "2. API Gateway (Port 8080, Debug 5006)"
    echo "3. Product Service (Port 8082, Debug 5007)"
    echo "4. Outlet Service (Port 8083, Debug 5008)"
    echo "5. Expense Service (Port 8084, Debug 5009)"
    echo "6. Back to main menu"
    echo ""
    echo "Enter your choice (1-6): "
    read -r choice
    
    case $choice in
        1) ./auth-service/run-auth-service.sh ;;
        2) ./api-gateway/run-api-gateway.sh ;;
        3) ./product-service/run-product-service.sh ;;
        4) ./outlet-service/run-outlet-service.sh ;;
        5) ./expense-service/run-expense-service.sh ;;
        6) return ;;
        *) echo "❌ Invalid choice!" ;;
    esac
}

# Function to stop individual service
stop_individual_service() {
    echo ""
    echo "🛑 Stop Individual Service:"
    echo "==========================="
    echo "1. Auth Service (Port 8081)"
    echo "2. API Gateway (Port 8080)"
    echo "3. Product Service (Port 8082)"
    echo "4. Outlet Service (Port 8083)"
    echo "5. Expense Service (Port 8084)"
    echo "6. Back to main menu"
    echo ""
    echo "Enter your choice (1-6): "
    read -r choice
    
    case $choice in
        1) lsof -ti:8081 | xargs kill -9 2>/dev/null; echo "✅ Auth Service stopped" ;;
        2) lsof -ti:8080 | xargs kill -9 2>/dev/null; echo "✅ API Gateway stopped" ;;
        3) lsof -ti:8082 | xargs kill -9 2>/dev/null; echo "✅ Product Service stopped" ;;
        4) lsof -ti:8083 | xargs kill -9 2>/dev/null; echo "✅ Outlet Service stopped" ;;
        5) lsof -ti:8084 | xargs kill -9 2>/dev/null; echo "✅ Expense Service stopped" ;;
        6) return ;;
        *) echo "❌ Invalid choice!" ;;
    esac
}

# Function to view service logs
view_logs() {
    echo ""
    echo "📋 View Service Logs:"
    echo "====================="
    echo "1. Auth Service Log"
    echo "2. API Gateway Log"
    echo "3. Product Service Log"
    echo "4. Outlet Service Log"
    echo "5. Expense Service Log"
    echo "6. All Logs (tail -f)"
    echo "7. Back to main menu"
    echo ""
    echo "Enter your choice (1-7): "
    read -r choice
    
    case $choice in
        1) tail -f logs/auth-service.log ;;
        2) tail -f logs/api-gateway-service.log ;;
        3) tail -f logs/product-service.log ;;
        4) tail -f logs/outlet-service.log ;;
        5) tail -f logs/expense-service.log ;;
        6) tail -f logs/*.log ;;
        7) return ;;
        *) echo "❌ Invalid choice!" ;;
    esac
}

# Function to clear logs
clear_logs() {
    echo "🗑️  Clearing all service logs..."
    rm -f logs/*.log
    echo "✅ All logs cleared!"
}

# Main menu loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) ./run-all-services.sh ;;
        2) ./stop-all-services.sh ;;
        3) ./restart-all-services.sh ;;
        4) show_status ;;
        5) start_individual_service ;;
        6) stop_individual_service ;;
        7) view_logs ;;
        8) clear_logs ;;
        9) echo "👋 Goodbye!"; exit 0 ;;
        *) echo "❌ Invalid choice! Please enter 1-9." ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read -r
done 