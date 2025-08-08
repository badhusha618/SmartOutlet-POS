# Simple script to start backend services
Write-Host "Starting SmartOutlet POS Backend Services..." -ForegroundColor Green

# Set up environment
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";C:\Program Files\Java\jdk-17\bin;$env:TEMP\apache-maven-3.9.6\bin"

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
        
        # Remove test directory if it exists to avoid compilation issues
        if (Test-Path "src\test") {
            Remove-Item -Path "src\test" -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Start the service
        try {
            $process = Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run", "-Dspring-boot.run.profiles=dev", "-Dserver.port=$Port" -WindowStyle Hidden -PassThru
            Write-Host "$ServiceName started with PID: $($process.Id)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to start $ServiceName" -ForegroundColor Red
        }
        
        Pop-Location
        Start-Sleep -Seconds 10
    } else {
        Write-Host "Service directory not found: $serviceDir" -ForegroundColor Red
    }
}

# Build common module first
Write-Host "Building common module..." -ForegroundColor Yellow
Push-Location backend\common-module
try {
    mvn clean install -DskipTests -q
    Write-Host "Common module built successfully" -ForegroundColor Green
} catch {
    Write-Host "Common module build failed" -ForegroundColor Red
    exit 1
}
Pop-Location

# Start services
Start-Service "auth-service" "auth-service" 8081
Start-Service "outlet-service" "outlet-service" 8082
Start-Service "product-service" "product-service" 8083
Start-Service "inventory-service" "inventory-service" 8086
Start-Service "pos-service" "pos-service" 8084
Start-Service "expense-service" "expense-service" 8085
Start-Service "api-gateway" "api-gateway" 8080

Write-Host ""
Write-Host "All services started!" -ForegroundColor Green
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Auth Service:      http://localhost:8081" -ForegroundColor White
Write-Host "  Outlet Service:    http://localhost:8082" -ForegroundColor White
Write-Host "  Product Service:   http://localhost:8083" -ForegroundColor White
Write-Host "  Inventory Service: http://localhost:8086" -ForegroundColor White
Write-Host "  POS Service:       http://localhost:8084" -ForegroundColor White
Write-Host "  Expense Service:   http://localhost:8085" -ForegroundColor White
Write-Host "  API Gateway:       http://localhost:8080" -ForegroundColor White 