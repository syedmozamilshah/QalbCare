import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentService {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      
      // Log initialized values for debugging
      print('🌍 Environment loaded successfully');
      print('🔗 API_BASE_URL: ${dotenv.env['API_BASE_URL'] ?? 'Not set'}');
      print('🔥 FIREBASE_PROJECT_ID: ${dotenv.env['FIREBASE_PROJECT_ID'] ?? 'Not set'}');
      print('📞 VAPI_THERAPIST_URL: ${dotenv.env['VAPI_THERAPIST_URL'] ?? 'Not set'}');
      
    } catch (e) {
      print('⚠️ Warning: .env file not found, using fallback values: $e');
      // Initialize with empty env for fallback
      dotenv.env.clear();
    }
  }

  // Firebase Configuration
  static String get firebaseApiKeyWeb => dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
  static String get firebaseApiKeyAndroid => dotenv.env['FIREBASE_API_KEY_ANDROID'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppIdWeb => dotenv.env['FIREBASE_APP_ID_WEB'] ?? '';
  static String get firebaseAppIdAndroid => dotenv.env['FIREBASE_APP_ID_ANDROID'] ?? '';
  static String get firebaseMeasurementId => dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';

  // API Configuration
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    print('🔗 API Base URL: $url');
    return url;
  }
  
  static String get vapiTherapistUrl => dotenv.env['VAPI_THERAPIST_URL'] ?? 'https://vapi-therapist-ai.vercel.app';
}
