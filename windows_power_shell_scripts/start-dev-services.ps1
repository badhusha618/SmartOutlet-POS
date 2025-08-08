# SmartOutlet POS - Start Dev Services (Windows PowerShell Version)
Write-Host "Starting SmartOutlet POS Services for Development" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

# Set up environment
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";C:\Program Files\Java\jdk-17\bin;$env:TEMP\apache-maven-3.9.6\bin"

# Create logs directory
if (-not (Test-Path "backend\logs")) {
    New-Item -ItemType Directory -Path "backend\logs" -Force
}

# Function to start a service
function Start-DevService {
    param(
        [string]$ServiceName,
        [int]$ServicePort
    )
    
    Write-Host "Starting $ServiceName on port $ServicePort..." -ForegroundColor Yellow
    
    $serviceDir = "backend\$ServiceName"
    if (Test-Path $serviceDir) {
        Push-Location $serviceDir
        
        # Kill any existing process on the port
        try {
            $existingProcess = Get-NetTCPConnection -LocalPort $ServicePort -ErrorAction SilentlyContinue
            if ($existingProcess) {
                Stop-Process -Id $existingProcess.OwningProcess -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # No existing process
        }
        
        # Start the service
        try {
            $process = Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run", "-Dspring-boot.run.profiles=dev" -WindowStyle Hidden -PassThru
            $process.Id | Out-File -FilePath "..\logs\$ServiceName.pid" -Encoding UTF8
            Write-Host "$ServiceName started (PID: $($process.Id))" -ForegroundColor Green
        } catch {
            Write-Host "Failed to start $ServiceName" -ForegroundColor Red
        }
        
        Pop-Location
        Start-Sleep -Seconds 5
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
Start-DevService "auth-service" 8081
Start-DevService "outlet-service" 8082
Start-DevService "product-service" 8083
Start-DevService "inventory-service" 8086
Start-DevService "pos-service" 8084
Start-DevService "expense-service" 8085
Start-DevService "api-gateway" 8080

Write-Host ""
Write-Host "All services started successfully!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Auth Service:      http://localhost:8081/swagger-ui/index.html" -ForegroundColor White
Write-Host "  Outlet Service:    http://localhost:8082/swagger-ui/index.html" -ForegroundColor White
Write-Host "  Product Service:   http://localhost:8083/swagger-ui/index.html" -ForegroundColor White
Write-Host "  Inventory Service: http://localhost:8086/swagger-ui/index.html" -ForegroundColor White
Write-Host "  POS Service:       http://localhost:8084/swagger-ui/index.html" -ForegroundColor White
Write-Host "  Expense Service:   http://localhost:8085/swagger-ui/index.html" -ForegroundColor White
Write-Host "  API Gateway:       http://localhost:8080/swagger-ui/index.html" -ForegroundColor White
Write-Host ""
Write-Host "Health checks:" -ForegroundColor Cyan
Write-Host "  Auth: http://localhost:8081/actuator/health" -ForegroundColor White
Write-Host "  API Gateway: http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Logs are available in: backend/logs/" -ForegroundColor Yellow
Write-Host "To stop services: ./stop-dev-services.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Cyan
Write-Host "  Admin: admin@smartoutlet.com / admin123" -ForegroundColor White
Write-Host "  Staff: staff@smartoutlet.com / staff123" -ForegroundColor White 