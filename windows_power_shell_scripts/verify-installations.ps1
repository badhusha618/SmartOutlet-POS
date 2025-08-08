# SmartOutlet POS - Installation Verification Script
Write-Host "Verifying SmartOutlet POS Prerequisites..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check Java
Write-Host "Checking Java..." -ForegroundColor Yellow
if (Test-Command "java") {
    try {
        $javaVersion = java -version 2>&1 | Select-String "version"
        Write-Host "✅ Java: $javaVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Java found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Java not found in PATH" -ForegroundColor Red
    Write-Host "   Download from: https://adoptium.net/" -ForegroundColor Cyan
}

# Check Node.js
Write-Host "Checking Node.js..." -ForegroundColor Yellow
if (Test-Command "node") {
    try {
        $nodeVersion = node --version
        Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Node.js found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Node.js not found in PATH" -ForegroundColor Red
    Write-Host "   Download from: https://nodejs.org/" -ForegroundColor Cyan
}

# Check npm
Write-Host "Checking npm..." -ForegroundColor Yellow
if (Test-Command "npm") {
    try {
        $npmVersion = npm --version
        Write-Host "✅ npm: $npmVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ npm found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ npm not found in PATH" -ForegroundColor Red
    Write-Host "   npm should be installed with Node.js" -ForegroundColor Cyan
}

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
if (Test-Command "docker") {
    try {
        $dockerVersion = docker --version
        Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker not found in PATH" -ForegroundColor Red
    Write-Host "   Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
}

# Check Docker Compose
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
if (Test-Command "docker-compose") {
    try {
        $composeVersion = docker-compose --version
        Write-Host "✅ Docker Compose: $composeVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker Compose found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker Compose not found in PATH" -ForegroundColor Red
    Write-Host "   Docker Compose should be installed with Docker Desktop" -ForegroundColor Cyan
}

# Check Maven (using local installation)
Write-Host "Checking Maven..." -ForegroundColor Yellow
if (Test-Command "mvn") {
    try {
        $mvnVersion = mvn --version | Select-String "Apache Maven"
        Write-Host "✅ Maven: $mvnVersion" -ForegroundColor Green
    } catch {
        Write-Host "❌ Maven found but version check failed" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Maven not found in PATH, but local installation available" -ForegroundColor Yellow
    if (Test-Path ".\maven\bin\mvn.cmd") {
        Write-Host "✅ Local Maven found at: .\maven\bin\mvn.cmd" -ForegroundColor Green
    } else {
        Write-Host "❌ Local Maven not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Installation Summary:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

$allInstalled = $true

if (-not (Test-Command "java")) { $allInstalled = $false }
if (-not (Test-Command "node")) { $allInstalled = $false }
if (-not (Test-Command "npm")) { $allInstalled = $false }
if (-not (Test-Command "docker")) { $allInstalled = $false }

if ($allInstalled) {
    Write-Host "🎉 All prerequisites are installed and ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Start Docker Desktop" -ForegroundColor White
    Write-Host "2. Run: ./start-all-services.sh" -ForegroundColor White
    Write-Host "3. Access the application at: http://localhost:3000" -ForegroundColor White
} else {
    Write-Host "⚠️  Some prerequisites are missing" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install the missing tools:" -ForegroundColor Cyan
    Write-Host "1. Java: https://adoptium.net/" -ForegroundColor Blue
    Write-Host "2. Node.js: https://nodejs.org/" -ForegroundColor Blue
    Write-Host "3. Docker: https://www.docker.com/products/docker-desktop/" -ForegroundColor Blue
    Write-Host ""
    Write-Host "After installation, restart your terminal and run this script again." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "For detailed installation instructions, see: MANUAL_INSTALLATION_GUIDE.md" -ForegroundColor Cyan 