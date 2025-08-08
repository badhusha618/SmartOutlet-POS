# SmartOutlet POS - Backend Startup Script for Java 17
Write-Host "Starting SmartOutlet POS Backend Services with Java 17..." -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# Set Java environment
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";C:\Program Files\Java\jdk-17\bin"

# Verify Java
Write-Host "Checking Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found" -ForegroundColor Red
    exit 1
}

# Set Maven path
$mavenPath = "..\maven\bin\mvn.cmd"

# Function to start a service
function Start-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath,
        [int]$Port
    )
    
    Write-Host "Starting $ServiceName on port $Port..." -ForegroundColor Yellow
    
    $serviceDir = "backend\$ServicePath"
    if (Test-Path $serviceDir) {
        Push-Location $serviceDir
        try {
            # Start the service in background
            Start-Process -FilePath "java" -ArgumentList "-jar", "target\$ServiceName-1.0.0.jar" -WindowStyle Hidden
            Write-Host "✅ $ServiceName started" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to start $ServiceName" -ForegroundColor Red
        }
        Pop-Location
    } else {
        Write-Host "❌ Service directory not found: $serviceDir" -ForegroundColor Red
    }
}

# Build all services first
Write-Host "Building all services..." -ForegroundColor Yellow
Push-Location backend

try {
    # Build parent project
    & $mavenPath clean install -DskipTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All services built successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Pop-Location

# Start services in order
Write-Host "Starting services..." -ForegroundColor Yellow

# Start auth service first (required by others)
Start-Service "auth-service" "auth-service" 8081
Start-Sleep -Seconds 5

# Start other services
Start-Service "outlet-service" "outlet-service" 8082
Start-Service "product-service" "product-service" 8083
Start-Service "inventory-service" "inventory-service" 8086
Start-Service "pos-service" "pos-service" 8084
Start-Service "expense-service" "expense-service" 8085
Start-Sleep -Seconds 5

# Start API gateway last
Start-Service "api-gateway" "api-gateway" 8080

Write-Host ""
Write-Host "🎉 Backend services are starting up!" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Auth Service:      http://localhost:8081" -ForegroundColor White
Write-Host "  Outlet Service:    http://localhost:8082" -ForegroundColor White
Write-Host "  Product Service:   http://localhost:8083" -ForegroundColor White
Write-Host "  Inventory Service: http://localhost:8086" -ForegroundColor White
Write-Host "  POS Service:       http://localhost:8084" -ForegroundColor White
Write-Host "  Expense Service:   http://localhost:8085" -ForegroundColor White
Write-Host "  API Gateway:       http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "Health checks:" -ForegroundColor Cyan
Write-Host "  Auth: http://localhost:8081/actuator/health" -ForegroundColor White
Write-Host "  API Gateway: http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Swagger docs:" -ForegroundColor Cyan
Write-Host "  Auth: http://localhost:8081/swagger-ui.html" -ForegroundColor White
Write-Host "  API Gateway: http://localhost:8080/swagger-ui.html" -ForegroundColor White 