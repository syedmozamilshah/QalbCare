import os
import logging
import requests
import hashlib
from typing import List, Dict, Any, Optional
from pathlib import Path
import json
import time
import re

try:
    import chromadb
    from chromadb.config import Settings
    CHROMADB_AVAILABLE = True
except ImportError:
    CHROMADB_AVAILABLE = False

try:
    from sentence_transformers import SentenceTransformer
    TRANSFORMERS_AVAILABLE = True
except ImportError:
    TRANSFORMERS_AVAILABLE = False

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleRAGDocumentManager:
    """Simple fallback document manager without heavy dependencies"""
    
    def __init__(self):
        # Simple in-memory storage
        self.documents = []
        self.document_count = 0
        
        # Initialize with sample content
        self._initialize_documents()
    
    def _initialize_documents(self):
        """Initialize with sample Islamic mental health content"""
        sample_content = [
            {
                "text": "In Islamic psychology, mental health is viewed holistically, considering the spiritual, emotional, and physical aspects of a person. The Quran mentions that hearts find rest in the remembrance of Allah (Quran 13:28). This principle forms the foundation of Islamic approaches to mental wellness.",
                "source": "Islamic Psychology Principles",
                "topic": "foundation",
                "emotion_relevance": ["anxious", "sad", "hopeless"]
            },
            {
                "text": "The story of Prophet Yusuf (peace be upon him) teaches us about resilience in the face of adversity. Despite being betrayed by his brothers, sold into slavery, and wrongly imprisoned, he maintained his faith and trust in Allah. His eventual triumph reminds us that Allah's plans are always for our ultimate good, even when we cannot see it.",
                "source": "Prophetic Stories for Mental Health",
                "topic": "resilience",
                "emotion_relevance": ["hopeless", "sad", "lonely", "overwhelmed"]
            },
            {
                "text": "Islamic Cognitive Behavioral Therapy (CBT) integrates traditional CBT techniques with Islamic teachings. It helps individuals identify negative thought patterns while using Islamic principles like tawakkul (trust in Allah), sabr (patience), and shukr (gratitude) as coping mechanisms.",
                "source": "Islamic CBT Manual",
                "topic": "therapy",
                "emotion_relevance": ["anxious", "guilty", "confused", "overwhelmed"]
            },
            {
                "text": "The Prophet Muhammad (peace be upon him) said: 'No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, not even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.' This hadith teaches us that suffering has spiritual purpose and can lead to purification.",
                "source": "Prophetic Teachings on Suffering",
                "topic": "meaning_of_suffering",
                "emotion_relevance": ["sad", "hopeless", "guilty", "overwhelmed"]
            },
            {
                "text": "The practice of dhikr (remembrance of Allah) has proven psychological benefits similar to mindfulness meditation. Regular recitation of 'La hawla wa la quwwata illa billah' (There is no power except with Allah) can reduce anxiety and increase feelings of peace and surrender.",
                "source": "Islamic Mindfulness Practices",
                "topic": "dhikr_therapy",
                "emotion_relevance": ["anxious", "overwhelmed", "tired"]
            },
            {
                "text": "Seeking forgiveness (istighfar) is both a spiritual practice and a psychological tool for healing from guilt and shame. The Quran assures us that Allah's mercy encompasses all things (Quran 7:156), and that sincere repentance leads to peace of heart.",
                "source": "Islamic Approaches to Guilt and Shame",
                "topic": "forgiveness",
                "emotion_relevance": ["guilty", "sad", "hopeless"]
            },
            {
                "text": "Community support (ummah) is essential for mental health in Islam. The Prophet said, 'The believers in their mutual kindness, compassion, and sympathy are just one body - when a limb suffers, the whole body responds to it with wakefulness and fever.' Isolation often worsens mental health conditions.",
                "source": "Islamic Community Mental Health",
                "topic": "community_support",
                "emotion_relevance": ["lonely", "sad", "overwhelmed"]
            },
            {
                "text": "The five daily prayers (salah) provide structure, mindfulness, and connection with the Divine. Research shows that regular prayer can reduce stress hormones, lower blood pressure, and improve overall mental well-being through its meditative and grounding effects.",
                "source": "Prayer and Mental Health",
                "topic": "prayer_therapy",
                "emotion_relevance": ["anxious", "overwhelmed", "tired", "confused"]
            }
        ]
        
        self.documents = sample_content
        self.document_count = len(sample_content)
        logger.info(f"Loaded {self.document_count} sample documents (simple mode)")
    
    def retrieve_relevant_documents(self, query: str, emotion: str = None, top_k: int = 3) -> List[Dict[str, Any]]:
        """Simple keyword-based document retrieval"""
        try:
            # Simple keyword matching
            query_words = set(query.lower().split())
            scored_docs = []
            
            for doc in self.documents:
                score = 0
                doc_words = set(doc["text"].lower().split())
                
                # Keyword overlap score
                score += len(query_words.intersection(doc_words)) * 2
                
                # Emotion relevance bonus
                if emotion and emotion in doc["emotion_relevance"]:
                    score += 10
                
                # Topic relevance
                if any(word in doc["text"].lower() for word in query_words):
                    score += 5
                
                if score > 0:
                    scored_docs.append((score, {
                        "content": doc["text"],
                        "source": doc["source"],
                        "topic": doc["topic"],
                        "distance": 1.0 - (score / 20.0)  # Convert to distance-like score
                    }))
            
            # Sort by score (higher is better) and return top_k
            scored_docs.sort(key=lambda x: x[0], reverse=True)
            result = [doc for score, doc in scored_docs[:top_k]]
            
            logger.info(f"Retrieved {len(result)} documents (simple mode)")
            return result
            
        except Exception as e:
            logger.error(f"Error in simple retrieval: {e}")
            return []
    
    def get_document_count(self) -> int:
        """Get document count"""
        return self.document_count
    
    def search_by_emotion(self, emotion: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search by emotion"""
        results = []
        for doc in self.documents:
            if emotion in doc["emotion_relevance"]:
                results.append({
                    "content": doc["text"],
                    "source": doc["source"],
                    "topic": doc["topic"]
                })
                if len(results) >= limit:
                    break
        return results
    
    def add_document(self, text: str, source: str, topic: str = "general", emotion_relevance: List[str] = None) -> bool:
        """Add document to simple storage"""
        try:
            doc = {
                "text": text,
                "source": source,
                "topic": topic,
                "emotion_relevance": emotion_relevance or []
            }
            self.documents.append(doc)
            self.document_count += 1
            return True
        except Exception as e:
            logger.error(f"Error adding document: {e}")
            return False
    
class RAGDocumentManager:
    """Manages documents, embeddings, and retrieval for Islamic mental health guidance"""
    
    def __init__(self):
        # Initialize fallback manager as None first
        self.fallback_manager = None
        self.use_fallback = False
        
        # Always start with fallback mode to avoid crashes
        if not CHROMADB_AVAILABLE or not TRANSFORMERS_AVAILABLE:
            logger.warning("ChromaDB or Transformers not available, using simple fallback")
            self.fallback_manager = SimpleRAGDocumentManager()
            self.use_fallback = True
            return
            
        # Try to initialize ChromaDB but fallback on any error
        try:
            # Initialize ChromaDB
            self.chroma_client = chromadb.PersistentClient(
                path="./data/chroma_db",
                settings=Settings(
                    anonymized_telemetry=False,
                    allow_reset=True
                )
            )
            
            # Get or create collection
            self.collection = self.chroma_client.get_or_create_collection(
                name="islamic_mental_health_docs",
                metadata={"description": "Islamic mental health and CBT resources"}
            )
            
            # Lazy loading for embedding model - don't load immediately
            self.embedding_model = None
            self.use_fallback = False
            
            logger.info("ChromaDB initialized successfully")
            
        except Exception as e:
            logger.error(f"ChromaDB initialization failed: {e}")
            logger.info("Falling back to simple document manager")
            self.fallback_manager = SimpleRAGDocumentManager()
            self.use_fallback = True
            return
        
        # Verified sources as specified
        self.trusted_sources = [
            {
                "name": "Islamic Integrated CBT Manual – Duke University",
                "url": "https://spiritualityandhealth.duke.edu/files/2021/11/IICBT_Client_Manual_WB.pdf",
                "type": "pdf"
            },
            {
                "name": "Faith in Mind: Islam's Role in Mental Health – Yaqeen Institute",
                "url": "https://app.yaqeen.io/read/paper/faith-in-mind-islams-role-in-mental-health",
                "type": "web"
            },
            {
                "name": "Islamic Spirituality and Mental Well‑Being – Yaqeen Institute",
                "url": "https://yaqeeninstitute.org/wp-content/uploads/2017/03/Islamic-Spirituality-and-Mental-Well-Being-revised.pdf",
                "type": "pdf"
            },
            {
                "name": "Perspectives on Islamic Psychology – Yaqeen Institute",
                "url": "https://yaqeeninstitute.org/read/paper/perspectives-on-islamic-psychology-healing-of-emotions-in-the-quran",
                "type": "web"
            },
            {
                "name": "Holistic Healing: Islam's Legacy of Mental Health – Yaqeen Institute",
                "url": "https://yaqeeninstitute.org/read/paper/holistic-healing-islams-legacy-of-mental-health",
                "type": "web"
            },
            {
                "name": "Naseeha Mental Health Resources",
                "url": "https://naseeha.org/resources/",
                "type": "web"
            },
            {
                "name": "Muslim Mental Health Digital Library",
                "url": "https://muslimmentalhealth.com/digital-library/",
                "type": "web"
            },
            {
                "name": "Islamic Oases From Daily Stress – About Islam",
                "url": "https://aboutislam.net/muslim-issues/science-muslim-issues/islamic-oases-daily-stress/",
                "type": "web"
            },
            {
                "name": "Overcome Your Anxiety the Islamic Way – About Islam",
                "url": "https://aboutislam.net/counseling/ask-the-counselor/mental-health/overcome-anxiety-islamic-way/",
                "type": "web"
            },
            {
                "name": "Coping with Stress & Anxiety Islamically – Islamic Dawah Center",
                "url": "https://islamidawahcenter.com/coping-with-stress-and-anxiety-islamically/",
                "type": "web"
            },
            {
                "name": "The Islamic Perspective on Mental Health – Islamic Dawah Center",
                "url": "https://islamidawahcenter.com/the-islamic-perspective-on-mental-health/",
                "type": "web"
            },
            {
                "name": "How to Manage Social Anxiety – About Islam",
                "url": "https://aboutislam.net/counseling/ask-the-counselor/mental-health/how-to-manage-your-social-anxiety/",
                "type": "web"
            },
            {
                "name": "Self-Help vs Psychotherapy – Islamic View – About Islam",
                "url": "https://aboutislam.net/counseling/ask-the-counselor/mental-health/self-help-methods-psychotherapy/",
                "type": "web"
            },
            {
                "name": "Islamic Oases Live Counseling Session – About Islam",
                "url": "https://aboutislam.net/live-session/islamic-counseling-on-mental-health-challenges/",
                "type": "web"
            },
            {
                "name": "Waswasa & OCD Counseling Session – About Islam",
                "url": "https://aboutislam.net/live-session/waswasa-obsessions-compulsions-counseling-session/",
                "type": "web"
            }
        ]
        
        # Don't initialize documents on startup - do it on first request
        self._documents_initialized = False
        logger.info("RAG system ready for lazy initialization")
    
    def _get_embedding_model(self, timeout_sec: int = 5):
        """Lazy load the embedding model with super lightweight approach"""
        if self.embedding_model is None:
            try:
                logger.info("Loading very lightweight sentence transformer model...")
                # Use the smallest, fastest model available
                import threading
                import time
                
                # Create a flag to track if model loaded
                model_loaded = [False]
                model_container = [None]
                
                def load_model():
                    try:
                        # Use the lightest, fastest model
                        model_container[0] = SentenceTransformer('paraphrase-MiniLM-L3-v2', device='cpu')
                        model_loaded[0] = True
                    except Exception as e:
                        logger.error(f"Model loading failed in thread: {e}")
                
                # Start loading in a separate thread
                thread = threading.Thread(target=load_model)
                thread.daemon = True
                thread.start()
                
                # Wait maximum timeout_sec seconds for model to load
                thread.join(timeout=timeout_sec)
                
                if model_loaded[0] and model_container[0] is not None:
                    self.embedding_model = model_container[0]
                    logger.info("Lightweight sentence transformer loaded successfully")
                else:
                    raise Exception("Model loading timed out or failed")
                    
            except Exception as e:
                logger.error(f"Failed to load sentence transformer: {e}")
                logger.info("Switching to fallback mode due to model loading timeout")
                if not hasattr(self, 'fallback_manager') or self.fallback_manager is None:
                    self.fallback_manager = SimpleRAGDocumentManager()
                self.use_fallback = True
                raise e
        return self.embedding_model
    
    def _initialize_documents(self):
        """Initialize the document store if it's empty"""
        try:
            # Check if collection has any documents
            if self.collection.count() == 0:
                logger.info("Document store is empty. Initializing with sample content...")
                self._load_sample_content()
            else:
                logger.info(f"Document store initialized with {self.collection.count()} documents")
        except Exception as e:
            logger.error(f"Error initializing documents: {e}")
            self._load_sample_content()
    
    def _load_sample_content(self):
        """Load sample Islamic mental health content for immediate functionality"""
        sample_content = [
            {
                "text": "In Islamic psychology, mental health is viewed holistically, considering the spiritual, emotional, and physical aspects of a person. The Quran mentions that hearts find rest in the remembrance of Allah (Quran 13:28). This principle forms the foundation of Islamic approaches to mental wellness.",
                "source": "Islamic Psychology Principles",
                "topic": "foundation",
                "emotion_relevance": ["anxious", "sad", "hopeless"]
            },
            {
                "text": "The story of Prophet Yusuf (peace be upon him) teaches us about resilience in the face of adversity. Despite being betrayed by his brothers, sold into slavery, and wrongly imprisoned, he maintained his faith and trust in Allah. His eventual triumph reminds us that Allah's plans are always for our ultimate good, even when we cannot see it.",
                "source": "Prophetic Stories for Mental Health",
                "topic": "resilience",
                "emotion_relevance": ["hopeless", "sad", "lonely", "overwhelmed"]
            },
            {
                "text": "Islamic Cognitive Behavioral Therapy (CBT) integrates traditional CBT techniques with Islamic teachings. It helps individuals identify negative thought patterns while using Islamic principles like tawakkul (trust in Allah), sabr (patience), and shukr (gratitude) as coping mechanisms.",
                "source": "Islamic CBT Manual",
                "topic": "therapy",
                "emotion_relevance": ["anxious", "guilty", "confused", "overwhelmed"]
            },
            {
                "text": "The Prophet Muhammad (peace be upon him) said: 'No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, not even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.' This hadith teaches us that suffering has spiritual purpose and can lead to purification.",
                "source": "Prophetic Teachings on Suffering",
                "topic": "meaning_of_suffering",
                "emotion_relevance": ["sad", "hopeless", "guilty", "overwhelmed"]
            },
            {
                "text": "The practice of dhikr (remembrance of Allah) has proven psychological benefits similar to mindfulness meditation. Regular recitation of 'La hawla wa la quwwata illa billah' (There is no power except with Allah) can reduce anxiety and increase feelings of peace and surrender.",
                "source": "Islamic Mindfulness Practices",
                "topic": "dhikr_therapy",
                "emotion_relevance": ["anxious", "overwhelmed", "tired"]
            },
            {
                "text": "Seeking forgiveness (istighfar) is both a spiritual practice and a psychological tool for healing from guilt and shame. The Quran assures us that Allah's mercy encompasses all things (Quran 7:156), and that sincere repentance leads to peace of heart.",
                "source": "Islamic Approaches to Guilt and Shame",
                "topic": "forgiveness",
                "emotion_relevance": ["guilty", "sad", "hopeless"]
            },
            {
                "text": "Community support (ummah) is essential for mental health in Islam. The Prophet said, 'The believers in their mutual kindness, compassion, and sympathy are just one body - when a limb suffers, the whole body responds to it with wakefulness and fever.' Isolation often worsens mental health conditions.",
                "source": "Islamic Community Mental Health",
                "topic": "community_support",
                "emotion_relevance": ["lonely", "sad", "overwhelmed"]
            },
            {
                "text": "The five daily prayers (salah) provide structure, mindfulness, and connection with the Divine. Research shows that regular prayer can reduce stress hormones, lower blood pressure, and improve overall mental well-being through its meditative and grounding effects.",
                "source": "Prayer and Mental Health",
                "topic": "prayer_therapy",
                "emotion_relevance": ["anxious", "overwhelmed", "tired", "confused"]
            },
            {
                "text": "1. Do wudu immediately 2. Change position: standing? sit down. Sitting? lie down 3. Say 'A'udhu billahi min ash-shaytani'r-rajim'",
                "source": "Islamic CBT Manual - Anger Management",
                "topic": "anger_cbt",
                "emotion_relevance": ["angry"]
            },
            {
                "text": "1. Breathe slowly while saying 'La hawla wa la quwwata illa billah' 2. Pray 2 rakats of istikhara 3. Write down fears and match each with a Quranic verse",
                "source": "Islamic CBT Manual - Anxiety Treatment",
                "topic": "anxiety_cbt",
                "emotion_relevance": ["anxious", "overwhelmed"]
            },
            {
                "text": "1. Use prayer times as daily structure 2. Write 3 things you're grateful for daily 3. Help others in your community",
                "source": "Islamic CBT Manual - Depression Treatment",
                "topic": "depression_cbt",
                "emotion_relevance": ["sad", "hopeless", "empty"]
            },
            {
                "text": "1. Do proper tawbah: admit, feel sorry, ask forgiveness, promise not to repeat 2. Say istighfar 100 times daily 3. Do good deeds to compensate",
                "source": "Islamic CBT Manual - Guilt Treatment",
                "topic": "guilt_cbt",
                "emotion_relevance": ["guilty", "hopeless"]
            },
            {
                "text": "1. Go to congregational prayers (especially Jummah) 2. Join dhikr circles or Islamic study groups 3. Volunteer at your local mosque",
                "source": "Islamic CBT Manual - Loneliness Treatment",
                "topic": "loneliness_cbt",
                "emotion_relevance": ["lonely", "empty"]
            },
            {
                "text": "1. Say 'Tafweez tu ilallah' (I give this to Allah) 2. Break big problems into small tasks and make dua before each 3. Take dhikr breaks - 5 minutes of 'Subhan Allah' every hour",
                "source": "Islamic CBT Manual - Stress Management",
                "topic": "stress_cbt",
                "emotion_relevance": ["overwhelmed", "tired", "anxious"]
            }
        ]
        
        for i, content in enumerate(sample_content):
            doc_id = f"sample_doc_{i+1}"
            
            # Generate embedding with chunking and error handling
            try:
                model = self._get_embedding_model(timeout_sec=15)  # Longer timeout for initialization
                
                # Chunk long text to avoid memory issues
                text = content["text"]
                if len(text) > 300:  # If text is long, chunk it
                    chunks = [text[i:i+300] for i in range(0, len(text), 270)]  # 30 char overlap
                    chunk_embeddings = []
                    for chunk in chunks:
                        if chunk.strip():  # Skip empty chunks
                            chunk_embeddings.append(model.encode(chunk))
                    
                    if chunk_embeddings:
                        # Average embeddings
                        import numpy as np
                        embedding = np.mean(chunk_embeddings, axis=0).tolist()
                    else:
                        embedding = model.encode(text[:300]).tolist()  # Fallback
                else:
                    embedding = model.encode(text).tolist()
                    
            except Exception as e:
                logger.error(f"Encoding failed for document {i+1}: {e}")
                continue  # Skip this document
            
            # Add to ChromaDB
            self.collection.add(
                ids=[doc_id],
                embeddings=[embedding],
                documents=[content["text"]],
                metadatas=[{
                    "source": content["source"],
                    "topic": content["topic"],
                    "emotion_relevance": ",".join(content["emotion_relevance"])
                }]
            )
        
        logger.info(f"Loaded {len(sample_content)} sample documents into ChromaDB")
    
    def _ensure_documents_initialized(self):
        """Ensure documents are initialized on first access"""
        if not self._documents_initialized:
            self._initialize_documents()
            self._documents_initialized = True
    
    def retrieve_relevant_documents(self, query: str, emotion: str = None, top_k: int = 3) -> List[Dict[str, Any]]:
        """Retrieve relevant documents for a given query and emotion"""
        # Delegate to fallback if needed
        if self.use_fallback:
            return self.fallback_manager.retrieve_relevant_documents(query, emotion, top_k)
            
        try:
            # Initialize documents if needed
            self._ensure_documents_initialized()
            
            # Generate query embedding
            model = self._get_embedding_model()
            query_embedding = model.encode(query).tolist()
            
            # Prepare where clause for emotion filtering
            where_clause = None
            if emotion and emotion != "neutral":
                # Use proper ChromaDB where clause syntax
                where_clause = {"emotion_relevance": {"$contains": emotion}}
            
            # Query ChromaDB
            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k,
                where=where_clause
            )
            
            # Format results
            documents = []
            if results["documents"] and results["documents"][0]:
                for i in range(len(results["documents"][0])):
                    doc = {
                        "content": results["documents"][0][i],
                        "source": results["metadatas"][0][i].get("source", "Unknown"),
                        "topic": results["metadatas"][0][i].get("topic", "general"),
                        "distance": results["distances"][0][i] if results.get("distances") else 0
                    }
                    documents.append(doc)
            
            logger.info(f"Retrieved {len(documents)} relevant documents for query: {query[:50]}...")
            return documents
            
        except Exception as e:
            logger.error(f"Error retrieving documents: {e}")
            # Switch to fallback on error
            if not hasattr(self, 'use_fallback') or not self.use_fallback:
                logger.info("Switching to fallback mode due to error")
                self.fallback_manager = SimpleRAGDocumentManager()
                self.use_fallback = True
                return self.fallback_manager.retrieve_relevant_documents(query, emotion, top_k)
            return []
    
    def add_document(self, text: str, source: str, topic: str = "general", emotion_relevance: List[str] = None) -> bool:
        """Add a new document to the knowledge base"""
        try:
            if emotion_relevance is None:
                emotion_relevance = []
                
            # Generate unique ID
            doc_id = hashlib.md5(f"{source}_{text[:100]}".encode()).hexdigest()
            
            # Generate embedding with error handling
            try:
                model = self._get_embedding_model()
                embedding = model.encode(text).tolist()
            except Exception as e:
                logger.error(f"Encoding failed: {e}")
                return False
            
            # Add to ChromaDB
            self.collection.add(
                ids=[doc_id],
                embeddings=[embedding],
                documents=[text],
                metadatas=[{
                    "source": source,
                    "topic": topic,
                    "emotion_relevance": ",".join(emotion_relevance)
                }]
            )
            
            logger.info(f"Added document from {source}")
            return True
            
        except Exception as e:
            logger.error(f"Error adding document: {e}")
            return False
    
    def get_document_count(self) -> int:
        """Get total number of documents in the knowledge base"""
        # Delegate to fallback if needed
        if self.use_fallback:
            return self.fallback_manager.get_document_count()
            
        try:
            return self.collection.count()
        except Exception as e:
            logger.error(f"Error getting document count: {e}")
            # Switch to fallback on error
            if not hasattr(self, 'use_fallback') or not self.use_fallback:
                logger.info("Switching to fallback mode due to error")
                self.fallback_manager = SimpleRAGDocumentManager()
                self.use_fallback = True
                return self.fallback_manager.get_document_count()
            return 0

    def search_by_emotion(self, emotion: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search documents specifically by emotion relevance"""
        # Delegate to fallback if needed
        if self.use_fallback:
            return self.fallback_manager.search_by_emotion(emotion, limit)
            
        try:
            # Use query instead of get for better compatibility
            results = self.collection.query(
                query_texts=[emotion],  # Use emotion as query text
                n_results=limit
                # Remove the where clause for now to avoid $contains issue
            )
            
            documents = []
            if results["documents"] and results["documents"][0]:
                for i in range(len(results["documents"][0])):
                    # Filter by emotion relevance manually
                    emotion_relevance = results["metadatas"][0][i].get("emotion_relevance", "")
                    if emotion in emotion_relevance:
                        doc = {
                            "content": results["documents"][0][i],
                            "source": results["metadatas"][0][i].get("source", "Unknown"),
                            "topic": results["metadatas"][0][i].get("topic", "general")
                        }
                        documents.append(doc)
            
            return documents
            
        except Exception as e:
            logger.error(f"Error searching by emotion: {e}")
            # Switch to fallback on error
            if not hasattr(self, 'use_fallback') or not self.use_fallback:
                logger.info("Switching to fallback mode due to error")
                self.fallback_manager = SimpleRAGDocumentManager()
                self.use_fallback = True
                return self.fallback_manager.search_by_emotion(emotion, limit)
            return []

# Global instance
rag_manager = RAGDocumentManager()
