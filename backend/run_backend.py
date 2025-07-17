#!/usr/bin/env python3
"""
Simple script to run the QalbCare backend server
"""
import subprocess
import sys
import os

def main():
    print("🕌 QalbCare Backend Server")
    print("=" * 50)
    
    # Check if .env exists
    if not os.path.exists('.env'):
        print("❌ .env file not found!")
        print("Please create a .env file with your GOOGLE_API_KEY")
        return 1
    
    print("✅ Starting QalbCare Backend...")
    print("🌐 Server will be available at: http://localhost:8000")
    print("📚 API Documentation: http://localhost:8000/docs")
    print("🛑 Press Ctrl+C to stop the server\n")
    
    # Run the server
    try:
        cmd = [
            sys.executable, "-m", "uvicorn", 
            "app.main:app", 
            "--host", "0.0.0.0", 
            "--port", "8000",
            "--reload"
        ]
        
        subprocess.run(cmd, check=True)
        
    except KeyboardInterrupt:
        print("\n🛑 Shutting down server...")
        print("✅ Server stopped")
    except Exception as e:
        print(f"❌ Error starting server: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
