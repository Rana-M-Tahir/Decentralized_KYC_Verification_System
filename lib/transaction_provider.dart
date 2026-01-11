import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionProvider extends ChangeNotifier {
  List<dynamic> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransactions(String walletAddress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Add your Moralis API Key here
      const apiKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjkzNDJiYmNkLWI3M2ItNDQ5Mi1iODU5LTQ2YmE5NDIwNDcxNSIsIm9yZ0lkIjoiNDg5NzE3IiwidXNlcklkIjoiNTAzODU1IiwidHlwZUlkIjoiN2ZiZjlkMTEtZDQxNi00NjIyLTkwYmUtODBkMmJkMzhlMDE4IiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NjgxNTU1MjQsImV4cCI6NDkyMzkxNTUyNH0.FGXf_mmVDkHa-GfCJpKEQ5s_1SpYzKijCG3yt-cmFgk';

      // Use the provided address if the wallet address is a placeholder or empty
      // String targetAddress = walletAddress;
      // if (targetAddress.contains("...") || targetAddress.isEmpty) {
      String targetAddress = "0xcB1C1FdE09f811B294172696404e88E658659905";
      // }

      final uri = Uri.parse(
          'https://deep-index.moralis.io/api/v2.2/wallets/$targetAddress/history?chain=eth&order=DESC&limit=25');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'X-API-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _transactions = data['result'] ?? [];
      } else {
        _error = 'Failed to load transactions: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
