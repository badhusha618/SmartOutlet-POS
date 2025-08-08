# Install Node.js for SmartOutlet POS Frontend
Write-Host "Installing Node.js for SmartOutlet POS Frontend..." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Download Node.js installer
$nodeVersion = "20.10.0"
$nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"
$installerPath = "$env:TEMP\nodejs-installer.msi"

Write-Host "Downloading Node.js v$nodeVersion..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath
    Write-Host "✅ Node.js installer downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download Node.js: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Installing Node.js..." -ForegroundColor Yellow
try {
    # Install Node.js silently
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host "✅ Node.js installed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Node.js installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Failed to install Node.js: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Refresh environment variables
Write-Host "Refreshing environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify installation
Write-Host "Verifying Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "✅ npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found in PATH. You may need to restart your terminal." -ForegroundColor Red
    Write-Host "💡 Please restart your terminal and try again." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎉 Node.js installation completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart your terminal" -ForegroundColor White
Write-Host "2. Navigate to the frontend directory" -ForegroundColor White
Write-Host "3. Run: npm install" -ForegroundColor White
Write-Host "4. Run: npm run dev" -ForegroundColor White 