import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsProvider extends ChangeNotifier {
  List<dynamic> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Using the provided API URL for crypto blogs
      final url = Uri.parse(
          'https://newsapi.org/v2/everything?q=crypto%20blog&language=en&sortBy=publishedAt&apiKey=17f6058ffcc748c4ab662d97f0c91a1d');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          _articles = data['articles'] ?? [];
        } else {
          _error = data['message'] ?? 'Unknown API error';
        }
      } else {
        _error = 'Failed to load news. Status: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
