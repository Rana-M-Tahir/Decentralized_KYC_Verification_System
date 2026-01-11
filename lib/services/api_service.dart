import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use the provided LAN IP for all API calls

  static const String baseUrl =
      kIsWeb ? 'http://localhost:4000' : 'http://192.168.100.103:4000';
  static const String registerEndpoint = '/api/auth/register';

  static Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Register user with email, password, and name
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonResponse,
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Login user with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Login successful',
          'data': jsonResponse['data'],
          'token': jsonResponse['data']?['token'],
          'user': jsonResponse['data']?['user'],
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Wallet Login
  static Future<Map<String, dynamic>> walletLogin({
    required String walletAddress,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/wallet-login'),
        headers: _headers(token),
        body: jsonEncode({
          'walletAddress': walletAddress,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Wallet login successful',
          'data': jsonResponse['data'],
          'token': jsonResponse['data']?['token'],
          'user': jsonResponse['data']?['user'],
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Wallet login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Get current user info
  static Future<Map<String, dynamic>> getMe(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers(token),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonResponse['data'],
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Failed to fetch user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Submit identity/profile data to /api/identity/submit
  static Future<Map<String, dynamic>> submitIdentity({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/identity/submit'),
        headers: _headers(token),
        body: jsonEncode(data),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonResponse,
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Submit failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Upload documents to /api/upload/documents
  static Future<Map<String, dynamic>> uploadDocuments({
    required List<File> documents,
    String? token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/documents'),
      );

      // Add authorization header if token exists
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add all document files
      for (File document in documents) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documents',
            document.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonResponse,
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Liveness verification to /api/verification/liveness
  static Future<Map<String, dynamic>> verifyLiveness({
    required File faceImage,
    required String step,
    String? token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/verification/liveness'),
      );

      // Add authorization header if token exists
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add step field
      request.fields['step'] = step;

      // Add face image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          faceImage.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonResponse,
        };
      } else {
        return {
          'success': false,
          'error': jsonResponse['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
