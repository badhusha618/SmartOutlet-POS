# Auth Service Runner Script (PowerShell)
# This script builds the common module and runs the auth service in debug mode with dev profile

Write-Host "🔧 Building common module..."
Set-Location ../common-module
if ($?) {
    mvn clean install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build common module"
        exit $LASTEXITCODE
    }
    Write-Host "✅ Common module built successfully."
} else {
    Write-Host "❌ Failed to navigate to common module"
    exit 1
}

Write-Host "=========================================="
Set-Location ../auth-service
if (-not $?) {
    Write-Host "❌ Failed to navigate to auth-service module"
    exit 1
}

Write-Host "🚀 Starting Auth Service in Debug Mode..."
Write-Host "=========================================="

# Check if port 8081 is in use
$port8081 = Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue
if ($port8081) {
    Write-Host "❌ Port 8081 is already in use!"
    Write-Host "   Stopping existing process..."
    $pid = (Get-Process | Where-Object { $_.Id -eq $port8081.OwningProcess }).Id
    Stop-Process -Id $pid -Force
    Start-Sleep -Seconds 2
}

# Check if debug port 5005 is in use
$port5005 = Get-NetTCPConnection -LocalPort 5005 -State Listen -ErrorAction SilentlyContinue
if ($port5005) {
    Write-Host "❌ Debug port 5005 is already in use!"
    Write-Host "   Stopping existing debug process..."
    $pid = (Get-Process | Where-Object { $_.Id -eq $port5005.OwningProcess }).Id
    Stop-Process -Id $pid -Force
    Start-Sleep -Seconds 2
}

Write-Host "✅ Ports cleared, starting auth service..."

# Run the auth service in debug mode with dev profile
mvn spring-boot:run `
    -Dspring-boot.run.profiles=dev `
    -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

Write-Host "🏁 Auth service stopped."
