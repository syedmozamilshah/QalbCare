#!/usr/bin/env python3
"""
Script to create text index for emotion filtering in Qdrant
"""

import os
import sys
import logging
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.append(str(backend_dir))

from qdrant_client import QdrantClient
from qdrant_client.http import models

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    """Create text index for emotion filtering"""
    print("🔧 Creating Text Index for Emotion Filtering")
    print("=" * 50)
    
    try:
        # Qdrant Cloud credentials
        QDRANT_CLUSTER_ID = "5a605d9d-3f4c-4582-a9c8-ca6b181dab19"
        QDRANT_API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2Nlc3MiOiJtIn0.Z61LzoC-0r55u6TOTNGDvV4z8NM8KUnZE35pSgoA-9g"
        QDRANT_URL = f"https://{QDRANT_CLUSTER_ID}.eu-west-2-0.aws.cloud.qdrant.io"
        
        # Initialize Qdrant client
        client = QdrantClient(
            url=QDRANT_URL,
            api_key=QDRANT_API_KEY,
            timeout=30
        )
        
        collection_name = "islamic_mental_health_docs"
        
        print("🔗 Connected to Qdrant")
        
        # Create text index for emotion_relevance field
        print("📄 Creating text index for emotion_relevance field...")
        
        client.create_payload_index(
            collection_name=collection_name,
            field_name="emotion_relevance",
            field_schema=models.TextIndexParams(
                type="text",
                tokenizer=models.TokenizerType.WORD,
                min_token_len=2,
                max_token_len=15,
                lowercase=True
            )
        )
        
        print("✅ Text index created successfully!")
        
        # Test the index
        print("🧪 Testing emotion search with index...")
        
        emotion_filter = models.Filter(
            must=[
                models.FieldCondition(
                    key="emotion_relevance",
                    match=models.MatchText(text="sad")
                )
            ]
        )
        
        results = client.scroll(
            collection_name=collection_name,
            scroll_filter=emotion_filter,
            limit=2,
            with_payload=True
        )
        
        print(f"📋 Found {len(results[0])} documents for 'sad' emotion with index")
        
        if results[0]:
            print("📖 Sample document:")
            print(f"   Content: {results[0][0].payload.get('content', '')[:100]}...")
            print(f"   Source: {results[0][0].payload.get('source', 'Unknown')}")
        
        print("\n🎉 Text index created and tested successfully!")
        
    except Exception as e:
        logger.error(f"❌ Failed to create index: {e}")
        print(f"❌ Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
