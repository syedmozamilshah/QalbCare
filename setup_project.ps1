#!/usr/bin/env pwsh

# QalbCare Project Setup Script
# This script sets up the entire QalbCare project with proper configurations

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("full", "backend", "frontend", "android")]
    [string]$Setup = "full",
    
    [Parameter(Mandatory=$false)]
    [string]$GoogleApiKey = "",
    
    [Parameter(Mandatory=$false)]
    [string]$NetworkConfig = "device"  # Options: device, emulator, web
)

Write-Host "🕌 QalbCare Project Setup Script" -ForegroundColor Green
Write-Host "=" * 50

# Helper function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Function to setup backend
function Setup-Backend {
    Write-Host "`n🔧 Setting up Backend..." -ForegroundColor Yellow
    
    if (-not (Test-Path "backend")) {
        Write-Host "❌ Backend directory not found!" -ForegroundColor Red
        return
    }
    
    Set-Location "backend"
    
    # Check if Python is installed
    if (-not (Test-Command "python")) {
        Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Python 3.8+ from https://python.org" -ForegroundColor Yellow
        Set-Location ".."
        return
    }
    
    # Create virtual environment if it doesn't exist
    if (-not (Test-Path "venv")) {
        Write-Host "📦 Creating virtual environment..." -ForegroundColor Cyan
        python -m venv venv
    }
    
    # Activate virtual environment
    if (Test-Path "venv\Scripts\Activate.ps1") {
        Write-Host "🔄 Activating virtual environment..." -ForegroundColor Cyan
        & "venv\Scripts\Activate.ps1"
    }
    
    # Install dependencies
    Write-Host "📦 Installing Python dependencies..." -ForegroundColor Cyan
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    
    # Setup .env file
    if (-not (Test-Path ".env")) {
        Write-Host "📝 Creating .env file..." -ForegroundColor Cyan
        Copy-Item ".env.example" ".env"
        
        if ($GoogleApiKey) {
            Write-Host "🔑 Setting Google API Key..." -ForegroundColor Cyan
            $envContent = Get-Content ".env" -Raw
            $envContent = $envContent -replace "your_google_api_key_here", $GoogleApiKey
            Set-Content ".env" $envContent
        } else {
            Write-Host "⚠️  Please set your GOOGLE_API_KEY in backend/.env" -ForegroundColor Yellow
        }
    }
    
    # Test backend setup
    Write-Host "🧪 Testing backend setup..." -ForegroundColor Cyan
    try {
        $testResult = python -c "from app.main import app; print('Backend setup successful')"
        Write-Host "✅ Backend setup completed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Backend setup failed. Check the error messages above." -ForegroundColor Red
    }
    
    Set-Location ".."
}

# Function to setup frontend
function Setup-Frontend {
    Write-Host "`n🔧 Setting up Frontend..." -ForegroundColor Yellow
    
    if (-not (Test-Path "frontend")) {
        Write-Host "❌ Frontend directory not found!" -ForegroundColor Red
        return
    }
    
    Set-Location "frontend"
    
    # Check if Flutter is installed
    if (-not (Test-Command "flutter")) {
        Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
        Set-Location ".."
        return
    }
    
    # Flutter doctor
    Write-Host "🩺 Running Flutter doctor..." -ForegroundColor Cyan
    flutter doctor
    
    # Setup .env file
    if (-not (Test-Path "assets\.env")) {
        Write-Host "📝 Creating .env file..." -ForegroundColor Cyan
        Copy-Item "assets\.env.example" "assets\.env"
        
        # Configure network settings based on parameter
        $envContent = Get-Content "assets\.env" -Raw
        switch ($NetworkConfig) {
            "emulator" {
                $envContent = $envContent -replace "API_BASE_URL=.*", "API_BASE_URL=http://10.0.2.2:8000"
                Write-Host "📱 Configured for Android Emulator (10.0.2.2:8000)" -ForegroundColor Cyan
            }
            "device" {
                $envContent = $envContent -replace "API_BASE_URL=.*", "API_BASE_URL=http://192.168.2.2:8000"
                Write-Host "📱 Configured for Physical Device (192.168.2.2:8000)" -ForegroundColor Cyan
            }
            "web" {
                $envContent = $envContent -replace "API_BASE_URL=.*", "API_BASE_URL=http://localhost:8000"
                Write-Host "🌐 Configured for Flutter Web (localhost:8000)" -ForegroundColor Cyan
            }
        }
        Set-Content "assets\.env" $envContent
    }
    
    # Get Flutter packages
    Write-Host "📦 Getting Flutter packages..." -ForegroundColor Cyan
    flutter pub get
    
    # Clean and rebuild
    Write-Host "🧹 Cleaning Flutter build..." -ForegroundColor Cyan
    flutter clean
    flutter pub get
    
    Write-Host "✅ Frontend setup completed successfully!" -ForegroundColor Green
    
    Set-Location ".."
}

# Function to setup Android build
function Setup-Android {
    Write-Host "`n🔧 Setting up Android Build..." -ForegroundColor Yellow
    
    if (-not (Test-Path "frontend\android")) {
        Write-Host "❌ Android directory not found!" -ForegroundColor Red
        return
    }
    
    Set-Location "frontend"
    
    # Check Android SDK
    if (-not $env:ANDROID_HOME) {
        Write-Host "⚠️  ANDROID_HOME environment variable not set" -ForegroundColor Yellow
        Write-Host "Please set ANDROID_HOME to your Android SDK path" -ForegroundColor Yellow
    }
    
    # Validate build configuration
    Write-Host "🧪 Validating Android build configuration..." -ForegroundColor Cyan
    .\validate_build_config.ps1
    
    # Try to build
    Write-Host "🏗️  Attempting Android build..." -ForegroundColor Cyan
    try {
        flutter build apk --debug --verbose
        Write-Host "✅ Android build completed successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Android build failed. Check the error messages above." -ForegroundColor Red
        Write-Host "💡 Try running: flutter doctor --android-licenses" -ForegroundColor Yellow
    }
    
    Set-Location ".."
}

# Function to test the entire setup
function Test-Setup {
    Write-Host "`n🧪 Testing Complete Setup..." -ForegroundColor Yellow
    
    # Test backend
    Write-Host "🧪 Testing backend..." -ForegroundColor Cyan
    Set-Location "backend"
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend is running and healthy!" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Backend is not running. Start it with: python run_backend.py" -ForegroundColor Yellow
    }
    Set-Location ".."
    
    # Test frontend
    Write-Host "🧪 Testing frontend configuration..." -ForegroundColor Cyan
    Set-Location "frontend"
    .\test_api_connection.ps1
    Set-Location ".."
    
    Write-Host "✅ Setup testing completed!" -ForegroundColor Green
}

# Main execution
try {
    switch ($Setup) {
        "full" {
            Setup-Backend
            Setup-Frontend
            Setup-Android
            Test-Setup
        }
        "backend" {
            Setup-Backend
        }
        "frontend" {
            Setup-Frontend
        }
        "android" {
            Setup-Android
        }
    }
    
    Write-Host "`n🎉 QalbCare Setup Complete!" -ForegroundColor Green
    Write-Host "=" * 50
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Start the backend: cd backend && python run_backend.py" -ForegroundColor White
    Write-Host "2. Start the frontend: cd frontend && flutter run" -ForegroundColor White
    Write-Host "3. Or build Android APK: cd frontend && flutter build apk" -ForegroundColor White
    
} catch {
    Write-Host "`n❌ Setup failed with error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the error messages above and try again." -ForegroundColor Yellow
}
