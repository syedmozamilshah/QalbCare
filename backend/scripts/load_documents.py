#!/usr/bin/env python3
"""
Document loader for QalbCare RAG system
This script can be used to load documents from trusted Islamic mental health sources
"""

import sys
import os
import requests
import time
from pathlib import Path

# Add the app directory to Python path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from app.rag_system import rag_manager

def load_sample_islamic_content():
    """Load additional sample Islamic mental health content"""
    
    print("Loading additional Islamic mental health content...")
    
    additional_content = [
        {
            "text": "The concept of tawakkul (trust in Allah) is central to Islamic mental health. It doesn't mean being passive, but rather taking action while having complete trust that Allah's decree is what's best for us. This balance between effort and surrender can significantly reduce anxiety and increase inner peace.",
            "source": "Islamic Trust and Mental Wellness",
            "topic": "tawakkul",
            "emotion_relevance": ["anxious", "overwhelmed", "confused"]
        },
        {
            "text": "Prophet Ayub (Job) endured immense suffering yet never lost faith. His story teaches us that trials are not punishments but tests that can strengthen our relationship with Allah. When he said 'Indeed, adversity has touched me, and you are the most merciful of the merciful' (Quran 21:83), he showed us how to maintain hope during hardship.",
            "source": "Prophetic Stories of Resilience",
            "topic": "patience_in_trials",
            "emotion_relevance": ["hopeless", "sad", "overwhelmed", "tired"]
        },
        {
            "text": "Islamic mindfulness through muraqaba (meditation) and dhikr helps practitioners develop awareness of Allah's presence. Studies show that regular dhikr practice can activate the parasympathetic nervous system, reducing stress hormones and promoting emotional regulation.",
            "source": "Islamic Mindfulness Research",
            "topic": "islamic_meditation",
            "emotion_relevance": ["anxious", "overwhelmed", "tired"]
        },
        {
            "text": "The Quran addresses mental health directly: 'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose' (65:3). This verse provides both comfort and practical guidance - we should take action while trusting in Allah's wisdom.",
            "source": "Quranic Guidance for Mental Health",
            "topic": "quranic_therapy",
            "emotion_relevance": ["hopeless", "anxious", "overwhelmed"]
        },
        {
            "text": "Gratitude (shukr) is a powerful therapeutic tool in Islam. The Prophet said, 'He who does not thank people does not thank Allah.' Practicing gratitude has been shown to increase dopamine and serotonin, naturally improving mood and creating positive neural pathways.",
            "source": "Islamic Psychology of Gratitude",
            "topic": "gratitude_therapy",
            "emotion_relevance": ["sad", "empty", "hopeless"]
        },
        {
            "text": "Islamic counseling emphasizes the importance of the heart (qalb) as the center of spiritual and emotional health. When the Quran mentions 'hearts find rest in the remembrance of Allah' (13:28), it points to dhikr as both a spiritual practice and a psychological healing tool.",
            "source": "Heart-Centered Islamic Therapy",
            "topic": "heart_healing",
            "emotion_relevance": ["sad", "empty", "lonely", "anxious"]
        },
        {
            "text": "The Islamic concept of fitrah (natural disposition) suggests that humans are inherently inclined toward good and connection with the Divine. Depression and anxiety can be understood as disconnection from this natural state, and healing involves returning to our fitrah through spiritual practices.",
            "source": "Fitrah and Mental Health",
            "topic": "natural_disposition",
            "emotion_relevance": ["empty", "confused", "hopeless"]
        },
        {
            "text": "Community (ummah) support is essential in Islamic mental health. The Prophet said, 'None of you truly believes until he loves for his brother what he loves for himself.' Social isolation worsens mental health, while meaningful community connections provide resilience and healing.",
            "source": "Islamic Community Mental Health",
            "topic": "community_healing",
            "emotion_relevance": ["lonely", "sad", "empty"]
        },
        {
            "text": "Islamic Cognitive Behavioral Therapy (ICBT) helps identify negative thought patterns while using Islamic principles as cognitive restructuring tools. For example, replacing 'I'm worthless' with 'Allah created me with dignity and purpose' based on Quran 17:70.",
            "source": "Islamic CBT Techniques",
            "topic": "islamic_cbt",
            "emotion_relevance": ["guilty", "hopeless", "sad", "empty"]
        },
        {
            "text": "The five daily prayers provide natural rhythm and structure that supports mental health. Each prayer time offers an opportunity for mindfulness, stress relief, and spiritual connection. Research shows that regular prayer can regulate circadian rhythms and reduce cortisol levels.",
            "source": "Prayer and Mental Wellness",
            "topic": "prayer_structure",
            "emotion_relevance": ["anxious", "overwhelmed", "confused", "tired"]
        }
    ]
    
    success_count = 0
    for content in additional_content:
        success = rag_manager.add_document(
            text=content["text"],
            source=content["source"],
            topic=content["topic"],
            emotion_relevance=content["emotion_relevance"]
        )
        if success:
            success_count += 1
            print(f"✅ Added: {content['source']}")
        else:
            print(f"❌ Failed to add: {content['source']}")
        
        # Small delay to avoid overwhelming the system
        time.sleep(0.1)
    
    print(f"\nLoaded {success_count}/{len(additional_content)} additional documents")
    return success_count

def load_duas_and_prayers():
    """Load Islamic duas and prayers for mental health"""
    
    print("Loading Islamic duas and prayers...")
    
    duas_content = [
        {
            "text": "The dua 'Rabbana atina fi'd-dunya hasanatan wa fi'l-akhirati hasanatan wa qina 'adhab an-nar' (Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire) is comprehensive prayer for both worldly and spiritual well-being. It acknowledges that true mental health involves balance between this life and the next.",
            "source": "Prophetic Duas for Well-being",
            "topic": "comprehensive_dua",
            "emotion_relevance": ["anxious", "overwhelmed", "hopeless"]
        },
        {
            "text": "The Prophet's dua 'Allahumma rahmataka arju fala takilni ila nafsi tarfata ayn' (O Allah, I hope for Your mercy, do not leave me to myself for the blink of an eye) expresses complete dependence on Allah. This surrender can provide profound relief from the burden of trying to control everything.",
            "source": "Duas for Surrender and Trust",
            "topic": "surrender_dua",
            "emotion_relevance": ["overwhelmed", "anxious", "tired"]
        },
        {
            "text": "Regular recitation of 'Hasbiyallahu la ilaha illa huwa alayhi tawakkaltu wa huwa rabbul arshil azeem' (Allah is sufficient for me; there is no deity except Him. On Him I rely, and He is the Lord of the Great Throne) has been shown to provide psychological comfort and reduce anxiety in believing Muslims.",
            "source": "Dhikr for Anxiety Relief",
            "topic": "anxiety_dhikr",
            "emotion_relevance": ["anxious", "overwhelmed", "confused"]
        }
    ]
    
    success_count = 0
    for content in duas_content:
        success = rag_manager.add_document(
            text=content["text"],
            source=content["source"],
            topic=content["topic"],
            emotion_relevance=content["emotion_relevance"]
        )
        if success:
            success_count += 1
            print(f"✅ Added: {content['source']}")
        else:
            print(f"❌ Failed to add: {content['source']}")
        
        time.sleep(0.1)
    
    print(f"Loaded {success_count}/{len(duas_content)} duas and prayers")
    return success_count

def main():
    """Main function to load all documents"""
    print("=== QalbCare Document Loader ===\n")
    
    # Check initial document count
    initial_count = rag_manager.get_document_count()
    print(f"Initial document count: {initial_count}")
    
    # Load additional content
    print("\n1. Loading additional Islamic content...")
    content_count = load_sample_islamic_content()
    
    print("\n2. Loading duas and prayers...")
    dua_count = load_duas_and_prayers()
    
    # Check final document count
    final_count = rag_manager.get_document_count()
    added_count = final_count - initial_count
    
    print(f"\n=== Loading Complete ===")
    print(f"Documents added: {added_count}")
    print(f"Total documents: {final_count}")
    print(f"RAG system ready for use!")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"❌ Loading failed with error: {e}")
        sys.exit(1)
