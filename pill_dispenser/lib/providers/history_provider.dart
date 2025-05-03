// lib/providers/history_provider.dart

import 'package:flutter/material.dart';

class DispensingHistory {
  final String medicationName;
  final DateTime dispensedAt;
  final int quantityDispensed;

  DispensingHistory({
    required this.medicationName,
    required this.dispensedAt,
    required this.quantityDispensed,
  });
}

class HistoryProvider with ChangeNotifier {
  List<DispensingHistory> _history = [];

  List<DispensingHistory> get history => _history;

  void addHistory(String medicationName, int quantity) {
    final newEntry = DispensingHistory(
      medicationName: medicationName,
      dispensedAt: DateTime.now(),
      quantityDispensed: quantity,
    );

    _history.add(newEntry);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}