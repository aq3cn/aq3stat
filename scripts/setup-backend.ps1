# aq3stat Backend Setup Script

param(
    [string]$Env = "development",
    [string]$Port = "8080",
    [string]$DbPassword = "",
    [switch]$Help
)

if ($Help) {
    Write-Host @"
aq3stat Backend Setup Script

Usage: .\scripts\setup-backend.ps1 [Parameters]

Parameters:
  -Env <string>           Environment (development|production) [Default: development]
  -Port <string>          Server port [Default: 8080]
  -DbPassword <string>    Database password
  -Help                   Show help

Examples:
  .\scripts\setup-backend.ps1
  .\scripts\setup-backend.ps1 -Env production -DbPassword "mypass"
"@
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "Cyan" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log $Message "ERROR"
    exit 1
}

# Check Go installation
Write-Log "Checking Go installation..."
if (!(Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Error-Log "Go is not installed. Please install Go 1.18+ first."
}

$goVersion = & go version
Write-Log "Found: $goVersion" "SUCCESS"

# Set working directory
Set-Location $ProjectDir
Write-Log "Working directory: $ProjectDir"

# Download Go dependencies
Write-Log "Downloading Go dependencies..."
& go mod download
if ($LASTEXITCODE -ne 0) {
    Write-Error-Log "Failed to download Go dependencies"
}
Write-Log "Go dependencies downloaded successfully" "SUCCESS"

# Create environment configuration
Write-Log "Creating environment configuration..."
$envFile = Join-Path $ProjectDir "configs\.env"

# Ensure configs directory exists
$configsDir = Join-Path $ProjectDir "configs"
if (!(Test-Path $configsDir)) {
    New-Item -ItemType Directory -Path $configsDir -Force | Out-Null
}

# Generate JWT secret
$timestamp = [int][double]::Parse((Get-Date -UFormat %s))
$randomNum = Get-Random -Minimum 1000 -Maximum 9999
$jwtSecret = "aq3stat_${timestamp}_${randomNum}_secret_key"

$envContent = @"
# aq3stat Environment Configuration
ENV=$Env
SERVER_PORT=$Port
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=$DbPassword
DB_NAME=aq3stat
JWT_SECRET=$jwtSecret
JWT_EXPIRATION=24h
LOG_LEVEL=info
LOG_FILE=
CORS_ORIGINS=*
RATE_LIMIT=100
REDIS_ENABLED=false
MAIL_ENABLED=false
GEO_ENABLED=true
STATS_RETENTION_DAYS=365
REALTIME_STATS=true
GZIP_ENABLED=true
MONITORING_ENABLED=false
DEBUG=false
"@

$envContent | Out-File -FilePath $envFile -Encoding UTF8
Write-Log "Environment configuration created: $envFile" "SUCCESS"

# Build backend
Write-Log "Building backend application..."
$outputFile = if ($Env -eq "production") { "aq3stat-server.exe" } else { "aq3stat-server.exe" }
& go build -o $outputFile cmd\api\main.go
if ($LASTEXITCODE -ne 0) {
    Write-Error-Log "Failed to build backend application"
}
Write-Log "Backend application built successfully: $outputFile" "SUCCESS"

# Test build
Write-Log "Testing application..."
$testOutput = & ".\$outputFile" --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "Application test passed" "SUCCESS"
} else {
    Write-Log "Application test failed, but build completed" "WARN"
}

# Show completion info
Write-Host ""
Write-Log "=== Setup Completed Successfully ===" "SUCCESS"
Write-Host "Environment: $Env" -ForegroundColor Cyan
Write-Host "Port: $Port" -ForegroundColor Cyan
Write-Host "Executable: $outputFile" -ForegroundColor Cyan
Write-Host "Config file: $envFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Setup MySQL database and run migrations" -ForegroundColor White
Write-Host "2. Start the server: .\$outputFile" -ForegroundColor White
Write-Host "3. Access API at: http://localhost:$Port/api" -ForegroundColor White
Write-Host "4. Health check: http://localhost:$Port/api/health" -ForegroundColor White
Write-Host ""
Write-Host "Default admin account: admin / admin123" -ForegroundColor Green
Write-Host "Please change the default password after first login!" -ForegroundColor Red
