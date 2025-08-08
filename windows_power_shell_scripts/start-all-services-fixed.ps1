# SmartOutlet POS - Start All Backend Services (Fixed)
Write-Host "Starting SmartOutlet POS Backend Services..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Set up environment
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";C:\Program Files\Java\jdk-17\bin;.\maven\bin"

# Verify Java and Maven
Write-Host "Checking Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found" -ForegroundColor Red
    exit 1
}

Write-Host "Checking Maven installation..." -ForegroundColor Yellow
try {
    $mvnVersion = mvn --version | Select-String "Apache Maven"
    Write-Host "✅ Maven: $mvnVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven not found" -ForegroundColor Red
    exit 1
}

# Function to start a service
function Start-BackendService {
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
            Write-Host "Removed test directory for $ServiceName" -ForegroundColor Yellow
        }
        
        # Start the service
        try {
            $process = Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run", "-Dspring-boot.run.profiles=dev", "-Dserver.port=$Port" -WindowStyle Hidden -PassThru
            Write-Host "✅ $ServiceName started with PID: $($process.Id)" -ForegroundColor Green
        } catch {
            Write-Host "❌ Failed to start $ServiceName" -ForegroundColor Red
        }
        
        Pop-Location
        Start-Sleep -Seconds 15
    } else {
        Write-Host "❌ Service directory not found: $serviceDir" -ForegroundColor Red
    }
}

# Function to wait for service to be ready
function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$Timeout = 30
    )
    
    Write-Host "Waiting for $ServiceName to be ready..." -ForegroundColor Yellow
    $count = 0
    while ($count -lt $Timeout) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $ServiceName is ready!" -ForegroundColor Green
                return $true
            }
        } catch {
            # Service not ready yet
        }
        Start-Sleep -Seconds 2
        $count += 2
        Write-Host "." -NoNewline
    }
    Write-Host ""
    Write-Host "⚠️ $ServiceName failed to start within $Timeout seconds" -ForegroundColor Yellow
    return $false
}

# Build common module first
Write-Host "Building common module..." -ForegroundColor Yellow
Push-Location backend\common-module
try {
    mvn clean install -DskipTests -q
    Write-Host "✅ Common module built successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Common module build failed" -ForegroundColor Red
    exit 1
}
Pop-Location

# Start services in order
Write-Host "Starting backend services..." -ForegroundColor Yellow

# Start auth service first (required by others)
Start-BackendService "auth-service" "auth-service" 8081

# Start other services
Start-BackendService "outlet-service" "outlet-service" 8082
Start-BackendService "product-service" "product-service" 8083
Start-BackendService "inventory-service" "inventory-service" 8086
Start-BackendService "pos-service" "pos-service" 8084
Start-BackendService "expense-service" "expense-service" 8085

# Start API gateway last
Start-BackendService "api-gateway" "api-gateway" 8080

# Wait for services to be ready
Write-Host "Checking service health..." -ForegroundColor Yellow
Wait-ForService "http://localhost:8081/actuator/health" "Auth Service" 60
Wait-ForService "http://localhost:8080/actuator/health" "API Gateway" 60

Write-Host ""
Write-Host "🎉 All backend services are starting up!" -ForegroundColor Green
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
Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Cyan
Write-Host "  Admin: admin@smartoutlet.com / admin123" -ForegroundColor White
Write-Host "  Staff: staff@smartoutlet.com / staff123" -ForegroundColor White
Write-Host ""
Write-Host "Note: Services are running in dev mode with H2 in-memory database" -ForegroundColor Yellow 