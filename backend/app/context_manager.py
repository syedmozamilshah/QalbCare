import os
import json
import time
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

class AdvancedContextManager:
    """Advanced context manager for intelligent conversation tracking"""
    
    def __init__(self, data_dir: str = "data/user_context"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
        # In-memory cache for active sessions
        self.active_sessions = {}
        
        # Pattern recognition
        self.emotional_patterns = {
            "recurring_depression": ["sad", "hopeless", "empty", "tired"],
            "anxiety_spiral": ["anxious", "overwhelmed", "worried", "fearful"],
            "relationship_issues": ["lonely", "heartbroken", "betrayed", "abandoned"],
            "spiritual_crisis": ["confused", "lost", "distant", "questioning"],
            "guilt_cycle": ["guilty", "ashamed", "regretful", "unworthy"]
        }
        
        # Response variation tracking
        self.response_history = {}
        
    def get_user_file_path(self, user_id: str) -> Path:
        """Get file path for user's context data"""
        return self.data_dir / f"{user_id}.json"
    
    def load_user_context(self, user_id: str) -> Dict[str, Any]:
        """Load user context from file"""
        file_path = self.get_user_file_path(user_id)
        
        if file_path.exists():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Error loading user context: {e}")
                return self._create_default_context()
        
        return self._create_default_context()
    
    def save_user_context(self, user_id: str, context: Dict[str, Any]):
        """Save user context to file"""
        file_path = self.get_user_file_path(user_id)
        
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(context, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"Error saving user context: {e}")
    
    def _create_default_context(self) -> Dict[str, Any]:
        """Create default user context"""
        return {
            "name": "Friend",
            "created_at": time.time(),
            "last_seen": time.time(),
            "conversation_history": [],
            "emotional_history": [],
            "topic_patterns": {},
            "response_patterns": {},
            "therapeutic_progress": {
                "sessions_count": 0,
                "improvement_indicators": [],
                "recurring_issues": [],
                "breakthrough_moments": []
            },
            "preferences": {
                "language": "english",
                "tone_preference": "gentle",
                "story_preferences": [],
                "dua_preferences": []
            },
            "relationship_context": {
                "has_disclosed_haram": False,
                "relationship_stage": "unknown",
                "support_network": "unknown"
            },
            "spiritual_context": {
                "practice_level": "unknown",
                "spiritual_concerns": [],
                "growth_areas": []
            }
        }
    
    def update_conversation(self, user_id: str, message: str, emotion: str, response: str):
        """Update conversation history with intelligent analysis"""
        context = self.load_user_context(user_id)
        
        # Add to conversation history
        conversation_entry = {
            "timestamp": time.time(),
            "message": message,
            "emotion": emotion,
            "response_length": len(response),
            "topics_detected": self._extract_topics(message),
            "urgency_level": self._assess_urgency(message, emotion),
            "spiritual_themes": self._extract_spiritual_themes(message)
        }
        
        context["conversation_history"].append(conversation_entry)
        
        # Keep only last 20 conversations
        if len(context["conversation_history"]) > 20:
            context["conversation_history"] = context["conversation_history"][-20:]
        
        # Update emotional history
        self._update_emotional_patterns(context, emotion)
        
        # Update topic patterns
        self._update_topic_patterns(context, message)
        
        # Assess therapeutic progress
        self._assess_progress(context, message, emotion)
        
        # Update last seen
        context["last_seen"] = time.time()
        context["therapeutic_progress"]["sessions_count"] += 1
        
        # Save context
        self.save_user_context(user_id, context)
        
        return context
    
    def _extract_topics(self, message: str) -> List[str]:
        """Extract topics from message"""
        topics = []
        message_lower = message.lower()
        
        topic_keywords = {
            "family": ["family", "parents", "mother", "father", "siblings", "brother", "sister"],
            "work": ["work", "job", "career", "boss", "colleague", "office", "employment"],
            "education": ["school", "university", "studies", "exam", "student", "teacher"],
            "health": ["health", "sick", "illness", "doctor", "hospital", "medicine"],
            "marriage": ["marriage", "wedding", "spouse", "husband", "wife", "nikah"],
            "friendship": ["friend", "friendship", "friends", "social", "companion"],
            "worship": ["prayer", "salah", "quran", "mosque", "ramadan", "hajj", "zakat"],
            "personal_growth": ["growth", "change", "improvement", "progress", "development"],
            "crisis": ["crisis", "emergency", "urgent", "serious", "critical", "help"]
        }
        
        for topic, keywords in topic_keywords.items():
            if any(keyword in message_lower for keyword in keywords):
                topics.append(topic)
        
        return topics
    
    def _assess_urgency(self, message: str, emotion: str) -> str:
        """Assess urgency level of the message"""
        message_lower = message.lower()
        
        crisis_indicators = [
            "suicide", "kill myself", "end it all", "can't go on", "no point",
            "hurt myself", "self harm", "die", "death", "ending", "over"
        ]
        
        high_urgency = [
            "emergency", "urgent", "crisis", "desperate", "can't handle",
            "breaking down", "falling apart", "losing control"
        ]
        
        if any(indicator in message_lower for indicator in crisis_indicators):
            return "crisis"
        elif any(indicator in message_lower for indicator in high_urgency):
            return "high"
        elif emotion in ["hopeless", "overwhelmed", "desperate"]:
            return "medium"
        else:
            return "low"
    
    def _extract_spiritual_themes(self, message: str) -> List[str]:
        """Extract spiritual themes from message"""
        themes = []
        message_lower = message.lower()
        
        spiritual_keywords = {
            "faith_doubt": ["doubt", "faith", "believe", "trust", "questioning"],
            "sin_guilt": ["sin", "guilty", "wrong", "haram", "forgiveness"],
            "worship_practice": ["prayer", "quran", "mosque", "dua", "dhikr"],
            "allah_relationship": ["allah", "god", "lord", "creator", "divine"],
            "afterlife": ["jannah", "jahannam", "paradise", "afterlife", "death"],
            "purpose": ["purpose", "meaning", "why", "point", "reason"]
        }
        
        for theme, keywords in spiritual_keywords.items():
            if any(keyword in message_lower for keyword in keywords):
                themes.append(theme)
        
        return themes
    
    def _update_emotional_patterns(self, context: Dict, emotion: str):
        """Update emotional patterns analysis"""
        context["emotional_history"].append({
            "emotion": emotion,
            "timestamp": time.time()
        })
        
        # Keep only last 15 emotions
        if len(context["emotional_history"]) > 15:
            context["emotional_history"] = context["emotional_history"][-15:]
        
        # Analyze patterns
        recent_emotions = [e["emotion"] for e in context["emotional_history"][-5:]]
        
        # Check for recurring patterns
        for pattern_name, pattern_emotions in self.emotional_patterns.items():
            if sum(1 for e in recent_emotions if e in pattern_emotions) >= 3:
                if pattern_name not in context["therapeutic_progress"]["recurring_issues"]:
                    context["therapeutic_progress"]["recurring_issues"].append(pattern_name)
    
    def _update_topic_patterns(self, context: Dict, message: str):
        """Update topic patterns"""
        topics = self._extract_topics(message)
        
        for topic in topics:
            if topic not in context["topic_patterns"]:
                context["topic_patterns"][topic] = {
                    "count": 0,
                    "first_mentioned": time.time(),
                    "last_mentioned": time.time()
                }
            
            context["topic_patterns"][topic]["count"] += 1
            context["topic_patterns"][topic]["last_mentioned"] = time.time()
    
    def _assess_progress(self, context: Dict, message: str, emotion: str):
        """Assess therapeutic progress"""
        # Check for positive indicators
        positive_indicators = [
            "better", "improved", "feeling good", "grateful", "thankful",
            "peaceful", "calm", "hopeful", "stronger", "healing"
        ]
        
        if any(indicator in message.lower() for indicator in positive_indicators):
            context["therapeutic_progress"]["improvement_indicators"].append({
                "indicator": "positive_language",
                "timestamp": time.time(),
                "message_excerpt": message[:100]
            })
        
        # Check for breakthrough moments
        breakthrough_indicators = [
            "understand now", "realize", "clarity", "breakthrough", "insight",
            "makes sense", "eye opening", "perspective", "changed my mind"
        ]
        
        if any(indicator in message.lower() for indicator in breakthrough_indicators):
            context["therapeutic_progress"]["breakthrough_moments"].append({
                "timestamp": time.time(),
                "message_excerpt": message[:100]
            })
    
    def get_contextual_prompt_enhancement(self, user_id: str) -> str:
        """Get contextual information to enhance prompts"""
        context = self.load_user_context(user_id)
        
        # Build contextual enhancement
        enhancement = []
        
        # User background
        sessions_count = context["therapeutic_progress"]["sessions_count"]
        if sessions_count > 1:
            enhancement.append(f"This user has had {sessions_count} sessions with you.")
        
        # Recurring issues
        recurring_issues = context["therapeutic_progress"]["recurring_issues"]
        if recurring_issues:
            enhancement.append(f"Recurring emotional patterns: {', '.join(recurring_issues)}")
        
        # Recent emotional trend
        recent_emotions = [e["emotion"] for e in context["emotional_history"][-3:]]
        if recent_emotions:
            enhancement.append(f"Recent emotional states: {' → '.join(recent_emotions)}")
        
        # Main topics of concern
        top_topics = sorted(context["topic_patterns"].items(), 
                          key=lambda x: x[1]["count"], reverse=True)[:3]
        if top_topics:
            topic_names = [topic[0] for topic in top_topics]
            enhancement.append(f"Main areas of concern: {', '.join(topic_names)}")
        
        # Progress indicators
        if context["therapeutic_progress"]["improvement_indicators"]:
            enhancement.append("User has shown signs of improvement in recent sessions.")
        
        # Relationship context
        if context["relationship_context"]["has_disclosed_haram"]:
            enhancement.append("User has previously discussed haram relationship issues.")
        
        return "\n".join(enhancement) if enhancement else "New user with no prior context."
    
    def should_vary_response(self, user_id: str, emotion: str, response_type: str) -> bool:
        """Determine if response should be varied based on history"""
        context = self.load_user_context(user_id)
        
        # Check if we've used similar responses recently
        recent_responses = context.get("response_patterns", {})
        
        key = f"{emotion}_{response_type}"
        if key in recent_responses:
            last_used = recent_responses[key].get("last_used", 0)
            usage_count = recent_responses[key].get("count", 0)
            
            # If used recently or frequently, suggest variation
            if time.time() - last_used < 86400:  # 24 hours
                return True
            if usage_count > 2:  # Used more than twice
                return True
        
        return False
    
    def track_response_usage(self, user_id: str, emotion: str, response_type: str):
        """Track response usage for variation"""
        context = self.load_user_context(user_id)
        
        if "response_patterns" not in context:
            context["response_patterns"] = {}
        
        key = f"{emotion}_{response_type}"
        if key not in context["response_patterns"]:
            context["response_patterns"][key] = {"count": 0, "last_used": 0}
        
        context["response_patterns"][key]["count"] += 1
        context["response_patterns"][key]["last_used"] = time.time()
        
        self.save_user_context(user_id, context)

# Global instance
context_manager = AdvancedContextManager()
