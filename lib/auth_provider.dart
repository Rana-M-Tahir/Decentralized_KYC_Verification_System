import 'package:flutter/material.dart';
import 'package:nexus_kyt/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _token; // optionally store token
  String? _currentScreen; // Track current screen during info collection
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get currentScreen => _currentScreen;
  bool get isInitialized => _isInitialized;

  // Initialize authentication state and current screen from local storage
  Future<void> initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _currentScreen = prefs.getString('current_screen');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save token to local storage
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Save current screen to local storage (during info collection flow)
  Future<void> setCurrentScreen(String screenName) async {
    _currentScreen = screenName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_screen', screenName);
    } catch (e) {
      print('Error saving screen: $e');
    }
    notifyListeners();
  }

  // Delete token and screen from local storage (on logout)
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_screen');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  // Example login - replace with real API call
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      // TODO: replace with your real API call
      await Future.delayed(const Duration(seconds: 2));
      // fake success condition:
      if (email.isNotEmpty && password.isNotEmpty) {
        _token = "dummy_token"; // store real token here
        notifyListeners();
        return true;
      } else {
        _error = "Invalid credentials";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Example signup - replace with real API call
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        name: name,
      );

      if (result['success']) {
        // Extract token from nested response: data -> token
        final data = result['data']['data'];
        _token = data['token'];
        await _saveToken(_token!); // Save token to local storage
        await setCurrentScreen('profile_form'); // Start at ProfileFormScreen
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Signup failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _token = null;
    _currentScreen = null;
    _clearAuthData();
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
