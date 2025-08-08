# SmartOutlet POS - Prerequisites Installation Script
# This script installs Java 21, Node.js, and Docker Desktop

Write-Host "Installing SmartOutlet POS Prerequisites..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check if winget is available
if (-not (Test-Command "winget")) {
    Write-Host "Winget is not available. Please install Windows Package Manager first." -ForegroundColor Red
    exit 1
}

Write-Host "Winget is available" -ForegroundColor Green

# Install Java 21
if (-not (Test-Command "java")) {
    Write-Host "Installing Java 21..." -ForegroundColor Yellow
    $javaResult = winget install Oracle.JDK.21 --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Java 21 installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to install Java 21" -ForegroundColor Red
        Write-Host "Alternative: Download from https://adoptium.net/" -ForegroundColor Cyan
    }
} else {
    Write-Host "Java is already installed" -ForegroundColor Green
}

# Install Node.js
if (-not (Test-Command "node")) {
    Write-Host "Installing Node.js..." -ForegroundColor Yellow
    $nodeResult = winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Node.js installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to install Node.js" -ForegroundColor Red
        Write-Host "Alternative: Download from https://nodejs.org/" -ForegroundColor Cyan
    }
} else {
    Write-Host "Node.js is already installed" -ForegroundColor Green
}

# Install Docker Desktop
if (-not (Test-Command "docker")) {
    Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow
    $dockerResult = winget install Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker Desktop installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Failed to install Docker Desktop" -ForegroundColor Red
        Write-Host "Alternative: Download from https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    }
} else {
    Write-Host "Docker is already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Refreshing environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check installations
Write-Host ""
Write-Host "Checking installations..." -ForegroundColor Yellow

if (Test-Command "java") {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "Java: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "Java not found in PATH" -ForegroundColor Red
}

if (Test-Command "node") {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "Node.js not found in PATH" -ForegroundColor Red
}

if (Test-Command "docker") {
    $dockerVersion = docker --version
    Write-Host "Docker: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "Docker not found in PATH" -ForegroundColor Red
}

Write-Host ""
Write-Host "Installation Summary:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if ((Test-Command "java") -and (Test-Command "node") -and (Test-Command "docker")) {
    Write-Host "All prerequisites installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run the SmartOutlet POS system:" -ForegroundColor Green
    Write-Host "   ./start-all-services.sh" -ForegroundColor Yellow
} else {
    Write-Host "Some installations may require a system restart." -ForegroundColor Yellow
    Write-Host "Please restart your terminal or computer and try again." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Manual installation links:" -ForegroundColor Cyan
    Write-Host "   Java: https://adoptium.net/" -ForegroundColor Blue
    Write-Host "   Node.js: https://nodejs.org/" -ForegroundColor Blue
    Write-Host "   Docker: https://www.docker.com/products/docker-desktop/" -ForegroundColor Blue
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "   1. Restart your terminal/computer if needed" -ForegroundColor White
Write-Host "   2. Start Docker Desktop" -ForegroundColor White
Write-Host "   3. Run: ./start-all-services.sh" -ForegroundColor White 