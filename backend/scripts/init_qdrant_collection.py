#!/usr/bin/env python3
"""
Script to manually initialize Qdrant collection for QalbCare
This creates the collection and loads initial documents
"""

import os
import sys
import logging
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.append(str(backend_dir))

from app.rag_system import RAGDocumentManager

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    """Initialize Qdrant collection and load documents"""
    print("🔧 Initializing Qdrant Collection for QalbCare")
    print("=" * 50)
    
    try:
        # Create RAG manager instance
        print("📦 Creating RAG manager...")
        rag_manager = RAGDocumentManager()
        
        if rag_manager.use_fallback:
            print("⚠️  Using fallback mode (not connected to Qdrant)")
            return
        
        print("🔗 Connected to Qdrant successfully")
        
        # Force initialization of documents
        print("📄 Initializing documents...")
        rag_manager._documents_initialized = False
        rag_manager._ensure_documents_initialized()
        
        # Get document count
        doc_count = rag_manager.get_document_count()
        print(f"✅ Collection initialized with {doc_count} documents")
        
        # Test emotion search
        print("🧪 Testing emotion search...")
        sad_docs = rag_manager.search_by_emotion("sad", limit=2)
        print(f"📋 Found {len(sad_docs)} documents for 'sad' emotion")
        
        if sad_docs:
            print("📖 Sample document:")
            print(f"   Content: {sad_docs[0]['content'][:100]}...")
            print(f"   Source: {sad_docs[0]['source']}")
        
        print("\n🎉 Qdrant collection initialized successfully!")
        
    except Exception as e:
        logger.error(f"❌ Failed to initialize collection: {e}")
        print(f"❌ Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
