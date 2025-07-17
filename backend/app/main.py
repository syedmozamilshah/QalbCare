from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import asyncio
import logging
from concurrent.futures import ThreadPoolExecutor
import time
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import rate limiter
from app.rate_limiter import rate_limit_middleware

# Import with error handling
try:
    from app.therapy_agent import langgraph_app
    from app.rag_system import rag_manager
    RAG_AVAILABLE = True
except Exception as e:
    logging.error(f"Error importing RAG components: {e}")
    RAG_AVAILABLE = False
    langgraph_app = None
    rag_manager = None

app = FastAPI(
    title="QalbCare Islamic Therapy API",
    description="An Islamic counseling and spiritual guidance API",
    version="1.0.0",
    docs_url=None if os.getenv("ENVIRONMENT") == "production" else "/docs",
    redoc_url=None if os.getenv("ENVIRONMENT") == "production" else "/redoc"
)

# Configure allowed origins based on environment
allowed_origins = []
if os.getenv("ENVIRONMENT") == "production":
    # Add your production domains here
    production_origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
    allowed_origins = [origin.strip() for origin in production_origins if origin.strip()]
    # If no production origins are specified, use more restrictive defaults
    if not allowed_origins:
        allowed_origins = [
            "https://localhost:3000",
            "https://localhost:8000",
            "https://qalbcare.com",
            "https://www.qalbcare.com"
        ]
else:
    # Development origins - specific ports for better debugging
    allowed_origins = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:8000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:8080",
        "http://localhost:5173",  # Vite default
        "http://localhost:4173",  # Vite preview
        "http://localhost:5000",  # React dev server alternative
        "http://localhost:3002",  # Next.js alternative
        # Flutter/Mobile development origins
        "http://192.168.2.2:8000",  # Physical device access
        "http://10.0.2.2:8000",    # Android emulator access
    ]

print(f"🔧 CORS Configuration: {allowed_origins}")
print(f"🌍 Environment: {os.getenv('ENVIRONMENT', 'development')}")

# Add CORS middleware with comprehensive configuration
# For development, use wildcard to allow all origins (Flutter doesn't send proper Origin headers)
if os.getenv("ENVIRONMENT") != "production":
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Allow all origins in development
        allow_credentials=False,
        allow_methods=["GET", "POST", "OPTIONS", "HEAD", "PUT", "DELETE"],
        allow_headers=["*"],
        expose_headers=["X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"]
    )
else:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=False,
        allow_methods=["GET", "POST", "OPTIONS", "HEAD", "PUT", "DELETE"],
        allow_headers=["*"],
        expose_headers=["X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset"]
    )

# Add middleware to log requests for debugging
@app.middleware("http")
async def log_requests(request, call_next):
    start_time = time.time()
    client_ip = request.client.host
    
    # Check for forwarded headers
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        client_ip = forwarded_for.split(",")[0].strip()
    
    print(f"📱 Request: {request.method} {request.url.path} from {client_ip}")
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    print(f"⚡ Response: {response.status_code} ({process_time:.2f}s)")
    
    return response

# Add rate limiting middleware
app.middleware("http")(rate_limit_middleware)

class UserMessage(BaseModel):
    user_id: str
    name: str = None
    message: str

    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_123",
                "name": "Ahmad",
                "message": "I'm feeling very anxious about my future"
            }
        }

@app.get("/")
def root():
    return {"message": "QalbCare Islamic Therapy API is running", "status": "healthy"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "QalbCare API"}

@app.get("/rag/status")
def rag_status():
    """Get RAG system status and document count"""
    # Only allow in development mode
    if os.getenv("ENVIRONMENT") == "production":
        raise HTTPException(status_code=404, detail="Not found")
    
    try:
        doc_count = rag_manager.get_document_count()
        return {
            "status": "healthy",
            "document_count": doc_count,
            "rag_enabled": True
        }
    except Exception as e:
        logging.error(f"RAG status error: {e}")
        return {
            "status": "error",
            "rag_enabled": False
        }

@app.get("/rag/search/{emotion}")
def search_by_emotion(emotion: str, limit: int = 5):
    """Search documents by emotion for debugging purposes"""
    # Only allow in development mode
    if os.getenv("ENVIRONMENT") == "production":
        raise HTTPException(status_code=404, detail="Not found")
    
    try:
        documents = rag_manager.search_by_emotion(emotion, limit)
        return {
            "emotion": emotion,
            "document_count": len(documents),
            "documents": documents
        }
    except Exception as e:
        logging.error(f"Emotion search error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.options("/chat")
def chat_options():
    """Handle OPTIONS requests for CORS preflight"""
    return {"message": "OK"}

@app.post("/chat")
def chat(data: UserMessage):
    try:
        # Validate input
        if not data.message or not data.message.strip():
            raise HTTPException(status_code=400, detail="Message cannot be empty")
        
        if not data.user_id or not data.user_id.strip():
            raise HTTPException(status_code=400, detail="User ID is required")
        
        # Process the message
        state = {
            "user_id": data.user_id,
            "name": data.name,
            "message": data.message.strip()
        }
        
        result = langgraph_app.invoke(state)
        
        # Ensure we have a response
        if not result.get("response"):
            raise HTTPException(status_code=500, detail="Failed to generate response")
        
        return JSONResponse(
            content={
                "name": result.get("name", "Friend"),
                "emotion": result.get("emotion", "neutral"),
                "message": result["response"],
                "dua": result.get("dua"),
                "success": True
            },
            media_type="application/json; charset=utf-8"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail="An error occurred while processing your message. Please try again."
        )
