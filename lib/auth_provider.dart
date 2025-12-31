import 'package:flutter/material.dart';
import 'package:nexus_kyt/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _token; // optionally store token

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  String? get token => _token;

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
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
