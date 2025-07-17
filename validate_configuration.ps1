#!/usr/bin/env pwsh

# QalbCare Configuration Validation Script
# This script validates all configuration files and dependencies

Write-Host "🔍 QalbCare Configuration Validation" -ForegroundColor Green
Write-Host "=" * 50

$ErrorCount = 0
$WarningCount = 0

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
    $script:WarningCount++
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    $script:ErrorCount++
}

function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Test project structure
Write-Host "`n🏗️  Validating Project Structure..." -ForegroundColor Cyan

if (Test-Path "backend") {
    Write-Success "Backend directory exists"
} else {
    Write-Error "Backend directory missing"
}

if (Test-Path "frontend") {
    Write-Success "Frontend directory exists"
} else {
    Write-Error "Frontend directory missing"
}

# Test backend configuration
Write-Host "`n🔧 Validating Backend Configuration..." -ForegroundColor Cyan

if (Test-Path "backend/requirements.txt") {
    Write-Success "Backend requirements.txt exists"
} else {
    Write-Error "Backend requirements.txt missing"
}

if (Test-Path "backend/.env") {
    Write-Success "Backend .env file exists"
    
    # Check for required environment variables
    $envContent = Get-Content "backend/.env" -Raw
    if ($envContent -match "GOOGLE_API_KEY=") {
        if ($envContent -match "GOOGLE_API_KEY=your_google_api_key_here") {
            Write-Warning "GOOGLE_API_KEY still has default value"
        } else {
            Write-Success "GOOGLE_API_KEY is configured"
        }
    } else {
        Write-Error "GOOGLE_API_KEY not found in .env"
    }
} else {
    Write-Error "Backend .env file missing"
}

if (Test-Path "backend/app/main.py") {
    Write-Success "Backend main.py exists"
} else {
    Write-Error "Backend main.py missing"
}

# Test frontend configuration
Write-Host "`n📱 Validating Frontend Configuration..." -ForegroundColor Cyan

if (Test-Path "frontend/pubspec.yaml") {
    Write-Success "Frontend pubspec.yaml exists"
} else {
    Write-Error "Frontend pubspec.yaml missing"
}

if (Test-Path "frontend/assets/.env") {
    Write-Success "Frontend .env file exists"
    
    # Check for required environment variables
    $envContent = Get-Content "frontend/assets/.env" -Raw
    if ($envContent -match "API_BASE_URL=") {
        Write-Success "API_BASE_URL is configured"
    } else {
        Write-Error "API_BASE_URL not found in .env"
    }
    
    if ($envContent -match "FIREBASE_PROJECT_ID=") {
        Write-Success "Firebase configuration found"
    } else {
        Write-Warning "Firebase configuration may be incomplete"
    }
} else {
    Write-Error "Frontend .env file missing"
}

if (Test-Path "frontend/lib/main.dart") {
    Write-Success "Frontend main.dart exists"
} else {
    Write-Error "Frontend main.dart missing"
}

# Test Android configuration
Write-Host "`n🤖 Validating Android Configuration..." -ForegroundColor Cyan

if (Test-Path "frontend/android/app/build.gradle.kts") {
    Write-Success "Android build.gradle.kts exists"
    
    # Check build configuration
    $buildContent = Get-Content "frontend/android/app/build.gradle.kts" -Raw
    if ($buildContent -match "compileSdk = 35") {
        Write-Success "compileSdk is set to 35"
    } else {
        Write-Warning "compileSdk may not be set correctly"
    }
    
    if ($buildContent -match "minSdk = 23") {
        Write-Success "minSdk is set to 23"
    } else {
        Write-Warning "minSdk may not be set correctly"
    }
} else {
    Write-Error "Android build.gradle.kts missing"
}

if (Test-Path "frontend/android/app/google-services.json") {
    Write-Success "Google Services configuration exists"
} else {
    Write-Warning "Google Services configuration missing (Firebase may not work)"
}

# Test development tools
Write-Host "`n🛠️  Validating Development Tools..." -ForegroundColor Cyan

if (Test-CommandExists "python") {
    try {
        $pythonVersion = python --version 2>&1
        Write-Success "Python is installed: $pythonVersion"
    } catch {
        Write-Warning "Python version check failed"
    }
} else {
    Write-Error "Python is not installed or not in PATH"
}

if (Test-CommandExists "flutter") {
    try {
        $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
        Write-Success "Flutter is installed: $flutterVersion"
    } catch {
        Write-Warning "Flutter version check failed"
    }
} else {
    Write-Error "Flutter is not installed or not in PATH"
}

if (Test-CommandExists "git") {
    try {
        $gitVersion = git --version 2>&1
        Write-Success "Git is installed: $gitVersion"
    } catch {
        Write-Warning "Git version check failed"
    }
} else {
    Write-Warning "Git is not installed or not in PATH"
}

# Test helper scripts
Write-Host "`n📜 Validating Helper Scripts..." -ForegroundColor Cyan

if (Test-Path "setup_project.ps1") {
    Write-Success "Setup script exists"
} else {
    Write-Warning "Setup script missing"
}

if (Test-Path "TROUBLESHOOTING.md") {
    Write-Success "Troubleshooting guide exists"
} else {
    Write-Warning "Troubleshooting guide missing"
}

if (Test-Path "frontend/switch_api_config.ps1") {
    Write-Success "API configuration script exists"
} else {
    Write-Warning "API configuration script missing"
}

if (Test-Path "frontend/test_api_connection.ps1") {
    Write-Success "API connection test script exists"
} else {
    Write-Warning "API connection test script missing"
}

# Summary
Write-Host "`n📊 Validation Summary" -ForegroundColor Green
Write-Host "=" * 30

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "🎉 All validations passed! Your project is ready to use." -ForegroundColor Green
} elseif ($ErrorCount -eq 0) {
    Write-Host "✅ No critical errors found. $WarningCount warnings to review." -ForegroundColor Yellow
} else {
    Write-Host "❌ $ErrorCount critical errors found. $WarningCount warnings to review." -ForegroundColor Red
}

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Fix any critical errors shown above" -ForegroundColor White
Write-Host "2. Set your Google API key in backend/.env" -ForegroundColor White
Write-Host "3. Configure Firebase in frontend/assets/.env" -ForegroundColor White
Write-Host "4. Start the backend: cd backend && python run_backend.py" -ForegroundColor White
Write-Host "5. Start the frontend: cd frontend && flutter run" -ForegroundColor White

Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
Write-Host "• README.md - Complete setup instructions" -ForegroundColor White
Write-Host "• TROUBLESHOOTING.md - Solutions to common issues" -ForegroundColor White
Write-Host "• setup_project.ps1 - Automated setup script" -ForegroundColor White

if ($ErrorCount -gt 0) {
    exit 1
} else {
    exit 0
}
