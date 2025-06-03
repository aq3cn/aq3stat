# aq3stat Website Statistics System PowerShell Deployment Script

param(
    [string]$Env = "development",
    [string]$Port = "8080",
    [string]$DbPassword = "",
    [switch]$SkipDeps,
    [switch]$SkipBuild,
    [switch]$SkipDb,
    [switch]$Help
)

# Show help information
if ($Help) {
    Write-Host @"
aq3stat Website Statistics System PowerShell Deployment Script

Usage: .\scripts\deploy.ps1 [Parameters]

Parameters:
  -Env <string>           Deployment environment (development|production) [Default: development]
  -Port <string>          Server port [Default: 8080]
  -DbPassword <string>    Database password
  -SkipDeps              Skip dependency installation
  -SkipBuild             Skip build process
  -SkipDb                Skip database initialization
  -Help                  Show help information

Examples:
  .\scripts\deploy.ps1 -Env development
  .\scripts\deploy.ps1 -Env production -DbPassword "mypassword"
"@
    exit 0
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# Log functions
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log $Message "ERROR"
    exit 1
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log $Message "SUCCESS"
}

function Write-Warn-Log {
    param([string]$Message)
    Write-Log $Message "WARN"
}

# Check system requirements
function Test-Requirements {
    Write-Log "Checking system requirements..."

    $requiredCommands = @("go", "node", "npm")

    foreach ($cmd in $requiredCommands) {
        if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
            Write-Error-Log "Missing required command: $cmd"
        }
    }

    Write-Success-Log "System requirements check completed"
}

# Install dependencies
function Install-Dependencies {
    if ($SkipDeps) {
        Write-Log "Skipping dependency installation"
        return
    }

    Write-Log "Installing dependencies..."

    Set-Location $ProjectDir

    # Install Go dependencies
    Write-Log "Installing Go dependencies..."
    & go mod download
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Go dependency installation failed"
    }

    # Install frontend dependencies
    Write-Log "Installing frontend dependencies..."
    Set-Location "web"
    & npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Frontend dependency installation failed"
    }
    Set-Location $ProjectDir

    Write-Success-Log "Dependencies installation completed"
}

# Configure environment variables
function Set-Environment {
    Write-Log "Configuring environment variables..."

    $envFile = Join-Path $ProjectDir "configs\.env"

    # Generate JWT secret
    $timestamp = [int][double]::Parse((Get-Date -UFormat %s))
    $randomNum = Get-Random -Minimum 1000 -Maximum 9999
    $jwtSecret = "aq3stat_${timestamp}_${randomNum}_secret_key"

    # Create .env file content
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
"@

    # Write to file
    $envContent | Out-File -FilePath $envFile -Encoding UTF8

    Write-Success-Log "Environment variables configuration completed"
}

# Initialize database
function Initialize-Database {
    if ($SkipDb) {
        Write-Log "Skipping database initialization"
        return
    }

    Write-Log "Initializing database..."

    # Check if MySQL is available
    if (Get-Command mysql -ErrorAction SilentlyContinue) {
        $initScript = Join-Path $ScriptDir "init_db.bat"
        if (Test-Path $initScript) {
            & $initScript -h localhost -P 3306 -u root -p $DbPassword -d aq3stat
        } else {
            Write-Warn-Log "Database initialization script not found, please initialize database manually"
        }
    } else {
        Write-Warn-Log "MySQL client not found, skipping database initialization"
    }

    Write-Success-Log "Database initialization completed"
}

# Build application
function Build-Application {
    if ($SkipBuild) {
        Write-Log "Skipping build process"
        return
    }

    Write-Log "Building application..."

    Set-Location $ProjectDir

    # Build backend
    Write-Log "Building backend..."
    & go build -o aq3stat-server.exe cmd\api\main.go
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Backend build failed"
    }

    # Build frontend
    Write-Log "Building frontend..."
    Set-Location "web"
    & npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Frontend build failed"
    }
    Set-Location $ProjectDir

    Write-Success-Log "Application build completed"
}

# Show deployment information
function Show-DeploymentInfo {
    Write-Log "Deployment Information:"
    Write-Host "  Environment: $Env" -ForegroundColor Cyan
    Write-Host "  Port: $Port" -ForegroundColor Cyan
    Write-Host "  Access URL: http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "  Default Admin Account: admin / admin123" -ForegroundColor Cyan
    Write-Warn-Log "Please change the default password immediately!"

    if ($Env -eq "development") {
        Write-Host ""
        Write-Host "Start development servers:" -ForegroundColor Yellow
        Write-Host "  Backend: go run cmd\api\main.go" -ForegroundColor Yellow
        Write-Host "  Frontend: cd web && npm run serve" -ForegroundColor Yellow
    }
}

# Main function
function Main {
    Write-Success-Log "Starting aq3stat Website Statistics System deployment..."
    Write-Log "Deployment environment: $Env"

    try {
        Test-Requirements
        Install-Dependencies
        Set-Environment
        Initialize-Database
        Build-Application
        Show-DeploymentInfo

        Write-Success-Log "aq3stat deployment completed successfully!"
    }
    catch {
        Write-Error-Log "Error occurred during deployment: $($_.Exception.Message)"
    }
}

# Execute main function
Main
