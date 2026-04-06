# QalbCare -- Islamic Mental Health & Therapy App

<div align="center">

![QalbCare Logo](frontend/lib/assets/logo.png)

**Healing Hearts Through Islamic Wisdom**

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=flat&logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

## 🌟 Overview

QalbCare is a comprehensive Islamic mental health support application that provides compassionate counseling and spiritual guidance rooted in Islamic wisdom. The app combines modern AI-powered therapy techniques with traditional Islamic approaches to mental health, offering users a culturally sensitive and religiously aligned therapeutic experience.

**Built with ❤️ for the Muslim community - May Allah bless this effort to support mental health through Islamic wisdom.**

### ✨ Key Features

#### 🤖 **AI-Powered Islamic Therapy**
- Intelligent counseling agent (Mustafa) trained on authentic Islamic mental health resources
- Advanced RAG System with verified Islamic sources from Yaqeen Institute, Duke University, and more
- Emotional Intelligence with personalized responses for 13+ emotional states
- Contextual Duas automatically selected based on emotional state

#### 📿 **Azkar Streak System**
- **Daily Azkar Tracking**: Morning and evening Azkar completion with 10 essential remembrances
- **Streak Counter**: Track consecutive days of Azkar completion with fire icon animation
- **Time-Based Sessions**: Separate morning (before 2 PM) and evening (after 2 PM) Azkar sessions
- **Progress Visualization**: Real-time progress bar and completion percentage
- **Smart Notifications**: Automated reminders at 7:00 AM and 6:30 PM

#### 💎 **Gamification & Progress Tracking**
- **Gem Points System**: Earn points for completing spiritual activities
- **Heart State Assessment**: 7-question spiritual health evaluation based on Islamic teachings
- **7-Day Heart Healing Journey**: Guided daily tasks for spiritual revival
- **Muhasiba (Self-Accountability)**: Daily self-reflection and accountability tracking
- **Progress History**: Visual charts and historical data for all activities

#### 🔔 **Smart Notification System**
- **Azkar Reminders**: Daily morning (7:00 AM) and evening (6:30 PM) notifications
- **Muhasiba Alerts**: Evening reminders (9:30 PM) for daily self-accountability
- **Customizable Channels**: Separate notification channels for different reminder types
- **Deep Linking**: Direct navigation to specific features from notifications

#### 👤 **Complete User Profile System**
- **Avatar Selection**: Customizable user avatars (male/female options)
- **Profile Management**: Full name, email, WhatsApp number configuration
- **Data Persistence**: Firebase Firestore integration for cross-device synchronization
- **Chat History**: Complete conversation history with AI therapist
- **Achievement Tracking**: Gem points and progress milestones

#### 🎯 **Core Therapeutic Features**
- **Voice Therapy**: VAPI integration for voice-based therapy sessions
- **Chat-Based Counseling**: Text conversations with Islamic AI therapist
- **Message Editing**: Edit and manage conversation history
- **Quick Messages**: Pre-defined conversation starters
- **Emotional Context**: AI detects and responds to emotional states

#### 🛡️ **Technical Excellence**
- **Modern Flutter UI**: Beautiful Islamic-themed interface with Material Design 3
- **Secure Authentication**: Firebase Auth with complete user profiles
- **Real-time Sync**: Firebase Firestore for instant data synchronization
- **Multilingual Support**: English and Roman Urdu language detection
- **Fast & Scalable**: Async FastAPI backend with ChromaDB vector database
- **Security-First**: Environment variable configuration for all sensitive data

## 🏗️ Architecture

## 🛠️ Technologies Used

### Frontend Stack

- **Flutter**: Cross-platform UI toolkit with modern Material Design
- **Dart**: Programming language with null-safety compliance
- **Firebase Auth**: Secure user authentication and management
- **Firebase Firestore**: Real-time NoSQL database for cloud storage
- **Liquid Swipe**: Beautiful onboarding animations
- **Custom Islamic UI**: Reusable widgets with Islamic design patterns

**Dependencies:**
- Flutter SDK: `>=3.16.0`
- Dart SDK: `>=3.2.0 <4.0.0`
- firebase_core: `^3.6.0`
- firebase_auth: `^5.3.1`
- cloud_firestore: `^5.4.3`
- liquid_swipe: `^3.1.0`
- http: `^1.2.0`
- shared_preferences: `^2.2.2`

### Backend Stack

- **FastAPI**: Modern, high-performance web framework
- **Google Gemini AI**: Advanced language model for response generation
- **ChromaDB**: Vector database for document storage and retrieval
- **HuggingFace Transformers**: Sentence embeddings for semantic search
- **LangGraph**: Workflow orchestration for AI processes
- **RAG System**: Retrieval-Augmented Generation for evidence-based responses

**Key Dependencies:**
- fastapi
- uvicorn
- google-generativeai
- chromadb
- sentence-transformers
- langgraph
- pydantic
- python-dotenv

## Setup and Installation

### 🚀 Quick Setup (Recommended)

Use the automated setup script for the easiest installation:

```powershell
# Navigate to the project directory
cd QalbCare

# Run the automated setup script
.\setup_project.ps1 -Setup full -GoogleApiKey "YOUR_GOOGLE_API_KEY"

# Or setup individual components
.\setup_project.ps1 -Setup backend
.\setup_project.ps1 -Setup frontend
.\setup_project.ps1 -Setup android
```

### 📋 Manual Setup

To set up and run the QalbCare project manually, follow the instructions for both the frontend and backend.

### Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment (recommended):**
   ```bash
   python -m venv venv
   ```

3. **Activate the virtual environment:**
   - **Windows:**
     ```bash
     .\venv\Scripts\activate
     ```
   - **macOS/Linux:**
     ```bash
     source venv/bin/activate
     ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Set up environment variables:**
   Create a `.env` file in the `backend/` directory:
   ```
   GOOGLE_API_KEY=YOUR_GOOGLE_API_KEY
   ```

6. **Start the server:**
   ```bash
   python run_backend.py
   ```
   The backend server should now be running on `http://localhost:8000`.

### Frontend Setup

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Fix Environment Configuration:**
   - Move `.env` file to `assets/.env`
   - Update `pubspec.yaml` to include `assets/.env`

3. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the Flutter application:**
   ```bash
   flutter run
   ```
   This will launch the application on a connected device or emulator, or in a web browser if running for web.

## Security Configuration

1. **Environment Variables:**
   - Use `.env` file for storing sensitive configurations.
   - Ensure `.gitignore` contains `assets/.env`
2. **Firebase and API URLs:**
   - Ensure environment variables are set for Firebase keys and API base URLs
   - Example `.env` variables:
     ```
     FIREBASE_API_KEY_WEB=your-actual-web-api-key
     FIREBASE_API_KEY_ANDROID=your-actual-android-api-key
     API_BASE_URL=http://localhost:8000
     ```

## 🚀 API Endpoints

The backend provides the following REST API endpoints:

### Main Endpoints

- **POST `/chat`** - Main therapy conversation endpoint
- **GET `/health`** - Health check endpoint
- **GET `/rag/status`** - RAG system status and document count
- **GET `/rag/search/{emotion}`** - Search documents by emotion (debugging)
- **GET `/`** - API status and welcome message

### Example Usage

```bash
curl -X POST "http://localhost:8000/chat" \
     -H "Content-Type: application/json" \
     -d '{
       "user_id": "user_123",
       "name": "Ahmad",
       "message": "I feel very anxious about my future"
     }'
```

### Response Format

```json
{
  "name": "Ahmad",
  "emotion": "anxious",
  "dua": "Arabic: اللّهُمّ لاَ سهْلَ إِلاّ ما جعلته سهلاً\nTranslation: O Allah, there is no ease except what You make easy.",
  "message": "I understand that feeling anxious about the future can be overwhelming...",
  "success": true
}
```

## 🧠 RAG System (Retrieval-Augmented Generation)

QalbCare features a sophisticated RAG system that grounds therapeutic responses in authentic Islamic mental health sources.

### How RAG Works

1. **Document Embedding**: Trusted Islamic mental health documents are processed using HuggingFace's `all-MiniLM-L6-v2` model
2. **Semantic Search**: User queries are matched against the document store using cosine similarity
3. **Context Retrieval**: Relevant documents are retrieved based on user emotion and query content
4. **Response Generation**: Google Gemini generates responses using only the retrieved context

### Trusted Sources

The RAG system is built on content from verified Islamic mental health sources:

- **Islamic Integrated CBT Manual** – Duke University
- **Faith in Mind: Islam's Role in Mental Health** – Yaqeen Institute
- **Islamic Spirituality and Mental Well‑Being** – Yaqeen Institute
- **Perspectives on Islamic Psychology** – Yaqeen Institute
- **Holistic Healing: Islam's Legacy of Mental Health** – Yaqeen Institute
- **Naseeha Mental Health Resources**
- **Muslim Mental Health Digital Library**
- **About Islam Mental Health Articles**
- **Islamic Dawah Center Resources**

### RAG Testing

**Test the RAG system:**
```bash
python tests/test_rag.py
```

**Check RAG status via API:**
```bash
curl http://localhost:8000/rag/status
```

## 🔐 Authentication System

QalbCare features a complete authentication system with Firebase integration:

### Authentication Flow

1. **First Time Users:**
   - App starts → AuthWrapper
   - No onboarding seen → OnboardingScreen (liquid swipe)
   - Complete onboarding → SignupScreen
   - Create account → LoginScreen
   - Login successfully → Main App (HeartStateScreen)

2. **Returning Users (not logged in):**
   - App starts → AuthWrapper
   - Onboarding already seen → LoginScreen
   - Login successfully → Main App

3. **Already Logged In Users:**
   - App starts → AuthWrapper
   - Firebase Auth detects active session → Main App directly

### User Profile Structure (Firestore)

```javascript
users/{userId} {
  uid: string,
  email: string,
  fullName: string,
  whatsappNumber: string,
  selectedAvatar: string,
  chatHistory: array,
  muhasibaResults: array,
  qalbStateHistory: array,
  gemPoints: number,
  createdAt: timestamp
}
```

### Authentication Features

- **Onboarding Screen**: Liquid swipe animation with Islamic theming
- **Signup Screen**: Complete form validation with Firebase user creation
- **Login Screen**: Email/password authentication with forgot password
- **Password Security**: Firebase handles all password security
- **Form Validation**: Comprehensive input validation on all forms
- **Error Handling**: User-friendly error messages and network failure handling

## 📋 Supported Emotions

The therapy agent can detect and respond to the following emotional states:

- **Negative Emotions**: sad, anxious, lonely, guilty, hopeless, angry, tired, empty
- **Positive Emotions**: happy, peaceful, grateful
- **Complex States**: confused, overwhelmed

## 🌎 Using the Application

Once both the frontend and backend are running:

1. **Access the app** through your mobile device or emulator
2. **Complete onboarding** on first launch
3. **Create an account** with email and password
4. **Start chatting** with the AI therapy agent
5. **Take assessments** to track your spiritual and mental health progress
6. **View your profile** and chat history
7. **Make voice calls** to the therapy agent (VAPI integration)

### API Documentation

Once the backend is running, access interactive API documentation at:
- **Swagger UI**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/health`
- **RAG Status**: `http://localhost:8000/rag/status`

## 📱 Additional Features

### Heart State Assessment (Muhasiba)
- **Qalb Assessment**: Spiritual heart condition evaluation
- **Progress Tracking**: Historical tracking of spiritual growth
- **Islamic Guidance**: Personalized recommendations based on assessment results

### Voice Calling Integration (VAPI)
- **Real-time Voice Therapy**: Talk directly to the AI therapist
- **Natural Conversations**: Voice-based therapeutic interactions
- **Seamless Integration**: Embedded within the Flutter app

### Islamic UI Components
- **Custom Logo System**: Consistent branding with `AppLogo`, `AppLogoSimple`, and `AppLogoAnimated`
- **Islamic Patterns**: Beautiful decorative elements throughout the app
- **Material Design 3**: Modern UI following latest Flutter standards
- **Responsive Design**: Optimized for various screen sizes

## ⚠️ Troubleshooting

> **📖 For comprehensive troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)**
> **🔧 For detailed configuration fixes, see [CONFIGURATION_FIXES.md](CONFIGURATION_FIXES.md)**

### Quick Diagnostics

```powershell
# Test API connection
cd frontend
.\test_api_connection.ps1

# Validate Android build
.\validate_build_config.ps1

# Reset entire project
.\setup_project.ps1 -Setup full
```

### Common Issues

**Backend Issues:**
- API connection failed → Check if backend is running on port 8000
- Google API Key missing → Set `GOOGLE_API_KEY` in `backend/.env`
- RAG system errors → Delete `data/chroma_db` directory and restart

**Frontend Issues:**
- Flutter build errors → Run `flutter clean && flutter pub get`
- Environment variables not loading → Check `assets/.env` file exists
- Firebase errors → Verify Firebase configuration in console

**Android Build Issues:**
- SDK version conflicts → Install Android 15 (API 35) from Android Studio
- Plugin compatibility → Configuration already fixed for minSdk 23
- NDK errors → Install NDK version 27.0.12077973

**Network Issues:**
- API connection failed → Use network configuration scripts:
  ```powershell
  cd frontend
  .\switch_api_config.ps1 -Target device    # Physical device
  .\switch_api_config.ps1 -Target emulator  # Android emulator
  .\switch_api_config.ps1 -Target web       # Flutter web
  ```

## 🛠️ Development

### Project Architecture

```
QalbCare/
├── frontend/                 # Flutter mobile application
│   ├── lib/
│   │   ├── models/           # Data models
│   │   ├── screens/          # UI screens
│   │   ├── services/         # API and data services
│   │   ├── widgets/          # Reusable UI components
│   │   ├── utils/            # Utilities and constants
│   │   └── assets/           # Images and assets
│   ├── android/              # Android-specific code
│   ├── ios/                  # iOS-specific code
│   └── web/                  # Web-specific code
│
├── backend/                  # Python FastAPI server
│   ├── app/
│   │   ├── main.py           # FastAPI application
│   │   ├── therapy_agent.py  # AI therapy logic
│   │   └── rag_system.py     # RAG implementation
│   ├── chroma_db/            # Vector database storage
│   ├── requirements.txt      # Python dependencies
│   ├── .env                  # Environment variables
│   └── start_server.py       # Server startup script
│
└── vapi_therapist/           # Voice calling integration
```

### Code Quality

**Frontend:**
- ✅ Null-safety compliant
- ✅ Modern Flutter APIs (PopScope, WidgetStateProperty)
- ✅ Material Design 3 compliance
- ✅ Consistent Islamic theming
- ✅ Proper error handling and user feedback

**Backend:**
- ✅ Type hints with Pydantic
- ✅ Comprehensive error handling
- ✅ RAG system with authentic sources
- ✅ Async/await patterns
- ✅ API documentation with FastAPI

### Testing

**Backend Testing:**
```bash
# Test RAG system
python test_rag.py

# Test complete integration
python tests/test_integration.py

# Test agent behavior
python test_fixed_behavior.py
```

**Frontend Testing:**
```bash
# Run Flutter tests
flutter test

# Analyze code
flutter analyze
```

## 📋 Features Status

| Feature | Status | Description |
|---------|--------|--------------|
| 🤖 AI Therapy Agent | ✅ Complete | Gemini-powered Islamic counseling |
| 🧠 RAG System | ✅ Complete | Evidence-based responses from Islamic sources |
| 🔐 Authentication | ✅ Complete | Firebase Auth with complete user profiles |
| 📱 Mobile App | ✅ Complete | Flutter app with Islamic theming |
| 🗣️ Voice Calling | ✅ Complete | VAPI integration for voice therapy |
| 📋 Assessments | ✅ Complete | Heart state and Muhasiba evaluations |
| 🌍 Multilingual | ✅ Complete | English and Roman Urdu support |
| 📊 Analytics | 🔄 Planned | Advanced user progress tracking |
| 🌐 Web Version | 🔄 Planned | Flutter web deployment |
| 📱 iOS App Store | 🔄 Planned | iOS distribution |

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature/your-feature-name`).
6. Open a pull request.

## License

This project is licensed under the MIT License.

---

*Built with ❤️ for the Muslim community - May Allah bless this effort to support mental health through Islamic wisdom.*
