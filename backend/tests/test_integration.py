#!/usr/bin/env python3
"""
Integration test to verify backend-frontend communication works smoothly
"""
import requests
import json
import time

def test_health_endpoint():
    """Test if the health endpoint is working"""
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health endpoint working")
            return True
        else:
            print(f"❌ Health endpoint failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health endpoint error: {e}")
        return False

def test_chat_endpoint_small_talk():
    """Test small talk detection according to specifications"""
    test_cases = [
        {
            "message": "How are you?",
            "expected_emotion": "greeting",
            "should_have_dua": False
        },
        {
            "message": "What's my name?", 
            "expected_emotion": "greeting",
            "should_have_dua": False
        },
        {
            "message": "What can you do?",
            "expected_emotion": "greeting", 
            "should_have_dua": False
        },
        {
            "message": "What's the Islamic date today?",
            "expected_emotion": "greeting",
            "should_have_dua": False
        }
    ]
    
    print("\n🧪 Testing Small Talk Detection:")
    all_passed = True
    
    for test in test_cases:
        try:
            data = {
                "user_id": "test_user",
                "name": "Ahmad", 
                "message": test["message"]
            }
            
            response = requests.post("http://localhost:8000/chat", json=data, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                emotion = result.get("emotion", "")
                has_dua = bool(result.get("dua"))
                message = result.get("message", "")
                
                # Check if emotion matches expectation
                emotion_correct = emotion == test["expected_emotion"]
                dua_correct = has_dua == test["should_have_dua"]
                
                # Check response format for small talk (should be brief and warm)
                is_brief = len(message.split()) < 50  # Should be brief
                no_therapy_language = not any(word in message.lower() for word in ["therapy", "dua", "islamic guidance", "emotion"])
                
                if emotion_correct and dua_correct and is_brief:
                    print(f"✅ '{test['message']}' → {emotion} (brief response)")
                else:
                    print(f"❌ '{test['message']}' → {emotion}, dua={has_dua}, brief={is_brief}")
                    all_passed = False
                    
            else:
                print(f"❌ '{test['message']}' → HTTP {response.status_code}")
                all_passed = False
                
        except Exception as e:
            print(f"❌ '{test['message']}' → Error: {e}")
            all_passed = False
            
    return all_passed

def test_chat_endpoint_emotional():
    """Test emotional response according to specifications"""
    test_cases = [
        {
            "message": "I feel so depressed... nothing makes sense",
            "expected_emotion": "sad",
            "should_have_dua": True
        },
        {
            "message": "Everything is making me angry these days",
            "expected_emotion": "angry", 
            "should_have_dua": True
        },
        {
            "message": "I'm feeling very anxious about my future",
            "expected_emotion": "anxious",
            "should_have_dua": True
        }
    ]
    
    print("\n🧪 Testing Emotional Response Format:")
    all_passed = True
    
    for test in test_cases:
        try:
            data = {
                "user_id": "test_user",
                "name": "Ahmad",
                "message": test["message"] 
            }
            
            response = requests.post("http://localhost:8000/chat", json=data, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                emotion = result.get("emotion", "")
                has_dua = bool(result.get("dua"))
                message = result.get("message", "")
                
                # Check format according to specifications
                has_emotional_opening = any(phrase in message for phrase in [
                    "That sounds heavy", "I can feel", "You're not alone"
                ])
                
                has_numbered_steps = any(str(i) + "." in message for i in range(1, 4))
                
                has_dua_intro = "Here's a short dua for you to feel relaxed in this moment:" in message
                
                # Check if emotion is emotional (not greeting)
                emotion_correct = emotion != "greeting"
                dua_correct = has_dua == test["should_have_dua"]
                
                if emotion_correct and dua_correct and has_emotional_opening and has_numbered_steps:
                    print(f"✅ '{test['message'][:30]}...' → {emotion} (proper format)")
                else:
                    print(f"❌ '{test['message'][:30]}...' → emotion={emotion}, dua={has_dua}")
                    print(f"   Format: opening={has_emotional_opening}, steps={has_numbered_steps}, dua_intro={has_dua_intro}")
                    all_passed = False
                    
            else:
                print(f"❌ '{test['message'][:30]}...' → HTTP {response.status_code}")
                all_passed = False
                
        except Exception as e:
            print(f"❌ '{test['message'][:30]}...' → Error: {e}")
            all_passed = False
            
    return all_passed

def main():
    print("🔧 QalbCare Backend-Frontend Integration Test")
    print("="*60)
    
    # Test health endpoint
    if not test_health_endpoint():
        print("\n❌ Backend is not running or not accessible")
        print("Please start the backend server with: python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
        return
    
    # Test chat functionality
    small_talk_passed = test_chat_endpoint_small_talk()
    emotional_passed = test_chat_endpoint_emotional()
    
    print("\n" + "="*60)
    print("📊 TEST SUMMARY:")
    print(f"Small Talk Detection: {'✅ PASSED' if small_talk_passed else '❌ FAILED'}")
    print(f"Emotional Response Format: {'✅ PASSED' if emotional_passed else '❌ FAILED'}")
    
    if small_talk_passed and emotional_passed:
        print("\n🎉 ALL TESTS PASSED! The agent behavior is working correctly.")
        print("Frontend should work smoothly with the backend.")
    else:
        print("\n⚠️ Some tests failed. Please check the agent configuration.")

if __name__ == "__main__":
    main()
