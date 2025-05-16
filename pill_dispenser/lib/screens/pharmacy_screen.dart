// lib/screens/pharmacy_screen.dart

import 'package:flutter/material.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 244),
      appBar: AppBar(
        title: const Text('Pharmacy Store'),
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'This is the pharmacy/e-commerce screen.\nComing soon!',
          style: TextStyle(color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}