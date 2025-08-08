@echo off
REM Auth Service Runner Script for Windows
REM This script builds the common module and runs the auth service in debug mode with dev profile

echo Building common module...
cd ..\common-module
IF ERRORLEVEL 1 (
    echo Failed to navigate to common module
    exit /b 1
)

..\..\maven\bin\mvn.cmd clean install
IF ERRORLEVEL 1 (
    echo Failed to build common module
    exit /b 1
)

echo Common module built successfully.
echo ==========================================

cd ..\auth-service
IF ERRORLEVEL 1 (
    echo Failed to navigate to auth-service module
    exit /b 1
)

echo Starting Auth Service in Debug Mode...
echo ==========================================

REM Check if port 8081 is already in use and kill the process
echo Checking for process on port 8081...
FOR /F "tokens=5" %%P IN ('netstat -aon ^| findstr ":8081" ^| findstr "LISTENING"') DO (
    IF "%%P" NEQ "0" (
        echo Port 8081 is in use by PID %%P. Stopping existing process...
        taskkill /F /PID %%P
        timeout /t 2 /nobreak > nul
    )
)

REM Check if debug port 5005 is already in use and kill the process
echo Checking for process on port 5005...
FOR /F "tokens=5" %%P IN ('netstat -aon ^| findstr ":5005" ^| findstr "LISTENING"') DO (
    IF "%%P" NEQ "0" (
        echo Debug port 5005 is in use by PID %%P. Stopping existing debug process...
        taskkill /F /PID %%P
        timeout /t 2 /nobreak > nul
    )
)

echo Ports cleared, starting auth service...

REM Run the auth service with debug mode and dev profile
..\..\maven\bin\mvn.cmd spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

echo Auth service stopped.
pause
