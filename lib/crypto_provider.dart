import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CryptoProvider extends ChangeNotifier {
  List<dynamic> _priceData = []; // List of [timestamp, price]
  bool _isLoading = false;
  String? _error;

  List<dynamic> get priceData => _priceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCryptoHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30&interval=daily');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _priceData = data['prices'] ?? [];
      } else {
        _error = 'Failed to load chart data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
