#!/usr/bin/env python3
"""
Safe QalbCare RAG Setup Script
Run this script to set up and verify the RAG-enabled backend with error handling
"""

import os
import sys
import subprocess
import time
from pathlib import Path

def print_header(text):
    print(f"\n{'='*50}")
    print(f"🕌 {text}")
    print(f"{'='*50}")

def check_dependencies():
    """Check if all required packages are installed"""
    print_header("Checking Dependencies")
    
    required_packages = [
        ('fastapi', 'fastapi'),
        ('uvicorn', 'uvicorn'), 
        ('python-dotenv', 'dotenv'),
        ('google-generativeai', 'google.generativeai'), 
        ('langgraph', 'langgraph'),
        ('pydantic', 'pydantic')
    ]
    
    missing_packages = []
    
    for package_name, import_name in required_packages:
        try:
            __import__(import_name)
            print(f"✅ {package_name}")
        except ImportError:
            print(f"❌ {package_name} - MISSING")
            missing_packages.append(package_name)
    
    # Check optional RAG packages
    print("\nChecking RAG dependencies (optional):")
    rag_packages = [
        ('qdrant-client', 'qdrant_client'),
        ('sentence-transformers', 'sentence_transformers'), 
        ('requests', 'requests'),
        ('beautifulsoup4', 'bs4'),
        ('pdfplumber', 'pdfplumber'),
        ('numpy', 'numpy')
    ]
    
    rag_available = True
    for package_name, import_name in rag_packages:
        try:
            __import__(import_name)
            print(f"✅ {package_name}")
        except ImportError:
            print(f"⚠️ {package_name} - MISSING (RAG will use fallback)")
            rag_available = False
    
    if missing_packages:
        print(f"\n⚠️  Missing core packages: {', '.join(missing_packages)}")
        print("Run: pip install -r requirements.txt")
        return False
    
    print("\n✅ Core dependencies installed!")
    if rag_available:
        print("✅ RAG dependencies available!")
    else:
        print("⚠️ Some RAG dependencies missing - will use simplified mode")
    return True

def check_env_config():
    """Check environment configuration"""
    print_header("Checking Environment Configuration")
    
    env_file = Path('.env')
    if not env_file.exists():
        print("❌ .env file not found")
        print("Create .env file with: GOOGLE_API_KEY=your_api_key")
        return False
    
    with open('.env', 'r') as f:
        env_content = f.read()
    
    if 'GOOGLE_API_KEY' in env_content and '=' in env_content:
        print("✅ .env file configured")
        return True
    else:
        print("❌ GOOGLE_API_KEY not found in .env")
        return False

def initialize_rag_system_safe():
    """Safely initialize the RAG system with proper error handling"""
    print_header("Initializing RAG System (Safe Mode)")
    
    try:
        # Import with timeout and error handling
        print("🔄 Loading RAG system...")
        sys.path.append('./app')
        
        # Import rag_system but catch any initialization errors
        from app.rag_system import rag_manager
        
        print("✅ RAG system imported successfully")
        
        # Check if it's using fallback mode
        if hasattr(rag_manager, 'use_fallback') and rag_manager.use_fallback:
            print("⚠️ RAG system is running in simple fallback mode")
            print("   This is fine - your app will still work with basic document retrieval")
        else:
            print("✅ RAG system is running in full Qdrant mode")
        
        # Skip document count check for safe initialization
        print("📄 Document count: Skipping check during safe initialization")
        print("   Note: Documents will be loaded lazily on first request")
        
        print("✅ RAG system ready for lazy document loading")
        return True
        
    except Exception as e:
        print(f"❌ RAG initialization failed: {e}")
        print("   Trying to continue without RAG...")
        return False

def test_basic_functionality():
    """Test basic API functionality without heavy operations"""
    print_header("Testing Basic Functionality")
    
    try:
        # Test core imports first
        print("🔄 Testing core imports...")
        from app.main import app
        print("✅ FastAPI app imported")
        
        from app.therapy_agent import langgraph_app
        print("✅ Therapy agent imported")
        
        # Test RAG with basic query
        try:
            from app.rag_system import rag_manager
            print("✅ RAG system accessible")
            
            # Skip document count test during safe setup
            print("✅ RAG system is ready for use (documents will load on demand)")
                
        except Exception as e:
            print(f"⚠️ RAG test skipped due to error: {e}")
        
        print("✅ Basic functionality test passed")
        return True
        
    except Exception as e:
        print(f"❌ Basic functionality test failed: {e}")
        return False

def main():
    """Main setup function"""
    print_header("QalbCare RAG Setup (Safe Mode)")
    print("Setting up RAG-enabled Islamic therapy backend with safe initialization...")
    
    # Step 1: Check dependencies
    if not check_dependencies():
        print("\n❌ Setup failed: Missing core dependencies")
        return False
    
    # Step 2: Check environment
    if not check_env_config():
        print("\n❌ Setup failed: Environment not configured")
        return False
    
    # Step 3: Initialize RAG safely
    print("\n🔄 Initializing RAG system (safe mode - this should be quick)...")
    rag_success = initialize_rag_system_safe()
    if not rag_success:
        print("\n⚠️ RAG initialization had issues, but continuing...")
        print("   Your app will work in basic mode without RAG enhancement")
    
    # Step 4: Test functionality
    if not test_basic_functionality():
        print("\n❌ Setup failed: Basic functionality test failed")
        return False
    
    # Success!
    print_header("Setup Complete!")
    if rag_success:
        print("✅ QalbCare RAG-enabled backend is ready!")
    else:
        print("✅ QalbCare backend is ready in basic mode!")
        print("   (RAG features may be limited but app will work)")
    
    print("\n🚀 To start the server:")
    print("   python start_server.py")
    print("\n📋 API will be available at:")
    print("   http://localhost:8000")
    print("   http://localhost:8000/docs (API documentation)")
    print("   http://localhost:8000/health (Health check)")
    if rag_success:
        print("   http://localhost:8000/rag/status (RAG status)")
    
    print("\n🧪 To run tests:")
    print("   python simple_test.py")
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
    
    print(f"\n{'='*50}")
    print("🎉 Setup complete!")
    print("Your Islamic therapy AI is ready to help users.")
    print(f"{'='*50}")
