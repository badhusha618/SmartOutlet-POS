# SmartOutlet POS - Windows Service Startup Script
Write-Host "Starting SmartOutlet POS System on Windows..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Set Java environment
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";C:\Program Files\Java\jdk-17\bin"

# Function to check if port is available
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", $Port)
        $connection.Close()
        return $true
    } catch {
        return $false
    }
}

# Function to wait for service to be ready
function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName,
        [int]$Timeout = 60
    )
    
    Write-Host "Waiting for $ServiceName to be ready..." -ForegroundColor Yellow
    $count = 0
    while ($count -lt $Timeout) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "$ServiceName is ready!" -ForegroundColor Green
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
    Write-Host "$ServiceName failed to start within $Timeout seconds" -ForegroundColor Red
    return $false
}

# Check if Docker is available
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Docker not available. Services will use H2 in-memory database." -ForegroundColor Yellow
}

# Start infrastructure services if Docker is available
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Starting infrastructure services..." -ForegroundColor Yellow
    
    # Start PostgreSQL
    Write-Host "Starting PostgreSQL..." -ForegroundColor Yellow
    try {
        docker run -d --name smartoutlet-postgres -e POSTGRES_DB=smartoutlet_auth -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=smartoutlet123 -p 5432:5432 postgres:15 2>$null
        Write-Host "✅ PostgreSQL started" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  PostgreSQL container already exists or failed to start" -ForegroundColor Yellow
    }
    
    # Start Redis
    Write-Host "Starting Redis..." -ForegroundColor Yellow
    try {
        docker run -d --name smartoutlet-redis -p 6379:6379 redis:7.2-alpine redis-server --requirepass smartoutlet123 2>$null
        Write-Host "✅ Redis started" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Redis container already exists or failed to start" -ForegroundColor Yellow
    }
} else {
    Write-Host "Using H2 in-memory database for development" -ForegroundColor Cyan
}

# Function to start a Spring Boot service
function Start-SpringBootService {
    param(
        [string]$ServiceName,
        [string]$ServicePath,
        [int]$Port,
        [string]$Profile = "test"
    )
    
    Write-Host "Starting $ServiceName on port $Port..." -ForegroundColor Yellow
    
    $serviceDir = "backend\$ServicePath"
    if (Test-Path $serviceDir) {
        Push-Location $serviceDir
        try {
            # Try to start using Maven if available
            if (Test-Path "..\..\maven\bin\mvn.cmd") {
                $mavenCmd = "..\..\maven\bin\mvn.cmd"
                $process = Start-Process -FilePath $mavenCmd -ArgumentList "spring-boot:run", "-Dspring-boot.run.profiles=$Profile", "-Dserver.port=$Port" -WindowStyle Hidden -PassThru
                Write-Host "✅ $ServiceName started with Maven (PID: $($process.Id))" -ForegroundColor Green
            } else {
                # Try to start using Java directly if JAR exists
                $jarPath = "target\$ServiceName-1.0.0.jar"
                if (Test-Path $jarPath) {
                    $process = Start-Process -FilePath "java" -ArgumentList "-jar", $jarPath, "--server.port=$Port", "--spring.profiles.active=$Profile" -WindowStyle Hidden -PassThru
                    Write-Host "✅ $ServiceName started with Java (PID: $($process.Id))" -ForegroundColor Green
                } else {
                    Write-Host "❌ No JAR file found for $ServiceName" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "Failed to start $ServiceName" -ForegroundColor Red
        }
        Pop-Location
    } else {
        Write-Host "❌ Service directory not found: $serviceDir" -ForegroundColor Red
    }
}

# Start backend services in order
Write-Host "Starting backend services..." -ForegroundColor Yellow

# Start auth service first (required by others)
Start-SpringBootService "auth-service" "auth-service" 8081 "test"
Start-Sleep -Seconds 10

# Start other services
Start-SpringBootService "outlet-service" "outlet-service" 8082 "test"
Start-SpringBootService "product-service" "product-service" 8083 "test"
Start-SpringBootService "inventory-service" "inventory-service" 8086 "test"
Start-SpringBootService "pos-service" "pos-service" 8084 "test"
Start-SpringBootService "expense-service" "expense-service" 8085 "test"
Start-Sleep -Seconds 5

# Start API gateway last
Start-SpringBootService "api-gateway" "api-gateway" 8080 "test"

# Wait for services to be ready
Write-Host "Checking service health..." -ForegroundColor Yellow
Wait-ForService "http://localhost:8081/actuator/health" "Auth Service" 30
Wait-ForService "http://localhost:8080/actuator/health" "API Gateway" 30

# Try to start frontend if Node.js is available
Write-Host "Checking frontend..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
    
    # Navigate to frontend and install dependencies
    Push-Location frontend
    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
        npm install
    }
    
    # Start frontend
    Write-Host "Starting frontend..." -ForegroundColor Yellow
    Start-Process -FilePath "npm" -ArgumentList "run", "dev" -WindowStyle Hidden
    Write-Host "✅ Frontend started" -ForegroundColor Green
    Pop-Location
} catch {
    Write-Host "⚠️  Node.js not available. Frontend will not start." -ForegroundColor Yellow
    Write-Host "   To install Node.js, visit: https://nodejs.org/" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎉 SmartOutlet POS System is starting up!" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Auth Service:      http://localhost:8081" -ForegroundColor White
Write-Host "  Outlet Service:    http://localhost:8082" -ForegroundColor White
Write-Host "  Product Service:   http://localhost:8083" -ForegroundColor White
Write-Host "  Inventory Service: http://localhost:8086" -ForegroundColor White
Write-Host "  POS Service:       http://localhost:8084" -ForegroundColor White
Write-Host "  Expense Service:   http://localhost:8085" -ForegroundColor White
Write-Host "  API Gateway:       http://localhost:8080" -ForegroundColor White
Write-Host "  Frontend:          http://localhost:3000" -ForegroundColor White
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