import 'package:flutter/material.dart';

class login_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Colors.blue.shade900,
      title: const Text(
        'NexusKYT',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2),
      ),
      centerTitle: true,
    ));
  }
}
