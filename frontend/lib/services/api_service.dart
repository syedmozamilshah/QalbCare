import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qalbcare/services/environment_service.dart';

class ApiService {
  final String baseUrl = EnvironmentService.apiBaseUrl;
  
  // Timeout duration for requests
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  Future<Map<String, dynamic>> sendChatMessage(
      String userId, String? name, String message) async {
    try {
      print('🚀 Attempting to send chat message to: $baseUrl/chat');
      
      // Validate inputs
      if (userId.trim().isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      // Prepare request body
      final requestBody = {
        'user_id': userId.trim(),
        'name': (name ?? '').trim(),
        'message': message.trim(),
      };
      
      print('📝 Request body: $requestBody');

      // Make the API call
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'User-Agent': 'QalbCare-Flutter/1.0.0',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(requestTimeout);

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response headers: ${response.headers}');
      
      // Handle response
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Validate response structure
        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        
        // Ensure required fields are present
        if (!decodedResponse.containsKey('message') || 
            decodedResponse['message'] == null ||
            decodedResponse['message'].toString().trim().isEmpty) {
          throw Exception('Server did not return a valid response');
        }
        
        print('✅ Message sent successfully');
        return decodedResponse;
      } else if (response.statusCode == 400) {
        final errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorResponse['detail'] ?? 'Bad request');
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        final errorResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final retryAfter = errorResponse['retry_after'] ?? 60;
        throw Exception(errorResponse['detail'] ?? 'Too many requests. Please try again in $retryAfter seconds.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (response.statusCode == 503) {
        throw Exception('Service temporarily unavailable. Please try again later.');
      } else {
        print('❌ Request failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Network error: ${e.message}');
      throw Exception('Network connection error: ${e.message}');
    } on FormatException catch (e) {
      print('❌ Format error: ${e.message}');
      throw Exception('Invalid response format: ${e.message}');
    } on Exception catch (e) {
      // Re-throw custom exceptions
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    } catch (e) {
      print('❌ General error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Health check method
  Future<bool> isServerHealthy() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
