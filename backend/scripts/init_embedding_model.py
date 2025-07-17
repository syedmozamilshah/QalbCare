#!/usr/bin/env python3
"""
Initialize the embedding model separately to avoid hanging during requests
"""
import sys
import os
import time
import logging
from pathlib import Path

# Add the app directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def initialize_model():
    """Initialize the sentence transformer model"""
    try:
        print("🔄 Initializing sentence transformer model...")
        print("This may take a few minutes on first run...")
        
        # Import sentence transformers
        from sentence_transformers import SentenceTransformer
        
        # Load the lightweight model - this will download it if not cached
        model = SentenceTransformer('paraphrase-MiniLM-L3-v2', device='cpu')
        
        # Test the model with a simple sentence
        test_sentence = "This is a test sentence"
        embedding = model.encode(test_sentence)
        
        print(f"✅ Model initialized successfully!")
        print(f"   Model name: all-MiniLM-L6-v2")
        print(f"   Embedding dimension: {len(embedding)}")
        print(f"   Device: CPU")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to initialize model: {e}")
        return False

def initialize_rag_documents():
    """Initialize RAG documents"""
    try:
        print("\n🔄 Initializing RAG documents...")
        
        # Import the RAG manager
        from app.rag_system import rag_manager
        
        # Check if using fallback
        if rag_manager.use_fallback:
            print("⚠️ Using fallback mode (simple document matching)")
            doc_count = rag_manager.get_document_count()
            print(f"✅ Fallback documents loaded: {doc_count}")
            return True
        
        # Try to initialize documents
        rag_manager._ensure_documents_initialized()
        doc_count = rag_manager.get_document_count()
        
        print(f"✅ RAG documents initialized: {doc_count}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to initialize RAG documents: {e}")
        print("   Will fall back to simple mode during runtime")
        return False

def main():
    print("🕌 QalbCare RAG Model Initialization")
    print("=" * 50)
    print("This script will pre-initialize the embedding model")
    print("to avoid hanging during the first API request.")
    print()
    
    # Step 1: Initialize embedding model
    model_success = initialize_model()
    
    # Step 2: Initialize RAG documents
    rag_success = initialize_rag_documents()
    
    # Summary
    print(f"\n{'='*50}")
    if model_success and rag_success:
        print("🎉 Initialization completed successfully!")
        print("Your RAG system is ready for fast responses.")
    elif model_success:
        print("⚠️ Model initialized, but RAG documents had issues.")
        print("The system will work in fallback mode.")
    else:
        print("❌ Initialization had issues.")
        print("The system will use fallback mode only.")
    
    print(f"\n🚀 You can now run: python start_server.py")
    print(f"{'='*50}")

if __name__ == "__main__":
    main()
