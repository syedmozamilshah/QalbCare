import os
import logging
import random
import time
import json
import hashlib
from typing import TypedDict, Optional, Dict, List, Any
from datetime import datetime, timedelta

from dotenv import load_dotenv
import google.generativeai as genai
from langgraph.graph import StateGraph
from app.rag_system import rag_manager
from app.context_manager import context_manager

# --- LOGGING SETUP --- #
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- STATE TYPE --- #
class TherapyState(TypedDict, total=False):
    user_id: str
    name: Optional[str]
    message: str
    emotion: Optional[str]
    dua: Optional[str]
    response: Optional[str]

# --- ENV + MODEL CONFIG --- #
load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise EnvironmentError("GOOGLE_API_KEY is missing in your .env file.")

genai.configure(api_key=GOOGLE_API_KEY)

# Try different Gemini models in order of preference
MODELS_TO_TRY = [
    "models/gemini-2.5-flash",
    "models/gemini-2.0-flash", 
    "models/gemini-1.5-flash"
]

model = None
for model_name in MODELS_TO_TRY:
    try:
        test_model = genai.GenerativeModel(model_name)
        # Test the model with a simple query to verify it works
        test_response = test_model.generate_content("Hello")
        model = test_model
        logger.info(f"Successfully initialized {model_name}")
        break
    except Exception as e:
        logger.warning(f"Failed to initialize {model_name}: {e}")
        continue

if model is None:
    raise EnvironmentError("None of the Gemini models could be initialized")

# --- MEMORY STATE --- #
memory = {}

# --- LANGUAGE DETECTION (Conservative) --- #
def detect_language(text: str) -> str:
    """Conservative language detection - defaults to English for safety"""
    text = text.strip().lower()
    
    # First check for clear English indicators - if found, it's definitely English
    english_indicators = [
        "i am", "i'm", "i feel", "i'm feeling", "feeling", "my", "me", "you", "the", "and", "or", "but", "with", "have", "has", "do", "does", "can", "will", "would", "should", "could", "to", "from", "in", "on", "at", "for", "about", "very", "really", "so", "much", "more", "most", "some", "any", "all", "no", "not", "what", "how", "why", "when", "where", "who", "which", "that", "this", "these", "those", "am", "is", "are", "was", "were", "been", "being", "sad", "happy", "angry", "anxious", "depressed", "worried", "scared", "lonely", "tired", "upset", "hurt", "pain", "help", "need", "want", "like", "love", "hate", "good", "bad", "better", "worse", "best", "worst", "hello", "hi", "hey", "thanks", "thank", "please", "sorry", "excuse", "today", "tomorrow", "yesterday", "now", "then", "here", "there", "always", "never", "sometimes", "usually", "often", "maybe", "perhaps", "probably", "definitely", "certainly", "absolutely", "exactly", "only", "just", "still", "already", "yet", "again", "back", "away", "up", "down", "over", "under", "through", "around", "between", "among", "during", "before", "after", "since", "until", "while", "although", "because", "if", "unless", "whether", "either", "neither", "both", "each", "every", "many", "few", "little", "enough", "too", "quite", "rather", "pretty", "fairly", "extremely", "incredibly", "amazingly", "surprisingly", "unfortunately", "hopefully", "actually", "basically", "generally", "specifically", "particularly", "especially", "obviously", "clearly", "apparently", "probably", "possibly", "certainly", "definitely", "absolutely", "completely", "totally", "fully", "partially", "slightly", "somewhat", "quite", "rather", "pretty", "fairly", "really", "very", "extremely", "incredibly", "amazingly", "surprisingly", "unfortunately", "hopefully", "actually", "basically", "generally", "specifically", "particularly", "especially", "obviously", "clearly", "apparently"
    ]
    
    # Check if text contains clear English indicators
    for indicator in english_indicators:
        if indicator in text:
            return "english"
    
    # Only very clear Roman Urdu indicators (must be complete words)
    clear_urdu_words = ["mein", "hun", "hai", "kya", "nahi", "bohat", "kaise", "theek", "accha", "bura", "kaun", "kahan", "kab", "kyun", "kuch", "sab", "yeh", "woh", "aur", "lekin", "phir", "abhi", "kal", "raat", "din", "ghar", "dost", "dil", "mohabbat", "khushi", "gham", "pareshani", "masla", "madad", "chahiye", "hoga", "tha", "tha", "thi", "thay", "main", "mera", "mere", "meri", "tumhara", "tumhare", "tumhari", "uska", "uske", "uski", "humara", "humare", "humari"]
    
    # Split into words and check for complete word matches
    words = text.split()
    urdu_count = sum(1 for word in words if word in clear_urdu_words)
    
    # Only use Roman Urdu for very clear cases with multiple Urdu words
    if urdu_count >= 2 and len(words) <= 10:  # At least 2 clear Urdu words
        return "roman_urdu"
    
    # Default to English for everything else (much safer)
    return "english"

# --- DYNAMIC TONE GENERATOR --- #
def generate_prompt_flavor():
    moods = ["gentle", "hopeful", "tender", "comforting", "reassuring", "sincere", "soft-spoken"]
    metaphors = [
        "like sunrise breaking through clouds",
        "like rain falling gently on dry land",
        "like a friend sitting silently beside you",
        "like warm hands around a cold heart",
        "like whispers of hope in a storm"
    ]
    emotion_frame = [
        "Speak as someone who has felt this pain too.",
        "Talk as if you're wrapping the person in a warm blanket of peace.",
        "Speak to their heart as a soul who cares deeply.",
        "Use words that feel like a calm sea after waves of distress."
    ]
    return f"{random.choice(moods).capitalize()} tone, {random.choice(metaphors)}, {random.choice(emotion_frame)}"


# --- FALLBACK DUAS --- #
FALLBACK_DUAS = [
    {
        "arabic": "رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ",
        "translation": "My Lord, indeed I am in need of whatever good You would send down to me."
    },
    {
        "arabic": "اللّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالجَنَّةَ وَأَعُوذُ بِكَ مِنْ سَخَطِكَ وَالنَّارِ",
        "translation": "O Allah, I ask You for Your pleasure and Paradise, and I seek refuge in You from Your anger and the Fire."
    },
    {
        "arabic": "اللّهُمَّ لا تَجْعَلْ مُصِيبَتَنَا فِي دِينِنَا",
        "translation": "O Allah, do not make our affliction in our religion."
    },
    {
        "arabic": "اللّهُمَّ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
        "translation": "O Allah, make my heart steadfast upon Your religion."
    },
    {
        "arabic": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
        "translation": "Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good, and protect us from the punishment of the Fire."
    }
]

# --- ISLAMIC QUESTION DETECTION --- #
def detect_islamic_question(text: str) -> bool:
    """Detect if message contains Islamic questions that should be redirected"""
    text = text.lower().strip()
    
    islamic_question_patterns = [
        "first islamic war", "first war", "islamic war", "battle of", "ghazwa", "expedition",
        "which was the first islamic war", "what was the first islamic war", "first battle",
        "wine permissible", "wine allowed", "alcohol permissible", "alcohol allowed", "drinking allowed",
        "is wine permissible", "is alcohol permissible", "is drinking allowed",
        "is music haram", "music permissible", "music allowed", "singing allowed",
        "is dancing haram", "dancing permissible", "dancing allowed",
        "five pillars", "pillars of islam", "how to pray", "how to perform salah",
        "zakat calculation", "how much zakat", "zakat amount",
        "hajj procedure", "how to perform hajj", "hajj steps",
        "islamic months", "hijri calendar", "islamic calendar", "islamic date",
        "prophets name", "names of prophets", "25 prophets",
        "quran verses", "surah", "ayah", "verses about",
        "hadith about", "prophet said", "rasool said",
        "islamic history", "caliphate", "companions", "sahaba",
        "fiqh", "islamic law", "shariah", "halal haram",
        "tafseer", "quran interpretation", "meaning of verse",
        "islamic documentary", "recommend islamic", "suggest islamic",
        "which was the first", "what was the first", "first islamic"
    ]
    
    return any(pattern in text for pattern in islamic_question_patterns)

# --- GREETING DETECTION --- #
def is_greeting_or_small_talk(text: str) -> bool:
    """Detect if message is just greeting or small talk"""
    text = text.strip().lower()
    
    # First check for Islamic questions - these are NOT greetings even if they contain greeting words
    if detect_islamic_question(text):
        return False
    
    # Check for emotional distress indicators - these are NOT greetings
    emotional_indicators = [
        "depressed", "depression", "sad", "sadness", "anxious", "anxiety", "worried", "worry",
        "scared", "fear", "angry", "frustrated", "upset", "hurt", "pain", "suffering",
        "lonely", "alone", "hopeless", "helpless", "lost", "confused", "overwhelmed",
        "tired", "exhausted", "guilty", "shame", "regret", "suicidal", "die", "death",
        "cry", "crying", "tears", "broken", "empty", "numb", "stressed", "stress",
        "feeling", "feel", "emotion", "mood", "mental", "psychological",
        "pointless", "meaningless", "useless", "worthless", "don't get what i want",
        "nothing works", "can't do anything", "everything seems", "nothing matters",
        "what's the point", "no point", "give up", "can't take it", "fed up",
        "disappointed", "devastated", "heartbroken", "miserable", "desperate",
        "struggling", "can't cope", "falling apart", "breaking down", "can't handle",
        "trouble", "problem", "issue", "difficult", "hard time", "tough", "rough",
        "failed", "failure", "losing", "lost everything", "ruined", "destroyed",
        "hate myself", "hate my life", "wish i was", "wish i could", "if only",
        "unlucky", "cursed", "doomed", "fate", "destiny", "why me", "unfair"
    ]
    
    # If it contains emotional indicators, it's NOT a greeting
    for indicator in emotional_indicators:
        if indicator in text:
            return False
    
    greeting_patterns = [
        "hello", "hi", "hey", "salam", "assalam", "assalamu alaikum", "wa alaikum",
        "good morning", "good afternoon", "good evening", "good night",
        "how are you", "how's it going", "what's up", "sup", "hows you",
        "tell me about yourself", "who are you", "what do you do", "what can you do",
        "what's my name", "do you know my name", "remember my name",
        "nice to meet you", "pleased to meet", "introduction",
        "thanks", "thank you", "appreciate", "grateful", "shukran",
        "bye", "goodbye", "see you", "take care", "allah hafiz",
        "kya haal", "kaise ho", "kya kar rahe", "theek ho", "kaisa hai",
        "who are you btw", "what's my name", "how are you boss", "introduce yourself",
        "who built you", "who created you", "who developed you", "who made you",
        "your creator", "your developer", "your maker", "your founder"
    ]
    
    # Check if it's a message with greeting patterns (excluding Islamic questions)
    if len(text.split()) <= 10:  # Increased to catch complex greetings
        for pattern in greeting_patterns:
            if pattern in text:
                return True
    
    # Check for pure greetings (very short)
    if len(text.split()) <= 3 and any(pattern in text for pattern in greeting_patterns[:10]):
        return True
        
    return False

# --- REFERENCE DICTIONARIES (for AI guidance, not static matching) --- #
GREETING_EXAMPLES = [
    "hello", "hi", "hey", "salam", "assalam", "assalamu alaikum", "wa alaikum",
    "good morning", "good afternoon", "good evening", "good night",
    "how are you", "how's it going", "what's up", "sup", "hows you",
    "tell me about yourself", "who are you", "what do you do", "what can you do",
    "what's my name", "do you know my name", "remember my name",
    "nice to meet you", "pleased to meet", "introduction",
    "thanks", "thank you", "appreciate", "grateful", "shukran",
    "bye", "goodbye", "see you", "take care", "allah hafiz",
    "kya haal", "kaise ho", "kya kar rahe", "theek ho", "kaisa hai",
    "who are you btw", "what's my name", "how are you boss", "introduce yourself",
    "who built you", "who created you", "who developed you", "who made you",
    "your creator", "your developer", "your maker", "your founder"
]

EMOTIONAL_DISTRESS_EXAMPLES = [
    "depressed", "depression", "sad", "sadness", "anxious", "anxiety", "worried", "worry",
    "scared", "fear", "angry", "frustrated", "upset", "hurt", "pain", "suffering",
    "lonely", "alone", "hopeless", "helpless", "lost", "confused", "overwhelmed",
    "tired", "exhausted", "guilty", "shame", "regret", "suicidal", "die", "death",
    "cry", "crying", "tears", "broken", "empty", "numb", "stressed", "stress",
    "feeling", "feel", "emotion", "mood", "mental", "psychological",
    "pointless", "meaningless", "useless", "worthless", "don't get what i want",
    "nothing works", "can't do anything", "everything seems", "nothing matters",
    "what's the point", "no point", "give up", "can't take it", "fed up",
    "disappointed", "devastated", "heartbroken", "miserable", "desperate",
    "struggling", "can't cope", "falling apart", "breaking down", "can't handle",
    "trouble", "problem", "issue", "difficult", "hard time", "tough", "rough",
    "failed", "failure", "losing", "lost everything", "ruined", "destroyed",
    "hate myself", "hate my life", "wish i was", "wish i could", "if only",
    "unlucky", "cursed", "doomed", "fate", "destiny", "why me", "unfair"
]

ISLAMIC_QUESTION_EXAMPLES = [
    "first islamic war", "first war", "islamic war", "battle of", "ghazwa", "expedition",
    "which was the first islamic war", "what was the first islamic war", "first battle",
    "wine permissible", "wine allowed", "alcohol permissible", "alcohol allowed", "drinking allowed",
    "is wine permissible", "is alcohol permissible", "is drinking allowed",
    "is music haram", "music permissible", "music allowed", "singing allowed",
    "is dancing haram", "dancing permissible", "dancing allowed",
    "five pillars", "pillars of islam", "how to pray", "how to perform salah",
    "zakat calculation", "how much zakat", "zakat amount",
    "hajj procedure", "how to perform hajj", "hajj steps",
    "islamic months", "hijri calendar", "islamic calendar", "islamic date",
    "prophets name", "names of prophets", "25 prophets",
    "quran verses", "surah", "ayah", "verses about",
    "hadith about", "prophet said", "rasool said",
    "islamic history", "caliphate", "companions", "sahaba",
    "fiqh", "islamic law", "shariah", "halal haram",
    "tafseer", "quran interpretation", "meaning of verse",
    "islamic documentary", "recommend islamic", "suggest islamic",
    "which was the first", "what was the first", "first islamic"
]

HARAM_CONTENT_EXAMPLES = {
    "relationship": [
        "girlfriend", "boyfriend", "dating", "date", "crush", "love someone",
        "in love with", "attracted to", "relationship with", "romantic", "romance",
        "physical relationship", "intimate", "intimacy", "sexual", "sex",
        "kissing", "hugging", "touching", "alone with", "haram relationship",
        "girl left me", "boy left me", "girl broke up", "boy broke up",
        "my girlfriend", "my boyfriend", "broke up with me", "left me",
        "want her back", "want him back", "get her back", "get him back",
        "missing her", "missing him", "love her", "love him"
    ],
    "general": [
        "alcohol", "drinking", "drunk", "wine", "beer", "party", "club",
        "gambling", "bet", "lottery", "drugs", "smoking", "cigarette",
        "music", "listen to music", "songs", "singing", "dance", "dancing"
    ]
}

# --- AI-BASED EMOTION DETECTION NODE --- #
def classify_emotion(state: TherapyState) -> TherapyState:
    user_msg = state["message"]
    
    # Use AI to comprehensively analyze the message
    prompt = f"""
Analyze this user message and categorize it into one of these types:

User message: \"{user_msg}\"

Categories:
1. "greeting" - Casual greetings, small talk, introductions, getting to know questions, identity questions
2. "islamic_question" - Questions about Islamic history, rules, theology, facts, or religious information
3. "haram_content" - Content involving haram relationships, substances, or activities that need Islamic guidance
4. "emotional_distress" - Messages expressing emotional pain, mental health concerns, or psychological distress
5. "neutral" - Other messages that don't fit above categories

For reference (but don't limit yourself to these examples):

Greeting examples: {', '.join(GREETING_EXAMPLES[:10])}...
Emotional distress examples: {', '.join(EMOTIONAL_DISTRESS_EXAMPLES[:10])}...
Islamic question examples: {', '.join(ISLAMIC_QUESTION_EXAMPLES[:5])}...
Haram content examples: {', '.join(HARAM_CONTENT_EXAMPLES['relationship'][:5])}...

IMPORTANT: Look beyond exact word matches. Understand the INTENT and CONTEXT:
- Someone saying "I'm not feeling good" is emotional distress, not neutral
- Someone asking "What should I do about my situation?" after describing problems is emotional distress
- Creative expressions of sadness, anxiety, or other emotions should be detected
- Indirect references to emotional states should be caught
- Consider cultural and linguistic variations

First, determine the category. Then if it's "emotional_distress", also identify the specific emotion from:
["sad", "angry", "anxious", "tired", "lonely", "guilty", "empty", "hopeless", "happy", "confused", "overwhelmed", "peaceful", "grateful"]

Return your analysis in this format:
Category: [category]
Emotion: [emotion if emotional_distress, otherwise "none"]
Reasoning: [brief explanation of why you classified it this way]
    """
    
    try:
        response = model.generate_content(prompt).text.strip()
        logging.info(f"AI Analysis Response: {response}")
        
        # Parse the AI response
        lines = response.split('\n')
        category = "neutral"
        emotion = "neutral"
        
        for line in lines:
            if line.lower().startswith('category:'):
                category = line.split(':', 1)[1].strip().lower()
            elif line.lower().startswith('emotion:'):
                emotion = line.split(':', 1)[1].strip().lower()
        
        # Handle different categories
        if category == "greeting":
            state["emotion"] = "greeting"
            logging.info("AI detected as greeting/small talk")
        elif category == "islamic_question":
            state["emotion"] = "islamic_question"
            logging.info("AI detected Islamic question")
        elif category == "haram_content":
            state["emotion"] = "haram_content"
            logging.info("AI detected haram content")
        elif category == "emotional_distress":
            # Use the specific emotion detected
            supported_emotions = ["sad", "angry", "anxious", "tired", "lonely", "guilty", "empty", "hopeless", "happy", "confused", "overwhelmed", "peaceful", "grateful"]
            
            # Find which emotion appears in the response
            detected_emotion = "neutral"
            for emo in supported_emotions:
                if emo in emotion:
                    detected_emotion = emo
                    break
            
            state["emotion"] = detected_emotion
            logging.info(f"AI detected emotional distress: {detected_emotion}")
        else:
            state["emotion"] = "neutral"
            logging.info("AI detected as neutral")
        
        return state
        
    except Exception as e:
        logging.error(f"Error in AI emotion detection: {e}")
        # Fallback to basic static detection
        if is_greeting_or_small_talk(user_msg):
            state["emotion"] = "greeting"
        elif detect_islamic_question(user_msg):
            state["emotion"] = "islamic_question"
        else:
            state["emotion"] = "neutral"
        return state


# --- DUA DATASET --- #
DUA_DATASET = {
    "sad": [
        {
            "arabic": "اللّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الهَمِّ وَالحَزَنِ",
            "translation": "O Allah, I seek refuge in You from worry and grief."
        },
        {
            "arabic": "اللّهُمَّ اجْبُرْ كَسْرِي وَارْزُقْنِي الرِّضَا",
            "translation": "O Allah, mend my brokenness and grant me contentment."
        },
        {
            "arabic": "اللّهُمَّ املأ قلبي سرورًا وأملاً بك",
            "translation": "O Allah, fill my heart with joy and hope in You."
        },
        {
            "arabic": "اللّهُمَّ إِنِّي أَسْأَلُكَ نَفْسًا مُطْمَئِنَّةً",
            "translation": "O Allah, I ask You for a soul that is content."
        },
        {
            "arabic": "اللّهُمَّ اجعلني ممن تبشرهم الملائكة: ألا تخافوا ولا تحزنوا",
            "translation": "O Allah, make me among those whom the angels give glad tidings: 'Do not fear and do not grieve.'"
        }
    ],
    "anxious": [
        {
            "arabic": "اللّهُمَّ لاَ سَهْلَ إِلاَّ مَا جَعَلْتَهُ سَهْلاً",
            "translation": "O Allah, there is no ease except what You make easy."
        },
        {
            "arabic": "اللّهُمَّ اكفني همي وأزل عني كربي",
            "translation": "O Allah, relieve me of my worry and remove my distress."
        },
        {
            "arabic": "اللّهُمَّ طمئن قلبي بذكرك",
            "translation": "O Allah, reassure my heart with Your remembrance."
        },
        {
            "arabic": "اللّهُمَّ إني أعوذ بك من الهم والحزن",
            "translation": "O Allah, I seek refuge in You from anxiety and sorrow."
        },
        {
            "arabic": "اللّهُمَّ اشرح لي صدري ويسر لي أمري",
            "translation": "O Allah, expand for me my chest and ease for me my task."
        }
    ],
    "hopeless": [
        {
            "arabic": "اللّهُمَّ ارزقني حسن الظن بك",
            "translation": "O Allah, grant me good thoughts about You."
        },
        {
            "arabic": "اللّهُمَّ اجعلني من المتوكلين عليك",
            "translation": "O Allah, make me among those who rely upon You."
        },
        {
            "arabic": "اللّهُمَّ لا تحرمني خير ما عندك بسوء ما عندي",
            "translation": "O Allah, do not deprive me of the best of what You have because of the worst of what I have."
        },
        {
            "arabic": "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ",
            "translation": "My Lord, do not leave me alone, and You are the best of inheritors."
        },
        {
            "arabic": "اللّهُمَّ اجعل آخر كلامي شهادة أن لا إله إلا الله",
            "translation": "O Allah, make the last words I speak: There is no god but Allah."
        }
    ],
    "guilty": [
        {
            "arabic": "اللّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا فَاغْفِرْ لِي",
            "translation": "O Allah, I have greatly wronged myself, so forgive me."
        },
        {
            "arabic": "رَبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
            "translation": "My Lord, forgive and have mercy, and You are the best of the merciful."
        },
        {
            "arabic": "اللّهُمَّ اجعلني من التوابين",
            "translation": "O Allah, make me among those who repent often."
        },
        {
            "arabic": "اللّهُمَّ طَهِّرْ قلبي من الذنوب والخطايا",
            "translation": "O Allah, purify my heart from sins and mistakes."
        },
        {
            "arabic": "رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا",
            "translation": "Our Lord, forgive us our sins and remove from us our misdeeds."
        }
    ],
    "lonely": [
            {
                "arabic": "اللّهُمَّ آنِسْ وَحْشَتِي",
                "translation": "O Allah, comfort my loneliness."
            },
        {
            "arabic": "اللّهُمَّ اكفني بحلالك عن حرامك وأغنني بفضلك عمن سواك",
            "translation": "O Allah, suffice me with Your lawful against Your unlawful, and enrich me by Your bounty over all besides You."
        },
        {
            "arabic": "اللّهُمَّ كُنْ مَعِي وَلاَ تَكُنْ عَلَيَّ",
            "translation": "O Allah, be with me and not against me."
        },
        {
            "arabic": "اللّهُمَّ إني أسألك أنس القلب بقربك",
            "translation": "O Allah, I ask You for the comfort of the heart through closeness to You."
        },
        {
            "arabic": "اللّهُمَّ املأ قلبي بنورك ورضاك",
            "translation": "O Allah, fill my heart with Your light and Your pleasure."
        }
    ]
}

# --- DUA FETCH NODE --- #
def fetch_dua(state: TherapyState) -> TherapyState:
    emotion = state.get("emotion")

    # If the emotion is neutral or positive, no dua is needed
    if emotion in ["happy", "neutral", "none"]:
        state["dua"] = None
        logging.info("No dua needed for positive or neutral emotion.")
        return state

    # Check if emotion exists in DUA_DATASET
    if emotion in DUA_DATASET:
        selected_dua = random.choice(DUA_DATASET[emotion])
        dua_text = f"Arabic: {selected_dua['arabic']}\nTranslation: {selected_dua['translation']}"
        state["dua"] = dua_text
        logging.info(f"Dua: {dua_text}")
        return state

    # If emotion not found, fallback to generic duas
    selected_dua = random.choice(FALLBACK_DUAS)
    dua_text = f"Arabic: {selected_dua['arabic']}\nTranslation: {selected_dua['translation']}"
    state["dua"] = dua_text
    logging.info(f"Fallback Dua: {dua_text}")
    return state



# --- HARAM CONTENT DETECTION --- #
def detect_haram_content(text: str) -> dict:
    """Detect if message contains haram relationship or content"""
    text = text.lower().strip()
    
    # Haram relationship indicators
    haram_relationship_patterns = [
        "girlfriend", "boyfriend", "dating", "date", "crush", "love someone",
        "in love with", "attracted to", "relationship with", "romantic", "romance",
        "physical relationship", "intimate", "intimacy", "sexual", "sex",
        "kissing", "hugging", "touching", "alone with", "haram relationship",
        "girl left me", "boy left me", "girl broke up", "boy broke up",
        "my girlfriend", "my boyfriend", "broke up with me", "left me",
        "want her back", "want him back", "get her back", "get him back",
        "missing her", "missing him", "love her", "love him"
    ]
    
    # General haram content
    haram_general_patterns = [
        "alcohol", "drinking", "drunk", "wine", "beer", "party", "club",
        "gambling", "bet", "lottery", "drugs", "smoking", "cigarette",
        "music", "listen to music", "songs", "singing", "dance", "dancing"
    ]
    
    found_haram_relationship = any(pattern in text for pattern in haram_relationship_patterns)
    found_haram_general = any(pattern in text for pattern in haram_general_patterns)
    
    return {
        "has_haram_relationship": found_haram_relationship,
        "has_haram_general": found_haram_general,
        "has_any_haram": found_haram_relationship or found_haram_general
    }

# --- COUNSELOR RESPONSE NODE --- #
def generate_counseling(state: TherapyState) -> TherapyState:
    name = state.get("name", "Friend")
    emotion = state.get("emotion", "neutral")
    user_msg = state["message"]

    # Handle greetings and small talk differently
    if emotion == "greeting":
        # Determine if greeting is necessary based on prior interactions
        user_context = get_user_context(state["user_id"])

        greeting_prompt = f"""
You are Mustafa, an Islamic therapist developed by Syed Mozamil Shah as a Sadqa e Jariya for the Islamic Community, to mend and heal hearts.

The user just sent a non-emotional message (small talk or casual conversation).

User context from memory:
{user_context}

Current message: "{user_msg}"

IMPORTANT: Respond naturally to greetings based on the context and past interactions, without always using the same format.

Specific responses for identity questions:

For "Who are you?" or "Tell me about yourself":
"I'm Mustafa, an Islamic therapist created to help mend and heal hearts through Islamic guidance and counseling. I was developed by Syed Mozamil Shah as a Sadqa e Jariya for the Islamic Community."

For "Who built you?" or "Who created you?" or "Who developed you?":
"I was developed by Syed Mozamil Shah as a Sadqa e Jariya for the Islamic Community. He created me to help provide Islamic counseling and support to those in need."

For "What can you do?":
"I offer support through listening and drawing from the Seerah, Sunnah, and Quran 🌙"

For "Do you know my name?" or "What's my name?":
- If name is available in memory: "Of course, your name is {name}!"
- If no name in memory: "I haven't saved your name yet. What would you like me to call you?"

For general greetings like "Hello", "Hi", "Assalam":
"I'm here to help you feel supported and heard."

For "How are you?" questions:
"I'm here to help you feel supported and heard."

Respond genuinely and warmly based on their message and memory context."""
        
        reply = model.generate_content(greeting_prompt).text.strip()
        state["response"] = reply
        logging.info(f"Greeting response: {reply}")
        return state
    
    if emotion == "islamic_question":
        reply = f"Sorry {name}, I can't have access to those kind of questions. I am here to provide you mood-based counselling. Tell me how your heart is feeling right now."
        state["response"] = reply
        logging.info(f"Islamic question redirect: {reply}")
        return state
    
    if emotion == "haram_content":
        # Handle haram content detected by AI
        logging.info("AI detected haram content, processing with specialized response")
        # Continue to the haram content handling section below
        pass

    # Check for haram content
    haram_check = detect_haram_content(user_msg)
    
    if haram_check["has_any_haram"]:
        # Handle haram content with specific response templates
        haram_templates = [
            {
                "opening": "Sometimes, when the heart becomes attached, it forgets its true Owner. But you are never too far gone. Allah is closer to you than your own sadness, and He loves the heart that returns.",
                "story": "There was a man who gave up everything for a woman he loved, but then remembered his Lord and repented. And Allah raised him higher than those who never fell. Allah says: 'Evil women are for evil men, and pious women for pious men.' And, 'Whoever fears standing before Allah will be granted two gardens.' Imagine the reward when you walk away for Him.",
                "techniques": [
                    "Write down what you truly want in life — and place Jannah at the top.",
                    "Replace emotional voids with Dhikr. Use Tasbih after Fajr and Maghrib.",
                    "Practice Cognitive Restructuring: When missing them, remind yourself what you're truly missing is nearness to Allah.",
                    "Reduce all triggers — block, unfollow, or even delete, because your soul is more precious."
                ],
                "dua": {
                    "arabic": "اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ",
                    "transliteration": "Allahumma ikfineehim bima shi'ta",
                    "translation": "O Allah, suffice me against them however You will."
                }
            },
            {
                "opening": "You feel something inside because your heart still beats with Imaan. Allah sees the struggle — not to be perfect, but to choose Him even with tears in your eyes.",
                "story": "Do you remember Yusuf عليه السلام? Alone in a palace, seduced by a powerful woman, but he said, 'O Allah, prison is dearer to me than this.' That one choice elevated him — not just spiritually, but in status. If you leave for Allah, He promises far better in return.",
                "techniques": [
                    "List what this relationship has cost you spiritually, mentally, and emotionally.",
                    "Start journaling a letter to Allah every night — call it 'My Return Journey'.",
                    "Fast on Mondays and Thursdays — it calms desire and boosts spiritual strength.",
                    "Say 'Astaghfirullah' with intention, not repetition — 33 times with heart."
                ],
                "dua": {
                    "arabic": "اللَّهُمَّ اجْعَلْنِي مِنْ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ",
                    "transliteration": "Allahumma aj'alni min at-tawwabeen waj'alni min al-mutatahhireen",
                    "translation": "O Allah, make me among those who often repent and purify themselves."
                }
            },
            {
                "opening": "Your pain is valid. But the One who fashioned your heart knows how to mend it. Return to Him, and you'll find light no one else could give.",
                "story": "There's a reason the Prophet ﷺ told a young man, 'Would you like it for your sister?' when he asked about zina. Not to shame him — but to awaken his dignity. That man changed forever, just from one conversation. You can too.",
                "techniques": [
                    "Write a list titled 'If I loved Allah more than them, I would…' and complete it.",
                    "Do wudhu slowly and mindfully — it literally resets your soul and mind.",
                    "Replace time spent texting or overthinking with Qur'an recitation — even 5 verses.",
                    "Learn the 90-second rule — sit with the emotion without reacting, let it pass."
                ],
                "dua": {
                    "arabic": "اللَّهُمَّ أَصْلِحْ لِي دِينِيَ الَّذِي هُوَ عِصْمَةُ أَمْرِي",
                    "transliteration": "Allahumma aslih li deeni alladhi huwa 'ismatu amri",
                    "translation": "O Allah, set right for me my religion which is the safeguard of my affairs."
                }
            },
            {
                "opening": "You chose to reach out instead of falling deeper — and that alone is a victory. Allah sees that flicker of light, and He can turn it into a flame of guidance.",
                "story": "There was once a companion addicted to sin, brought to the Prophet ﷺ again and again. People cursed him. The Prophet ﷺ said: 'Do not curse him, for he loves Allah and His Messenger.' If Allah accepted that heart, He will accept yours too.",
                "techniques": [
                    "Sit after Fajr and imagine what your life could look like if it was built around Allah.",
                    "Use the Thought Stop Technique: when romantic thoughts appear, audibly say 'Stop' and redirect with a verse or Tasbih.",
                    "Clean your room or environment — remove anything tied to sin. This cleans your Qalb too.",
                    "Speak to your future self who made it out — what would they thank you for?"
                ],
                "dua": {
                    "arabic": "اللَّهُمَّ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
                    "transliteration": "Allahumma thabbit qalbi 'ala deenik",
                    "translation": "O Allah, keep my heart firm upon Your religion."
                }
            }
        ]
        
        # Use both approaches: sometimes template, sometimes LLM-generated
        use_llm = random.choice([True, False])  # 50% chance to use LLM
        
        if use_llm:
            # Select a random template for LLM guidance
            selected_template = random.choice(haram_templates)
            
            # Generate varied response using LLM based on template themes
            haram_llm_prompt = f"""
You are Mustafa, an Islamic therapist. A user is struggling with a haram relationship. Create a compassionate Islamic counseling response following this EXACT structure:

First paragraph: Acknowledge their struggle with connection to Allah's mercy (2-3 lines)

Second paragraph: Reference a Prophet's story or companion's experience that relates to their situation (2-3 lines)

Third paragraph: Write "Here are steps to heal:" then give 4 numbered practical steps

Final paragraph: Provide authentic Arabic dua with transliteration and translation

Use these themes as inspiration but create your own variation:
- Opening theme: "{selected_template['opening'][:50]}..."
- Story theme: "{selected_template['story'][:50]}..."
- Technique examples: {', '.join(selected_template['techniques'][:2])}
- Dua theme: {selected_template['dua']['translation']}

IMPORTANT FORMATTING RULES:
- NO asterisks (*) anywhere in your response
- NO bold text or special formatting
- NO headings like "Opening:" or "Islamic Story:" or "Practical Islamic CBT Techniques:"
- Just write natural paragraphs and numbered lists
- Use plain text only
- Be compassionate but firm about Islamic boundaries
- Reference specific Quranic concepts like taqwa, repentance, Allah's mercy
- Include practical CBT techniques adapted for Islamic context
- Use authentic Arabic dua with proper transliteration
- Keep the tone warm but spiritually motivating

User's situation: "{user_msg}"

Generate a complete response following the structure above with plain text formatting only."""
            
            reply = model.generate_content(haram_llm_prompt).text.strip()
            logging.info(f"LLM-generated haram content response: {reply}")
        else:
            # Use predefined template
            selected_template = random.choice(haram_templates)
            
            # Build the response
            reply = selected_template["opening"] + "\n\n" + selected_template["story"] + "\n\nHere are steps to heal:\n\n"
            
            for i, technique in enumerate(selected_template["techniques"], 1):
                reply += f"{i}. {technique}\n\n"
            
            # Add the dua
            reply += f"{selected_template['dua']['arabic']}\n{selected_template['dua']['transliteration']}\n\"{selected_template['dua']['translation']}\""
            
            logging.info(f"Template-based haram content response: {reply}")
        
        state["response"] = reply
        return state

    # For emotional responses, use the full therapeutic approach
    # Update user's emotional history
    update_user_emotion_history(state["user_id"], emotion)
    
    # Get user context from memory
    user_context = get_user_context(state["user_id"])
    
    # Use RAG system to get relevant Islamic CBT techniques and guidance with timeout
    relevant_docs = []
    try:
        logging.info("Retrieving relevant documents from RAG system...")
        # Quick timeout for RAG retrieval to prevent hanging
        import threading
        import time
        
        def get_docs():
            try:
                # Get documents specifically for this emotion (limit 1 for speed)
                emotion_docs = rag_manager.search_by_emotion(emotion, limit=1)
                return emotion_docs
            except Exception as e:
                logging.warning(f"RAG retrieval failed: {e}")
                return []
        
        # Use threading with timeout
        result_container = []
        
        def rag_thread():
            result_container.append(get_docs())
        
        thread = threading.Thread(target=rag_thread)
        thread.daemon = True
        thread.start()
        thread.join(timeout=3)  # 3 second timeout
        
        if result_container:
            relevant_docs = result_container[0]
            logging.info(f"Retrieved {len(relevant_docs)} documents for emotion '{emotion}'")
        else:
            logging.warning("RAG retrieval timed out, using fallback")
            relevant_docs = []
            
    except Exception as e:
        logging.warning(f"RAG retrieval failed: {e}. Using static context.")
        relevant_docs = []
    if relevant_docs:
        context_content = "\n\nBased on Islamic guidance:\n"
        for i, doc in enumerate(relevant_docs, 1):
            excerpt = doc['content'][:200] + "..." if len(doc['content']) > 200 else doc['content']
            context_content += f"{excerpt}\n\n"
    else:
        context_content = f"\n\nIslamic teachings remind us that Allah is always with those who seek Him. The Quran and Sunnah provide guidance for all emotional states.\n"

    # Intelligent emotional response system with holistic CBT techniques
    prompt = f"""
You are Mustafa, an Islamic counselor specializing in Islamic CBT techniques.

User's name: {state.get('name', 'Friend')}
Emotion: {emotion}
Message: "{user_msg}"
User context: {user_context}

Create an emotionally resonant opening without repeatition (1-2 lines only):
- "Hi [name], I understand you are [feeling]. Sometimes we chase a flower, but Allah plans to bless us with a whole bouquet."
- "Hello [name], I feel your weight. Remember, even clouds carry rain that blesses the earth."

Your response MUST follow this format:

[Opening sentence - 1-2 lines max]

[Islamic story of prophets, sahabas, seerah etc relevant to user condition - 4-5 lines don't cite the reference and use exact wording of stories but naturally]

[3-4 practical Islamic CBT techniques - Write them as simple numbered points and not lengthy just 1 to 2 line each: 1. [technique] 2. [technique] 3. [technique] 4. [technique]]

[Hopeful closure - 1-2 lines max]

CRITICAL FORMATTING RULES:
|- No asterisks (*) or headings
|- Use only plain text and numbered lists
|- Each technique concise and action-oriented
|- Keep response under 200 words total
|- Don't write reference for what you are citing

Techniques might include:
- Dhikr and short du'as for mindfulness
- Practical gratitude reflections
- Cognitive shifts with Quranic guidance
- Immediate actionable, faith-based steps

Frame your response as heartfelt advice from someone grounded in Islamic wisdom and psychology."""
    language = detect_language(user_msg)
    if language == "roman_urdu":
        prompt += "\n(Respond gently in Roman Urdu.)"
    else:
        prompt += "\n(Respond warmly in English.)"
    reply = model.generate_content(prompt).text.strip()

    # Attach relevant dua if necessary
    dua_info = state.get("dua")
    if dua_info:
        reply += f"\n\nMay this dua guide you to peace:\n\n🤲 {dua_info}"
    
    state["response"] = reply
    logging.info(f"Therapist reply: {reply}")
    return state

# --- USER MEMORY NODE --- #
def set_user_memory(state: TherapyState) -> TherapyState:
    uid = state["user_id"]
    current_name = state.get("name", "Friend")
    current_message = state.get("message", "")
    
    # Initialize user memory if not exists
    if uid not in memory:
        memory[uid] = {
            "name": current_name,
            "conversation_history": [],
            "mood_history": [],
            "last_seen": None,
            "topics_discussed": [],
            "preferences": {}
        }
        logging.info(f"New user registered: {current_name}")
    else:
        # Update existing user's name if provided
        if current_name and current_name != "Friend":
            memory[uid]["name"] = current_name
        
        stored_name = memory[uid].get("name", "Friend")
        logging.info(f"Welcome back, {stored_name}!")
    
    # Store conversation history (last 5 messages)
    if "conversation_history" not in memory[uid]:
        memory[uid]["conversation_history"] = []
    
    memory[uid]["conversation_history"].append({
        "message": current_message,
        "timestamp": time.time(),
        "detected_patterns": []
    })

    # Detect and store haram or significant patterns in conversation
    haram_content_info = detect_haram_content(current_message)
    if haram_content_info["has_any_haram"]:
        memory[uid]["conversation_history"][-1]["detected_patterns"] = haram_content_info.get("patterns_detected", [])

    # Keep only last 10 messages with comprehensive history
    if len(memory[uid]["conversation_history"]) > 10:
        memory[uid]["conversation_history"] = memory[uid]["conversation_history"][-10:]
    
    # Update last seen
    memory[uid]["last_seen"] = time.time()
    
    # Set the name in state from memory
    state["name"] = memory[uid].get("name", "Friend")
    
    return state

def get_user_context(user_id: str) -> str:
    """Get user context for prompts"""
    if user_id not in memory:
        return "This is a new user. No previous context available."
    
    user_mem = memory[user_id]
    name = user_mem.get("name", "Friend")
    
    # Get recent conversation topics
    recent_messages = user_mem.get("conversation_history", [])[-3:]  # Last 3 messages
    recent_topics = [msg["message"][:50] + "..." if len(msg["message"]) > 50 else msg["message"] for msg in recent_messages]
    
    # Get mood history
    mood_history = user_mem.get("mood_history", [])[-2:]  # Last 2 moods
    
    context = f"User's name: {name}\n"
    
    if recent_topics:
        context += f"Recent topics discussed: {', '.join(recent_topics)}\n"
    
    if mood_history:
        context += f"Recent emotional states: {', '.join(mood_history)}\n"
    
    return context

def update_user_emotion_history(user_id: str, emotion: str):
    """Update user's emotional history"""
    if user_id not in memory:
        return
    
    if "mood_history" not in memory[user_id]:
        memory[user_id]["mood_history"] = []
    
    memory[user_id]["mood_history"].append(emotion)
    
    # Keep only last 5 emotions
    if len(memory[user_id]["mood_history"]) > 5:
        memory[user_id]["mood_history"] = memory[user_id]["mood_history"][-5:]

# --- LANGGRAPH BUILD --- #
graph = StateGraph(TherapyState)

graph.add_node("handle_memory", set_user_memory)
graph.add_node("detect_emotion", classify_emotion)
graph.add_node("get_dua", fetch_dua)
graph.add_node("generate_reply", generate_counseling)

graph.set_entry_point("handle_memory")
graph.add_edge("handle_memory", "detect_emotion")

graph.add_conditional_edges(
    "detect_emotion",
    lambda state: "get_dua" if state.get("emotion") in ["sad", "angry", "anxious", "tired", "lonely", "guilty", "empty", "hopeless"] else "generate_reply"
)

graph.add_edge("get_dua", "generate_reply")
graph.set_finish_point("generate_reply")

langgraph_app = graph.compile()
